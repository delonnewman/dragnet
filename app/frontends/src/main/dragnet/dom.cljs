(ns dragnet.dom
  (:require
   [clojure.string :as s]))


(def ^:dynamic *window* js/window)


(defn root-url []
  (.-origin (.-location *window*)))


(defn ex-arguments
  [& {:keys [expected received]}]
  (ex-info
   (str "wrong number of arguments, expected " (pr-str expected) " received " (pr-str received))
   #:ex-arguments{:expected expected :received received}))


(defn url-helper
  [path-fn]
  (fn [& args]
    (str (root-url) (apply path-fn args))))


(defn- path-args
  [args argc]
  (cond
    ;; args map
    (let [[map] args]
      (and
       (= 1 (count args))
       (map? map)
       (<= argc (count map))))
    (first args)

    ;; args list
    (= argc (count args)) args

    :else
    (throw (ex-arguments :expected argc :received (count args)))))


(defn- args-map
  [path-spec args]
  (->> path-spec
       (filter keyword?)
       (map-indexed #(vector %2 (nth args %1)))
       (into {})))


(defn- path-spec->path
  [path-spec m]
  (->> path-spec (map #(get m % %)) (s/join "/")))


(defn path-helper
  [path-spec]
  (let [argc (->> path-spec (filter keyword?) count)]
    (fn [& args]
      (let [args' (path-args args argc)]
        (if (map? args')
          (path-spec->path path-spec args')
          (path-spec->path path-spec (args-map path-spec args')))))))


(defn- entity? [x]
  (and (map? x) (contains? x :entity/type)))


;; TODO: Add keyword argument support
(defn- extract-options
  [args]
  (let [lst (last args)]
    (if (and (map? lst) (not (entity? lst)))
      [lst (drop-last args)]
      [{} args])))


(defn dom-id
  "Construct a dom-id from a series of entity maps. If a :prefix
  keyword argument is given that value will be used as the prefix."
  [entity & args]
  (let [[{prefix :prefix} rest] (extract-options args)
        prefix (or prefix (-> entity :entity/type name))
        root (if-let [id (or (:entity/id entity) entity)]
               (str prefix "-" id)
               prefix)]
    (if (empty? rest)
      root
      (str root "-" (s/join "-" (map dom-id rest))))))

(comment
  (= "question-1" (dom-id {:entity/id 1 :entity/type :question}))
  (= "question-1" (dom-id {:entity/id 1} {:prefix "question"}))
  (= "question-1" (dom-id 1 {:prefix "question"}))
)


(defn form-name
  "Construct a Rails style nested form name from the provided keys."
  [& keys]
  (let [ks
        (if (and (= 1 (count keys)) (coll? (first keys)))
          (first keys)
          keys)]
    (reduce
     (fn [s k]
       (let [k' (if (number? k) (str k) (name k))]
         (str s "[" k' "]")))
     (name (first ks))
     (drop 1 ks))))

(defn non-propagating-handler
  "Return a function that accepts an event with a body that calls the provided
  function passing along the event as its argument and calls stopPropagation
  on the event."
  [f]
  (fn [e]
    (f e)
    (-> e .-nativeEvent .stopPropagation)))
