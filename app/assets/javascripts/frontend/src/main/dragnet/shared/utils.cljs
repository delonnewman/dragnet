(ns dragnet.shared.utils
  (:require [clojure.string :as s]))

(def ^:dynamic *window* js/window)

(defn root-url [] (.-origin (.-location *window*)))

(defn form-name
  [& keys]
  (let [ks (if (and (= 1 (count keys)) (coll? (first keys))) (first keys) keys)]
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

;; TODO: make a blank? protocol
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

(defn any-blank?
  [col] (not-every? present? col))

(defn every-blank
  [col] (filter blank? col))

(defn presence
  [x] (if (blank? x) nil x))

;; TODO: add locale support
;; (see https://api.rubyonrails.org/classes/Array.html#method-i-to_sentence)
(defn sentence
  [col & {:keys [delimiter last-delimiter two-word-delimiter]
          :or {delimiter ", " last-delimiter ", and " two-word-delimiter " and "}}]
  (cond
   (= 1 (count col)) (str (first col))
   (and two-word-delimiter (= 2 (count col))) (str (first col) two-word-delimiter (second col))
   last-delimiter (str (s/join delimiter (drop-last col)) last-delimiter (last col))
   :else (s/join delimiter col)))

(defn ex-blank
  [& {:keys [missing-variables]}]
  (let [mapped (if (map? missing-variables) (map #(str (pr-str (% 0)) " = " (pr-str (% 1))) missing-variables) missing-variables)]
    (ex-info (str (sentence mapped) " should be present")
             {:missing-variables missing-variables})))
