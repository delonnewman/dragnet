(ns dragnet.common.utils
  (:require
   [cljs-http.client :as http]
   [cljs.core.async :refer [<! go]]
   [clojure.string :as s]
   [cognitect.transit :as t]))


(def ^:dynamic *window* js/window)


(defn root-url
  [] (.-origin (.-location *window*)))


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


(defn http-request
  [& {:keys [error-fn method url transit-params]}]
  (go (let [args  {:method method :url url :transit-params transit-params}
            res   (<! (http/request args))
            error (= :http-error (:error-code res))]
        (cond
          (and error error-fn) (error-fn res)
          error (throw (ex-info "communication error" #:ex-http{:keys args :response res}))
          :else (res :body)))))


(defn form-name
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


(defn entity?
  [x]
  (and (map? x) (contains? x :entity/type)))


;; TODO: Add keyword argument support
(defn extract-options
  [args]
  (let [lst (last args)]
    (if (and (map? lst) (not (entity? lst)))
      [lst (drop-last args)]
      [{} args])))


(defn dom-id
  [entity & args]
  (let [[{prefix :prefix} rest] (extract-options args)
        prefix (or prefix (-> entity :entity/type name))
        root (if-let [id (entity :entity/id)]
               (str prefix "-" id)
               prefix)]
    (if (empty? rest)
      root
      (str root "-" (s/join "-" (map dom-id rest))))))

(comment

(dom-id {:entity/id 1 :entity/type :question})
(dom-id {:entity/id 1 :entity/type :question} {:entity/id 1 :entity/type :question-option})
(dom-id {:entity/id 1 :entity/type :question} {:prefix "test"})
  )

;; A naive plural inflection, but good enough for this
(defn pluralize
  [word n]
  (if (= 1 n)
    (str "1 " word)
    (if (.endsWith word "s")
      (str n " " word "es")
      (str n " " word "s"))))


(def ^:private years   31104000000)
(def ^:private months  2592000000)
(def ^:private weeks   604800000)
(def ^:private days    86400000)
(def ^:private hours   3600000)
(def ^:private minutes 60000)
(def ^:private seconds 1000)


(defn time-ago-in-words
  [^js/Date time]
  (let [now    (js/Date.)
        diff   (- time now)
        suffix (if (pos? diff) "from now" "ago")
        diff'  (Math/abs diff)]
    (cond
      (> diff' years)   (str (->> (/ diff' years)   Math/floor (pluralize "year"))   " " suffix)
      (> diff' months)  (str (->> (/ diff' months)  Math/floor (pluralize "month"))  " " suffix)
      (> diff' weeks)   (str (->> (/ diff' weeks)   Math/floor (pluralize "week"))   " " suffix)
      (> diff' days)    (str (->> (/ diff' days)    Math/floor (pluralize "day"))    " " suffix)
      (> diff' hours)   (str (->> (/ diff' hours)   Math/floor (pluralize "hour"))   " " suffix)
      (> diff' minutes) (str (->> (/ diff' minutes) Math/floor (pluralize "minute")) " " suffix)
      (> diff' seconds) (str (->> (/ diff' seconds) Math/floor (pluralize "second")) " " suffix)
      :else "just now")))


(defn blank?
  ([x]
   (if (seqable? x)
     (or (empty? x) (and (string? x) (empty? (s/replace x #"\s+" ""))))
     false))
  ([x y & zs]
   (and (blank? x) (blank? y) (every? blank? zs))))


(defn present?
  ([x] (not (blank? x)))
  ([x & ys] (and (present? x) (every? present? ys))))


(defn presence
  "Return nil if the value is blank, otherwise return the value."
  [x] (if (blank? x) nil x))


(defn any-blank?
  [col]
  (not-every? present? col))


(defn ->sentence
  [col & {:keys [delimiter last-delimiter two-word-delimiter]
          :or {delimiter ", " last-delimiter ", and " two-word-delimiter " and "}}]
  (cond
    (= 1 (count col)) (str (first col))
    (and two-word-delimiter (= 2 (count col))) (str (first col) two-word-delimiter (second col))
    last-delimiter (str (s/join delimiter (drop-last col)) last-delimiter (last col))
    :else (s/join delimiter col)))


(defn ex-blank
  "Create an ex-info exception with meta data regarding missing variables.
  The :missing-variables keyword argument is required, it can be a collection
  of symbols or a map of symbols and their values."
  [& {:keys [missing-variables]}]
  (let [mapped
        (if (map? missing-variables)
          (map #(str (pr-str (% 0)) " = " (pr-str (% 1))) missing-variables)
          missing-variables)]
    (ex-info (str (->sentence mapped) " should be present")
             #:ex-blank{:missing-variables missing-variables})))


(defn name-of-type
  [t] (if (fn? t) (.-name t) t))


(defn type-name
  [x] (-> x type name-of-type))


(defn ex-coercion
  [& {:keys [value target-type]}]
  (ex-info (str "cannot coerce " (pr-str value) ":" (type-name value) " into a " target-type)
           #:ex-coercion{:value value :target-type target-type}))


(defn ->uuid
  "Coerce the value into a UUID or fail trying"
  [x]
  (cond
    (uuid? x) x
    (t/uuid? x) (parse-uuid (str x))
    (string? x) (parse-uuid x)
    :else (throw (ex-coercion :value x :target-type "UUID"))))


(defn ->int
  [x]
  (cond
    (int? x) x
    (or (float? x) (string? x)) (js/parseInt x 10)
    :else (throw (ex-coercion :value x :target-type "int"))))


(defn map-values
  "Return a new map with the same keys and values computed by the given function."
  [f map] (reduce (fn [m [k v]] (assoc m k (f v))) {} map))
