(ns dragnet.editor.components
  (:require [cljs.pprint :as pp]
            [cljs-uuid-utils.core :as uuid]))

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

(defn- question-settings-predicate
  [setting]
  (fn [question]
    (get-in question [:settings setting] false)))

(def long-answer? (question-settings-predicate :long_answer))
(def multiple-answers? (question-settings-predicate :multiple_answers))
(def include-date? (question-settings-predicate :include_date))
(def include-time? (question-settings-predicate :include_time))

(defn include-date-and-time?
  [q]
  (and (include-date? q) (include-time? q)))

(defn- option-updater
  [field value-fn]
  (fn [state question option]
    (fn [event]
      (let [value (-> event .-target .-value value-fn)]
        (swap! state assoc-in [:survey :questions (question :id) :question_options (option :id) field] value)))))

(def ^:private option-text-updater (option-updater :text identity))
(def ^:private option-weight-updater (option-updater :weight #(js/parseInt % 10)))

(defn- remove-option
  [state question option]
  (fn [e]
    (let [key-path [:survey :questions (question :id) :question_options]
          options (dissoc (get-in @state key-path {}) (option :id))]
      (swap! state assoc-in key-path options))
    (-> e .-nativeEvent .preventDefault)
    (-> e .-nativeEvent .stopPropagation)))

(defn- choice-option
  [state question option]
  (let [dom-id (str "question-option-" (question :id) "-" (option :id))]
    [:div.question-option.mb-2.d-flex.align-items-center
     [:div.me-1
      (if (multiple-answers? question)
        [:input {:type "checkbox" :disabled true}]
        [:input {:type "radio" :disabled true}])]
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
     [:div
      [:a.btn.btn-link {:href "#" :on-click (remove-option state question option)} "Remove"]]]))

; TODO: move to global state atom
(def option-temp-ids (atom {}))

(defn- add-option
  [state question]
  (fn [e]
    (let [id (-> (get @option-temp-ids (question :id) 0) dec)]
      (swap! option-temp-ids assoc (question :id) (dec id))
      (swap! state assoc-in [:survey :questions (question :id) :question_options id] {:id id}))
    (-> e .-nativeEvent .preventDefault)
    (-> e .-nativeEvent .stopPropagation)))

(defn choice-body
  [state question]
  [:div
   [:div.question-options
    (for [option (vals (:question_options question))]
      (let [dom-id (str "question-" (:id question) "-options-" (option :id))]
        ^{:key dom-id} [choice-option state question option]))]
   [:a.btn.btn-link {:href "#" :on-click (add-option state question)} "Add Option"]])

(defn text-body
  [state question]
  (let [form-id (str "question-" (question :id))]
    (if (long-answer? question)
      [:textarea.form-control {:id form-id :rows 3}]
      [:input.form-control {:id form-id :type "text"}])))

(defn number-body
  [state question]
  (let [form-id (str "question" (question :id))]
    [:input.form-control {:id form-id :type "number"}]))

(defn time-body
  [state question]
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
  (let [type (question-type-slug (question-types state) question)
        body (question-card-bodies type)]
    (if body
      [body state question])))

(defn- change-setting-handler
  [state question setting]
  (fn [event]
    (let [checked (-> event .-target .-checked)
          path [:survey :questions (question :id) :settings]
          settings (assoc (get-in @state path {}) setting checked)]
      (swap! state assoc-in path settings))))

(defn- change-required-handler
  [state question]
  (fn [event]
    (let [checked (-> event .-target .-checked)]
      (swap! state assoc-in [:survey :questions (question :id) :required] checked))))

(defn switch
  [& {:keys [id checked on-change label style class-name]}]
  [:div.form-check.form-switch {:style style :class-name class-name}
   [:input.form-check-input {:id id :type "checkbox" :on-change on-change :checked checked}]
   [:label.form-check-label {:for id} label]])

(defn question-card-footer
  [state question]
  [:div.card-footer
   [:div.d-flex.justify-content-end
    (if-let [type ((question-types state) (question :question_type_id))]
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
           (-> event .-target .-value (js/parseInt 10)))))

(defn question-type-selector
  [state question]
  (let [type-id (question :question_type_id)
        attrs {:aria-label "Select Question Type"
               :on-change (change-type-handler state question)}]
    [:select.form-select.w-25
     (if type-id (assoc attrs :value type-id) attrs)
     (if-not type-id
       [:option "Select Question Type"])
     (for [type (question-type-list state)]
       [:option
        {:key (question-type-key (str "question-" (:id question)) type)
         :value (:id type)}
        (type :name)])]))

(defn resizing-text-field
  [& {:keys [id class style default-value on-change]}]
  [:input.resizing-text-field.w-100.border-bottom
   {:class class
    :default-value default-value
    :type "text"
    :on-blur on-change
    :style (merge style {:border "none"})}])

(defn- remove-question
  [state question]
  (fn []
    (if-let [questions (get-in @state [:survey :questions])]
      (swap! state assoc-in [:survey :questions] (dissoc questions (question :id))))))

(defn question-card
  [state question]
  [:div.card.question.mb-4
   [:div.card-body
    [:div.card-title.d-flex.justify-content-between
     [:div.question-title.w-100.d-flex.me-3
      [resizing-text-field
       {:id (question :id)
        :class "h5"
        :default-value (question :text)
        :on-change #(swap! state assoc-in [:survey :questions (question :id) :text] (-> % .-target .-value))}]
      (if (question :required) [:span {:title "Required"} "*"])]
     [question-type-selector state question]
     [:a.btn.btn-link {:href "#" :on-click (remove-question state question)} "Remove"]]
    [question-card-body state question]]
    [question-card-footer state question]])

(defn survey-questions
  [state]
  [:div.questions
   (let [qs (->> (survey state :questions) vals (sort-by :display_order))]
     (for [q qs] ^{:key (str "question-card-" (:id q))} [question-card state q]))])

(defn update-survey-field
  [state field]
  (fn [e]
    (swap! state assoc-in [:survey field] (-> e .-target .-value))))

(defn survey-details
  [state]
  [:div.card.survey-details.mb-5
   [:div.card-body
    [:div.card-title.pb-3
      [resizing-text-field
       {:id (survey state :id)
        :class "h3"
        :default-value (survey state :name)
        :on-change (update-survey-field state :name)}]]
    [:textarea.form-control
     {:rows 2
      :placeholder "Description"
      :on-change (update-survey-field state :description)}
     (survey state :description)]]])

(defn- add-question
  [state]
  (fn [e]
    (let [id (-> (uuid/make-random-uuid) uuid/uuid-string)]
      (swap! state assoc-in [:survey :questions id] {:id id}))))

(defn survey-editor
  [state]
  [:div {:class "container"}
   [survey-details state]
   [:div.mb-3.d-flex.justify-content-end
    [:button.btn.btn-primary {:type "button" :on-click (add-question state)} "Add Question"]]
   [survey-questions state]])
