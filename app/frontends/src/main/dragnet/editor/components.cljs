(ns dragnet.editor.components
  "View components for the Editor UI"
  (:require
   [cljs.core.async :refer [<! go]]
   [clojure.string :as s]
   [dragnet.core :as core]
   [dragnet.editor.core :as editor :refer
    [survey
     survey-edited?
     type-list
     errors?]]
   [dragnet.common.components :refer
    [icon switch text-field remove-button]]
   [dragnet.common.core :refer
    [multiple-answers?]]
   [dragnet.common.utils
    :as utils
    :refer [time-ago-in-words pp-str]
    :include-macros true]
   [dragnet.dom :as dom]))


(defn error-handler
  [state]
  (fn [res]
    (js/console.error "handling error" (pp-str res))
    (swap! state editor/with-errors (res :body))))


(defmulti question-card-body :question/type)

(defmethod question-card-body :dragnet.core.type/text [_ _]
  [:input.form-control {:type "text"}])

(defmethod question-card-body :dragnet.core.type/long-text [_ _]
  [:textarea.form-control {:rows 3}])


(defn remove-option-handler
  [ref question option]
  (dom/non-propagating-handler
   (fn []
     (swap! ref editor/remove-option question option))))


(defn make-option-handler
  [field value-fn]
  (fn [ref question option]
    (dom/non-propagating-handler
     (fn [event]
       (let [value (-> event .-target .-value value-fn)]
         (swap! ref editor/assoc-in-option question option field value))))))


(def update-option-text-handler (make-option-handler :question.option/text identity))
(def update-option-weight-handler (make-option-handler :question.option/weight utils/->int))


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
        :on-change (update-option-text-handler state question option)}]]
     [:div
      [:input.form-control
       {:type "number"
        :placeholder "Numerical Weight"
        :default-value (option :question.option/weight)
        :on-change (update-option-weight-handler state question option)}]]
     [:div.ms-1
      [remove-button {:on-click (remove-option-handler state question option)}]]]))


(defn add-option-handler
  [ref question]
  (dom/non-propagating-handler
   (fn []
    (swap! ref editor/assoc-option question (editor/new-option)))))


(defmethod question-card-body :dragnet.core.type/choice [ref question]
  [:div
   [:div.question-options
    (for [option (->> (:question/options question) vals (remove :entity/_destroy))]
      ^{:key (utils/dom-id question option)} [choice-option ref question option])]
   [:a.btn.btn-link {:href "#" :on-click (add-option-handler ref question)} "Add Option"]])

(defmethod question-card-body :dragnet.core.type/number [_ _]
  [:input.form-control {:type "number"}])

(defmethod question-card-body :dragnet.core.type/date-and-time [_ _]
  [:input.form-control {:type "datetime-local"}])

(defmethod question-card-body :dragnet.core.type/date [_ _]
  [:input.form-control {:type "date"}])

(defmethod question-card-body :dragnet.core.type/time [_ _]
  [:input.form-control {:type "time"}])


(defn change-required-handler
  [ref question]
  (dom/non-propagating-handler
   (fn [event]
     (let [checked (-> event .-target .-checked)]
       (swap!
        ref
        assoc-in
        [:survey :survey/questions (question :entity/id) :question/required]
        checked)))))


(defn question-card-footer
  [ref question]
  [:div.card-footer
   [:div.d-flex.justify-content-end
    (let [form-id (str "option-" (question :id) "-required")]
      ^{:key form-id}
      [switch
       {:id form-id
        :checked (question :question/required)
        :on-change (change-required-handler ref question)
        :style {:margin-right "20px"}
        :label "Required"}])]])


(defn change-type-handler
  [ref question]
  (dom/non-propagating-handler
   (fn [event]
     (let [type-key (-> event .-target .-value)]
       (swap!
        ref
        assoc-in
        [:survey :survey/questions (question :entity/id) :question/type]
        (core/->type type-key))))))


(defn select-question-type
  [ref question]
  (let [type (:question/type question)
        attrs {:aria-label "Select Question Type"
               :on-change (change-type-handler ref question)}
        attrs (if type (assoc attrs :value type) attrs)]
    [:select.form-select.w-25
     attrs
     (when-not type [:option "Select Question Type"])
     (for [type (type-list @ref)]
       [:option {:key (type :symbol) :value (type :slug)} (type :name)])]))


(defn update-question-text-handler
  [ref question]
  (dom/non-propagating-handler
   (fn [e]
     (swap! ref editor/assoc-question-field question :question/text (-> e .-target .-value)))))


(defn remove-question-handler
  [ref question]
  (dom/non-propagating-handler
   (fn []
     (swap! ref editor/remove-question question))))


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
        :on-change (update-question-text-handler ref question)}]
      (when (question :question/required) [:span {:title "Required"} "*"])]
     [select-question-type ref question]
     [remove-button {:on-click (remove-question-handler ref question)}]]
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
  [basis]
  [:table.table.table-sm
   [:tbody
    (for [key (keys basis)]
      (let [val (map key)]
        [:tr
         [:th key]
         [:td (if (map? val) [map-table val] (pp-str val))]]))]])


(defn dev-info
  [basis]
  [map-table basis])


(defn save-survey-handler
  [ref]
  (dom/non-propagating-handler
   (fn []
     (go
       (let [res
             (<! (utils/http-request
                  :method :post
                  :url (editor/apply-survey-edits-url (@ref :survey))
                  :error-fn (error-handler ref)))
             t   (-> res :body :updated_at)]
         (swap! ref assoc :edits nil :updated_at t))))))


(defn update-survey-field-handler
  [ref field]
  (dom/non-propagating-handler
   (fn [e]
     (swap! ref editor/update-survey-field field (-> e .-target .-value)))))


(defn add-question-handler
  [ref]
  (dom/non-propagating-handler
   (fn []
     (swap! ref editor/assoc-question (editor/new-question)))))


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
     (when (errors? @ref) (str "Error: " (s/join ", " (editor/errors @ref))))]
    [:div
     [:button.btn.btn-sm.btn-primary.me-1
      {:type "button"
       :disabled (not (survey-edited? @ref))
       :on-click (save-survey-handler ref)}
      "Save"]]]
   [survey-details
    {:id (survey @ref :entity/id)
     :name (survey @ref :survey/name)
     :description (survey @ref :survey/description)
     :on-change-description (update-survey-field-handler ref :survey/description)
     :on-change-name (update-survey-field-handler ref :survey/name)}]
   [:div.mb-3.d-flex.justify-content-end
    [:button.btn.btn-sm.btn-secondary
     {:type "button"
      :on-click (add-question-handler ref)}
     (icon "fa-solid" "plus" "Add Question")]]
   [survey-questions ref]])
