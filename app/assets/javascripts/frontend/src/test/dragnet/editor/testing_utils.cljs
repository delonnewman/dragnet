(ns dragnet.editor.testing-utils)

(def question-types
  {1 {:id 1 :slug "text"}
   2 {:id 2 :slug "number"}
   3 {:id 3 :slug "choice"}
   4 {:id 4 :slug "time"}})

(def state (atom {:survey {:id (random-uuid)} :question_types question-types}))

(defn question-of-type [type]
  (when-first [t (filter #(= type (:slug %)) (vals question-types))]
    {:id (random-uuid) :question_type_id (t :id) :question_type {:id (t :id) :slug type}}))
