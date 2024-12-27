(ns dragnet.editor.components
  "View components for the Editor UI"
  (:require
    [clojure.string :as s]
    [dragnet.editor.core :as editor :refer
     [survey survey-edited? question-type-slug question-types question-type-list question-type-uid errors?]]
    [dragnet.common.components :refer
     [icon switch text-field remove-button]]
    [dragnet.common.core :refer
     [multiple-answers? long-answer? include-date? include-time? include-date-and-time?]]
    [dragnet.shared.utils :as utils :refer [time-ago-in-words pp-str] :include-macros true]))


(defn choice-option
  [state question option]
  (let [dom-id (str "question-option-" (question :entity/id) "-" (option :entity/id))]
    [:div.question-option.mb-2.d-flex.align-items-center
     [:div.me-1
      (if (multiple-answers? question)
        [:input {:id dom-id :type "checkbox" :disabled true}]
        [:input {:id dom-id :type "radio" :disabled true}])]
     [:div.me-1
      [:input.form-control
       {:type "text"
        :placeholder "Option Text"
        :default-value (option :question.option/text)
        :on-change (editor/update-option-text! state question option)}]]
     [:div
      [:input.form-control
       {:type "number"
        :placeholder "Numerical Weight"
        :default-value (option :question.option/weight)
        :on-change (editor/update-option-weight! state question option)}]]
     [:div.ms-1
      [remove-button {:on-click (editor/remove-option! state question option)}]]]))


(defn choice-body
  [ref question]
  [:div
   [:div.question-options
    (for [option (->> (:question/options question) vals (remove :entity/_destroy))]
      ^{:key (utils/dom-id question option)} [choice-option ref question option])]
   [:a.btn.btn-link {:href "#" :on-click (editor/add-option! ref question)} "Add Option"]])


(defn text-body
  [_ question]
  (if (long-answer? question)
    [:textarea.form-control {:rows 3}]
    [:input.form-control {:type "text"}]))


(defn number-body
  [_ _question]
  [:input.form-control {:type "number"}])


(defn time-body
  [_ question]
  (cond
    (include-date-and-time? question) [:input.form-control {:type "datetime-local"}]
    (include-date? question) [:input.form-control {:type "date"}]
    (include-time? question) [:input.form-control {:type "time"}]
    :else [:input.form-control {:type "datetime-local"}]))


(def question-card-bodies
  {"text"   text-body
   "choice" choice-body
   "number" number-body
   "time"   time-body})


(defn question-card-body
  [ref question]
  (when-let [body (question-card-bodies (question-type-slug @ref question))]
    [body ref question]))


(defn question-card-footer
  [ref question]
  [:div.card-footer
   [:div.d-flex.justify-content-end
    (when-let [type ((question-types @ref) (question :question_type_id))]
      (for [[ident {text :text type :type default :default}] (type :question.type/settings)]
        (let [form-id (str "option-" (question :id) "-" (name ident))]
          ^{:key form-id} [switch
                           {:id form-id
                            :checked (editor/question-setting question ident :default default)
                            :on-change (editor/change-setting! ref question ident)
                            :style {:margin-right "20px"}
                            :label text}])))
    (let [form-id (str "option-" (question :id) "-required")]
      ^{:key form-id} [switch
                       {:id form-id
                        :checked (question :question/required)
                        :on-change (editor/change-required! ref question)
                        :style {:margin-right "20px"}
                        :label "Required"}])]])


(defn select-question-type
  [ref question]
  (let [type-id (editor/question-type-id question)
        attrs {:aria-label "Select Question Type"
               :on-change (editor/change-type! ref question)}]
    [:select.form-select.w-25
     (if type-id (assoc attrs :value type-id) attrs)
     (when-not type-id
       [:option "Select Question Type"])
     (for [type (question-type-list @ref)]
       [:option
        {:key (question-type-uid question type)
         :value (type :entity/id)}
        (type :question.type/name)])]))


(defn question-card
  [ref question]
  [:div.card.question.mb-4 {:id (utils/dom-id question)}
   [:div.card-body
    [:div.card-title.d-flex.justify-content-between
     [:div.question-title.w-100.d-flex.me-3
      [text-field
       {:id (question :entity/id)
        :title "Enter question text"
        :class "h5"
        :default-value (question :question/text)
        :on-change (editor/update-question-text! ref question)}]
      (when (question :question/required) [:span {:title "Required"} "*"])]
     [select-question-type ref question]
     [remove-button {:on-click (editor/remove-question! ref question)}]]
    [question-card-body ref question]]
   [question-card-footer ref question]])


(defn survey-questions
  [ref]
  [:div.questions
   (for [q (editor/survey-questions @ref)]
     ^{:key (utils/dom-id q)} [question-card ref q])])


(defn survey-details
  [& {:keys [id name description on-change-description on-change-name]}]
  [:div.card.survey-details.mb-5
   [:div.card-body
    [:div.card-title.pb-3
     [text-field
      {:id id
       :title "Enter form name"
       :class "h3"
       :default-value name
       :on-change on-change-name}]]
    [:textarea.form-control
     {:rows 1
      :placeholder "Description"
      :on-blur on-change-description
      :default-value description}]]])


(defn map-table
  [map]
  [:table.table.table-sm
   [:tbody
    (for [key (keys map)]
      (let [val (map key)]
        [:tr
         [:th key]
         [:td (if (map? val) [map-table val] (pp-str val))]]))]])


(defn dev-info
  [state]
  [map-table state])


(defn survey-editor
  [ref]
  [:div {:class "container"}
   [:div.mb-3.d-flex.justify-content-between
    [:div
     [:small.me-1.text-muted
      (if (survey-edited? @ref)
        (str "Last saved " (time-ago-in-words (editor/updated-at @ref)))
        (str "Up to date. Saved " (time-ago-in-words (editor/updated-at @ref))))]]
    [:small#errors.text-danger
     (if (errors? @ref) (str "Error: " (s/join ", " (editor/errors @ref))))]
    [:div
     [:button.btn.btn-sm.btn-primary.me-1
      {:type "button"
       :disabled (not (survey-edited? @ref))
       :on-click (editor/save-survey! ref)}
      "Save"]]]
   [survey-details
    {:id (survey @ref :entity/id)
     :name (survey @ref :survey/name)
     :description (survey @ref :survey/description)
     :on-change-description (editor/update-survey-field! ref :survey/description)
     :on-change-name (editor/update-survey-field! ref :survey/name)}]
   [:div.mb-3.d-flex.justify-content-end
    [:button.btn.btn-sm.btn-secondary
     {:type "button"
      :on-click (editor/add-question! ref)}
     (icon "fa-solid" "plus" "Add Question")]]
   [survey-questions ref]
   [dev-info @ref]])
