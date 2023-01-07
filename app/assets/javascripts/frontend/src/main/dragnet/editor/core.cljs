(ns dragnet.editor.core)

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
