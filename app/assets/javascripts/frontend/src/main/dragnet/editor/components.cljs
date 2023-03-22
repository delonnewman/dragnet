(ns dragnet.editor.components
  "View components for the Editor UI"
  (:require-macros
   [cljs.core.async.macros :refer [go]])
  (:require
    [clojure.string :as s]
    [cljs.core.async :refer [<!]]
    [cljs-http.client :as http]
    [dragnet.shared.utils :refer [time-ago-in-words ->int pp pp-str http-request] :include-macros true]
    [dragnet.shared.components :refer
      [icon switch text-field remove-button]]
    [dragnet.shared.core :refer
      [multiple-answers? long-answer? include-date? include-time? include-date-and-time?]]
    [dragnet.editor.core :as editor :refer
      [survey survey-edited? question-type-slug question-types question-type-list question-type-uid apply-survey-edits-url errors?]]))

(defn error-handler
  [state]
  (fn [res]
    (println "handling error" (pp-str res))
    (swap! state assoc :errors (res :body))))

(defn- option-updater
  [field value-fn]
  (fn [state question option]
    (fn [event]
      (let [value (-> event .-target .-value value-fn)]
        (swap! state assoc-in [:survey :questions (question :id) :question_options (option :id) field] value)))))

(def ^:private option-text-updater (option-updater :text identity))
(def ^:private option-weight-updater (option-updater :weight ->int))

(defn- remove-option
  [state question option]
  (fn [e]
    (swap! state assoc-in [:survey :questions (question :id) :question_options (option :id) :_destroy] true)
    (-> e .-nativeEvent .preventDefault)
    (-> e .-nativeEvent .stopPropagation)))

(defn- choice-option
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
        :on-change (option-text-updater state question option)}]]
     [:div
      [:input.form-control
       {:type "number"
        :placeholder "Numerical Weight"
        :default-value (option :weight)
        :on-change (option-weight-updater state question option)}]]
     [:div.ms-1
      [remove-button {:on-click (remove-option state question option)}]]]))

(def ^:private temp-id (atom 0))

(defn- add-option
  [state question]
  (fn [e]
    (let [id (swap! temp-id dec)]
      (swap! state assoc-in [:survey :questions (question :id) :question_options id] {:id id}))
    (-> e .-nativeEvent .preventDefault)
    (-> e .-nativeEvent .stopPropagation)))

(defn choice-body
  [state question]
  [:div
   [:div.question-options
    (for [option (->> (:question_options question) vals (remove :_destroy))]
      (let [dom-id (str "question-" (:id question) "-options-" (option :id))]
        ^{:key dom-id} [choice-option state question option]))]
   [:a.btn.btn-link {:href "#" :on-click (add-option state question)} "Add Option"]])

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
  [state question]
  (when-let [body (question-card-bodies (question-type-slug @state question))]
    [body state question]))

(defn- change-setting-handler
  [state question setting]
  (fn [event]
    (println "change-setting-handler" event)
    (let [checked (-> event .-target .-checked)
          path [:survey :questions (question :id) :settings]
          settings (assoc (get-in @state path {}) setting checked)]
      (println "path" path)
      (println "settings" settings)
      (println "state" (-> @state :survey))
      (swap! state assoc-in path settings))))

(defn- change-required-handler
  [state question]
  (fn [event]
    (let [checked (-> event .-target .-checked)]
      (swap! state assoc-in [:survey :questions (question :id) :required] checked))))

(defn question-card-footer
  [state question]
  [:div.card-footer
   [:div.d-flex.justify-content-end
    (when-let [type ((question-types @state) (question :question_type_id))]
      (for [[ident {text :text type :type default :default}] (type :settings)]
        (let [form-id (str "option-" (question :id) "-" (name ident))]
          ^{:key form-id} [switch
                           {:id form-id
                            :checked (get-in question [:settings ident] default)
                            :on-change (change-setting-handler state question ident)
                            :style {:margin-right "20px"}
                            :label text}])))
    (let [form-id (str "option-" (question :id) "-required")]
        ^{:key form-id} [switch
                         {:id form-id
                          :checked (question :required)
                          :on-change (change-required-handler state question)
                          :style {:margin-right "20px"}
                          :label "Required"}])]])
   
