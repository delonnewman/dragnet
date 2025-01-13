(ns dragnet.editor.core
  "Core logic for the Editor UI"
  (:require
   [dragnet.core :as core]
   [dragnet.editor.entities :refer [make-survey]]
   [dragnet.common.utils
    :as utils
    :refer [echo]
    :include-macros true]))


(def survey-path (utils/path-helper ["/api/v1/editing/surveys" :entity/id]))
(def survey-url (utils/url-helper survey-path))

(def apply-survey-edits-path (utils/path-helper ["/api/v1/editing/surveys" :entity/id "apply"]))
(def apply-survey-edits-url (utils/url-helper apply-survey-edits-path))

(comment
  survey-url
  (survey-url 1)
  )

(defn create-basis
  "Create an edtior basis map (a representation of the editors current state).

  Required keys for input data are:
    :survey (a survey map)
    :type_hierarchy (a map of type hierarchy information),
    :type_registry (a map of type meta data)

  Optional keys:
    :update_at (a timestamp indicating the editors last update)
    :edits (a collection of edit history data)
  "
  [data]
  {::survey (make-survey (:survey data))
   ::updated-at (:updated_at data)
   ::edits (:edits data)
   ::type-hierarchy (core/->type-hierarchy (:type_hierarchy data))
   ::type-registry (core/->type-registry (:type_registry data))})


(defn survey
  [basis & key-path]
  (if (empty? key-path)
    (basis ::survey)
    (get-in basis (cons ::survey key-path))))


(defn state-change? [old new]
  (not= (::survey old) (::survey new)))


(defn with-errors [basis errors]
  (assoc basis ::errors errors))


(defn errors [basis]
  (basis ::errors))


(defn errors? [basis]
  (-> basis errors seq))


(defn updated-at [basis]
  (basis ::updated-at))


(defn survey-edited?
  "Return true if the survey state has edits otherwise return false"
  [basis]
  (-> (basis ::edits) seq))


(defn type-list
  "Return the list of types from the editor basis"
  [basis]
  (->> basis ::type-registry vals))


(defn assoc-question-field
  [state question field value]
  (assoc-in state [::survey :survey/questions (question :entity/id) field] value))


(defn remove-question
  [state question]
  (assoc-in state [::survey :survey/questions (question :entity/id) :_destroy] true))


(defn update-survey-field
  [state field value]
  (assoc-in state [::survey field] value))


(defn new-text-generator
  [text-template]
  (let [n (atom -1)]
    (fn []
      (swap! n inc)
      (if (zero? @n)
        text-template
        (str text-template " (" @n ")")))))


(def new-question-text (new-text-generator "New Question"))
(def new-option-text (new-text-generator "New Option"))


(defn assoc-option
  [state question option]
  (assoc-in
   state
   [::survey :survey/questions (question :entity/id) :question/options (option :entity/id)]
   option))


(defn assoc-question
  [state question]
  (assoc-in state [::survey :survey/questions (question :entity/id)] question))


(let [temp-id (atom 0)]
  (defn new-option []
    {:id (swap! temp-id dec) :question.option/text (new-option-text)})

  (defn new-question []
    {:id (swap! temp-id dec) :question/text (new-question-text)}))


(defn remove-option
  [state question option]
  (assoc-in
   state
   [::survey :survey/questions (question :entity/id) :question/options (option :entity/id) :_destroy]
   true))


(defn assoc-in-option
  [state question option field value]
  (assoc-in
   state
   [::survey :survey/questions (question :entity/id) :question/options (option :entity/id) field]
   value))


(defn survey-questions
  [basis]
  (->> basis
       ::survey
       :survey/questions
       vals
       (remove :entity/_destroy)
       (sort-by :question/display-order)))


(defn options->update
  [[id option]]
  [id
   {:id id
    :text (:question.option/text option)
    :weight (:question.option/weight option)
    :_destroy (:entity/_destroy option)}])


(defn question->update
  [[id question]]
  [(str id)
   {:id (str id)
    :text (:question/text question)
    :display_order (:question/display-order question)
    :required (:question/required question)
    :settings (:question/settings question)
    :type_symbol (-> question :question/type name keyword)
    :question_options (->> question :question/options (map options->update) (into {}))
    :_destroy (:entity/_destroy question)}])


(defn user->update
  [user]
  {:id (:entity/id user)
   :name (:user/name user)
   :nickname (:user/nickname user)})


(defn survey->update
  [survey]
  {:id (str (:entity/id survey))
   :name (:survey/name survey)
   :author_id (get-in survey [:survey/author :entity/id])
   :author (user->update (:survey/author survey))
   :updated_at (:survey/updated-at survey)
   :description (:survey/description survey)
   :questions (->> survey :survey/questions (map question->update) (into {}))})
