(ns dragnet.submitter.components
  (:require
   [dragnet.shared.utils :refer [form-name]]
   [dragnet.shared.components :refer [prompt-body]]
   [dragnet.submitter.core :refer [submission-path answer-form-name]]))

(defn answer-prompt
  [& {:keys [label children question-id reply-id survey-id question-type-id]}]
  [:div.card.prompt.mb-4
   [:div.card-body
    [:div.card-title [:h4 label]]
    [:div
     [:input {:type "hidden" :name (answer-form-name question-id :question_id) :value question-id}]
     [:input {:type "hidden" :name (answer-form-name question-id :reply_id) :value reply-id}]
     [:input {:type "hidden" :name (answer-form-name question-id :survey_id) :value survey-id}]
     [:input {:type "hidden" :name (answer-form-name question-id :question_type_id) :value question-type-id}]
     children]]])

(defn reply-submitter
  [reply-id state & {:keys [preview]}]
  (let [survey (-> state :survey)]
    [:div.reply-submitter
     [:h1 (survey :name)]
     [:form {:action (submission-path reply-id) :method "post"}
      [:input {:type "hidden" :name (form-name [:reply :id]) :value reply-id}]
      [:input {:type "hidden" :name (form-name [:reply :survey_id]) :value (survey :id)}]
      (for [question (->> survey :questions vals)]
        ^{:key (question :id)} [answer-prompt
                                :question-id (question :id)
                                :survey-id (survey :id)
                                :reply-id reply-id
                                :question-type-id (question :question_type_id)
                                :label (question :text)
                                :children (prompt-body question :form-name-prefix [:reply :answers_attributes])])
      (when-not preview
        [:button.btn.btn-primary {:type "submit"} "Submit"])]]))
