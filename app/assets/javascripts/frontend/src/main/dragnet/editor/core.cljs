(ns dragnet.editor.core
  (:require
   [dragnet.shared.utils :as utils]))

;; TODO: add validation for surveys, edits, questions, and question options
;; TODO: add stateful functions

(defn survey
  [state & key-path]
  (if (empty? key-path)
    (state :survey)
    (get-in state (cons :survey key-path))))

(defn survey-edited?
  "Return true if the survey state has edits otherwise return false"
  [state]
  (-> (state :edits) seq))

(defn question-types
  "Return the question types map from the survey state"
  [state]
  (-> state :question_types))

(defn question-type-list
  "Return the list of question types from the survey state"
  [state]
  (-> state :question_types vals))

(defn question-type
  "Return the question type of the question or nil if not present.

  For the editor we can't rely on pulling the slug structurally
  (i.e. (-> q :question_type :slug)) because the question type is
  updated by it's id."
  [state question]
  (let [types (question-types state)]
    (-> question :question_type_id types)))

(defn question-type-slug
  "Return the question type slug of the question or nil if not present."
  [state question]
  (:slug (question-type state question)))

(defn question-type-id
  "Return the question type id of the question"
  [question]
  (-> question :question_type_id))

(defn question-type-uid
  "Return a universally unique id for a question type.

  When a type is given that type id will be used otherwise the question's
  type id will be used. The type can be specified as a map with an :id key
  or as a scalar value."
  ([question]
   (question-type-uid question (question-type-id question)))
  ([question type]
   (let [id (if (map? type) (type :id) type)]
     (str "question-" (question :id) "-type-" id))))

(defn survey-path
  "Return the API path for accessing survey data"
  [state]
  (let [id (if (map? state) (-> state :survey :id) state)]
    (str "/api/v1/editing/surveys/" id)))

(defn survey-url
  "Return the full API url for accessing survey data"
  [state]
  (str (utils/root-url) (survey-path state)))
