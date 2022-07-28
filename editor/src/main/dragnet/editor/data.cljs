(ns dragnet.editor.data)

(defn survey
  [state & key-path]
  (if (empty? key-path)
    (@state :survey)
    (get-in @state (cons :survey key-path))))

(defn survey-edited?
  [state]
  (-> (@state :edits) seq))

(defn question-types
  [state]
  (-> @state :question_types))

(defn question-type-list
  [state]
  (-> @state :question_types vals))

(defn question-type-slug
  [types question]
  (-> question :question_type_id types :slug))

(defn question-type-key
  [ns type]
  (str ns "-type-" (:id type)))

(defn- question-settings-predicate
  [setting]
  (fn [question]
    (get-in question [:settings setting] false)))

(def long-answer? (question-settings-predicate :long_answer))
(def multiple-answers? (question-settings-predicate :multiple_answers))
(def include-date? (question-settings-predicate :include_date))
(def include-time? (question-settings-predicate :include_time))

(defn include-date-and-time?
  [q]
  (and (include-date? q) (include-time? q)))

