(ns dragnet.editor.components
  (:require [cljs.pprint :as pp]))

(defn survey
  [state & key-path]
  (get-in @state (cons :survey key-path)))

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

(defn question-options-body
  [question]
  [:div.question-options
   (for [option (:question_options question)]
     [:div.question-option {:key (str "question-" (:id question) "-options-" (:id option))}
      (:text option)])])

(defn short-answer-body [question]
  [:pre (str "short-answer-body" (prn-str question))])

(defn paragraph-body [question]
  [:pre (str "paragraph-body" (prn-str question))])

(defn question-card-body
  [question-types question]
  (case (question-type-slug question-types question)
    "short-answer" [short-answer-body question]
    "paragraph" [paragraph-body question]
    "multiple-choice" [question-options-body question]
    "checkboxes" [question-options-body question]
    [question-options-body question]))

(defn question-card
  [_ state question]
  [:div.card.question.mb-4
   [:div.card-body
    [:div.card-title.d-flex.justify-content-between
     [:h5 (:text question)]
     [:select.form-select.w-25 {:aria-label "Select Question Type"
                                :on-change #(swap! state assoc-in [:survey :questions (question :id) :question_type_id] (-> % .-target .-value))
                                :value (:question_type_id question)}
      (for [type (question-type-list state)]
        [:option {:key (question-type-key (str "question-" (:id question)) type)
                  :value (:id type)}
         (:name type)])]]
      [question-card-body (question-types state) question]]])

(defn survey-questions
  [state]
  [:div.questions
   (let [qs (->> (survey state :questions) vals (sort-by :display_order))]
     (prn qs)
     (for [q qs]
       [question-card {:key (str "question-card-" (:id q))} state q]))])

(defn survey-details
  [state]
  [:div.card.survey-details.mb-5
   [:div.card-body
    [:div.card-title
     [:h3 (survey state :name)]]
    [:textarea.form-control {:rows 3 :placeholder "Description" :name "survey[description]"}
     (survey state :description)]]])

(defn survey-editor
  [state]
  [:div {:class "container"}
   [survey-details state]
   [survey-questions state]])
