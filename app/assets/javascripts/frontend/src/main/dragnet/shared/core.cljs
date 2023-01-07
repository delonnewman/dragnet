(ns dragnet.shared.core)

(defn- question-settings-predicate
  [setting]
  (fn [question]
    (get-in question [:settings setting] false)))

(def long-answer? (question-settings-predicate "long_answer"))
(def multiple-answers? (question-settings-predicate "multiple_answers"))
(def include-date? (question-settings-predicate "include_date"))
(def include-time? (question-settings-predicate "include_time"))

(defn include-date-and-time?
  [q]
  (and (include-date? q) (include-time? q)))

(defn question-type-slug
  [types question]
  (-> question :question_type_id types :slug))
