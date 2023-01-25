(ns dragnet.shared.utils)

(def ^:dynamic *window* js/window)

(defn root-url [] (.-origin (.-location *window*)))

(defn form-name
  [& keys]
  (let [ks (if (and (= 1 (count keys)) (coll? (first keys)))
             (first keys)
             keys)]
    (reduce
     (fn [s k]
       (let [k' (if (number? k) (str k) (name k))]
         (str s "[" k' "]")))
     (name (first ks))
     (drop 1 ks))))

; A naive plural inflection, but good enough for this
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

(defmacro echo
  [sym]
  `(println ~(name sym) ~sym))
