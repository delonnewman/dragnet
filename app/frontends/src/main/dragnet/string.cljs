(ns dragnet.string
  (:require
   [clojure.string :as s]))


;; A naive plural inflection, but good enough for this
(defn pluralize
  [word n]
  (if (= 1 n)
    (str "1 " word)
    (if (.endsWith word "s")
      (str n " " word "es")
      (str n " " word "s"))))


(defn blank?
  "Return true if the value is an empty string or a string is only
  whitespace, or the value is an empty collection, otherwise return false."
  ([x]
   (if (seqable? x)
     (or (empty? x) (and (string? x) (empty? (s/replace x #"\s+" ""))))
     false))
  ([x y & zs]
   (and (blank? x) (blank? y) (every? blank? zs))))


(defn present?
  "Return true if the value is not blank, otherwise return false."
  ([x] (not (blank? x)))
  ([x & ys] (and (present? x) (every? present? ys))))


(defn presence
  "Return nil if the value is blank, otherwise return the value."
  [x] (if (blank? x) nil x))


(defn any-blank?
  "Return true if any of the values in the collection are blank,
  otherwise return false."
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