(defn- change-type-handler
  [state question]
  (fn [event]
    (swap! state
           assoc-in
           [:survey :questions (question :id) :question_type_id]
           (-> event .-target .-value))))

(defn question-type-selector
  [state question]
  (let [type-id (question :question_type_id)
        attrs {:aria-label "Select Question Type"
               :on-change (change-type-handler state question)}]
    [:select.form-select.w-25
     (if type-id (assoc attrs :value type-id) attrs)
     (when-not type-id
       [:option "Select Question Type"])
     (for [type (question-type-list @state)]
       [:option
        {:key (question-type-uid question type)
         :value (:id type)}
        (type :name)])]))

(defn- remove-question
  [state question]
  (fn []
    (swap! state assoc-in [:survey :questions (question :id) :_destroy] true)))

(defn question-card
  [state question]
  [:div.card.question.mb-4
   [:div.card-body
    [:div.card-title.d-flex.justify-content-between
     [:div.question-title.w-100.d-flex.me-3
      [text-field
       {:id (question :id)
        :title "Enter question text"
        :class "h5"
        :default-value (question :text)
        :on-change #(swap! state assoc-in [:survey :questions (question :id) :text] (-> % .-target .-value))}]
      (when (question :required) [:span {:title "Required"} "*"])]
     [question-type-selector state question]
     [remove-button {:on-click (remove-question state question)}]]
    [question-card-body state question]]
    [question-card-footer state question]])

(defn survey-questions
  [state]
  [:div.questions
   (let [qs (->> (survey @state :questions) vals (remove :_destroy) (sort-by :display_order))]
     (for [q qs]
       (let [key (str "question-card-" (:id q))]
         ^{:key key} [question-card state q])))])

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

(def new-question-text
  (let [n (atom -1)]
    (fn []
      (swap! n inc)
      (if (zero? @n)
        "New Question"
        (str "New Question (" @n ")")))))

(defn- add-question!
  [state]
  (fn [_e]
    (let [id   (swap! temp-id dec)
          text (new-question-text)]
      (swap! state assoc-in [:survey :questions id] {:id id :text text}))))

(defn- save-survey!
  [state]
  (fn []
    (go
      (let [res (<! (http-request :method :post :url (apply-survey-edits-url (@state :survey)) :error-fn (error-handler state)))
            t   (-> res :body :updated_at)]
        (pp res)
        (swap! state assoc :edits nil :updated_at t)))))

(defn update-survey-field!
  [state field]
  (fn [e]
    (swap! state assoc-in [:survey field] (-> e .-target .-value))))

(defn survey-editor
  [state]
  [:div {:class "container"}
   [:div.mb-3.d-flex.justify-content-between
    [:div
     [:small.me-1.text-muted
      (if (survey-edited? @state)
       (str "Last saved " (time-ago-in-words (@state :updated_at)))
       (str "Up to date. Saved " (time-ago-in-words (@state :updated_at))))]]
    [:small#errors.text-danger
     (if (errors? @state) (str "Error: "(s/join ", " (@state :errors))))]
    [:div
     [:button.btn.btn-sm.btn-primary.me-1
      {:type "button"
       :disabled (not (survey-edited? @state))
       :on-click (save-survey! state)}
      "Save"]]]
   [survey-details {:id (survey @state :id)
                    :name (survey @state :name)
                    :description (survey @state :description)
                    :on-change-description (update-survey-field! state :description)
                    :on-change-name (update-survey-field! state :name)}]
   [:div.mb-3.d-flex.justify-content-end
    [:button.btn.btn-sm.btn-secondary
     {:type "button"
      :on-click (add-question! state)}
     (icon "fa-solid" "plus" "Add Question")]]
   [survey-questions state]])
