(ns dragnet.editor.components
  "View components for the Editor UI"
  (:require
    [clojure.string :as s]
    [cljs.core.async :refer [<! go]]
    [cljs-http.client :as http]
    [dragnet.shared.utils :refer [time-ago-in-words pp pp-str http-request] :include-macros true]
    [dragnet.shared.components :refer
      [icon switch text-field remove-button]]
    [dragnet.shared.core :refer
      [multiple-answers? long-answer? include-date? include-time? include-date-and-time?]]
    [dragnet.editor.core :as editor :refer
      [survey survey-edited? question-type-slug question-types question-type-list question-type-uid apply-survey-edits-url errors?]]))

(defn choice-option
  [state question option]
  (let [dom-id (str "question-option-" (question :id) "-" (option :id))]
    [:div.question-option.mb-2.d-flex.align-items-center
     [:div.me-1
      (if (multiple-answers? question)
        [:input {:id dom-id :type "checkbox" :disabled true}]
        [:input {:id dom-id :type "radio" :disabled true}])]
     [:div.me-1
      [:input.form-control
       {:type "text"
        :placeholder "Option Text"
        :default-value (option :text)
        :on-change (editor/update-option-text! state question option)}]]
     [:div
      [:input.form-control
       {:type "number"
        :placeholder "Numerical Weight"
        :default-value (option :weight)
        :on-change (editor/update-option-weight! state question option)}]]
     [:div.ms-1
      [remove-button {:on-click (editor/remove-option! state question option)}]]]))

(defn choice-body
  [ref question]
  [:div
   [:div.question-options
    (for [option (->> (:question_options question) vals (remove :_destroy))]
      (let [dom-id (str "question-" (:id question) "-options-" (option :id))]
        ^{:key dom-id} [choice-option ref question option]))]
   [:a.btn.btn-link {:href "#" :on-click (editor/add-option! ref question)} "Add Option"]])

(defn text-body
  [_ question]
  (let [form-id (str "question-" (question :id))]
    (if (long-answer? question)
      [:textarea.form-control {:id form-id :rows 3}]
      [:input.form-control {:id form-id :type "text"}])))

(defn number-body
  [_ question]
  (let [form-id (str "question" (question :id))]
    [:input.form-control {:id form-id :type "number"}]))

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
      (for [[ident {text :text type :type default :default}] (type :settings)]
        (let [form-id (str "option-" (question :id) "-" (name ident))]
          ^{:key form-id} [switch
                           {:id form-id
                            :checked (get-in question [:settings ident] default)
                            :on-change (editor/change-setting! ref question ident)
                            :style {:margin-right "20px"}
                            :label text}])))
    (let [form-id (str "option-" (question :id) "-required")]
        ^{:key form-id} [switch
                         {:id form-id
                          :checked (question :required)
                          :on-change (editor/change-required! ref question)
                          :style {:margin-right "20px"}
                          :label "Required"}])]])
   
(defn select-question-type
  [ref question]
  (let [type-id (question :question_type_id)
        attrs {:aria-label "Select Question Type"
               :on-change (editor/change-type! ref question)}]
    [:select.form-select.w-25
     (if type-id (assoc attrs :value type-id) attrs)
     (when-not type-id
       [:option "Select Question Type"])
     (for [type (question-type-list @ref)]
       [:option
        {:key (question-type-uid question type)
         :value (:id type)}
        (type :name)])]))

(defn question-card
  [ref question]
  [:div.card.question.mb-4
   [:div.card-body
    [:div.card-title.d-flex.justify-content-between
     [:div.question-title.w-100.d-flex.me-3
      [text-field
       {:id (question :id)
        :title "Enter question text"
        :class "h5"
        :default-value (question :text)
        :on-change (editor/update-question-text! ref question)}]
      (when (question :required) [:span {:title "Required"} "*"])]
     [select-question-type ref question]
     [remove-button {:on-click (editor/remove-question! ref question)}]]
    [question-card-body ref question]]
   [question-card-footer ref question]])

(defn survey-questions
  [ref]
  [:div.questions
   (let [qs (->> (survey @ref :questions) vals (remove :_destroy) (sort-by :display_order))]
     (for [q qs]
       (let [key (str "question-card-" (:id q))]
         ^{:key key} [question-card ref q])))])

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

(defn survey-editor
  [ref]
  [:div {:class "container"}
   [:div.mb-3.d-flex.justify-content-between
    [:div
     [:small.me-1.text-muted
      (if (survey-edited? @ref)
       (str "Last saved " (time-ago-in-words (@ref :updated_at)))
       (str "Up to date. Saved " (time-ago-in-words (@ref :updated_at))))]]
    [:small#errors.text-danger
     (if (errors? @ref) (str "Error: " (s/join ", " (@ref :errors))))]
    [:div
     [:button.btn.btn-sm.btn-primary.me-1
      {:type "button"
       :disabled (not (survey-edited? @ref))
       :on-click (editor/save-survey! ref)}
      "Save"]]]
   [survey-details
    {:id (survey @ref :id)
     :name (survey @ref :name)
     :description (survey @ref :description)
     :on-change-description (editor/update-survey-field! ref :description)
     :on-change-name (editor/update-survey-field! ref :name)}]
   [:div.mb-3.d-flex.justify-content-end
    [:button.btn.btn-sm.btn-secondary
     {:type "button"
      :on-click (editor/add-question! ref)}
     (icon "fa-solid" "plus" "Add Question")]]
   [survey-questions ref]])
