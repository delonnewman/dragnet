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
        (println "option-updater" field (question :id) (option :id) value)
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
      [body state question]
      (throw (js/Error. (str "Invalid question type " (prn-str type)))))))

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
   (let [type ((question-types state) (question :question_type_id))]
     (when-not type
       (throw (js/Error. (str "Couldn't find question type with id=" (prn-str (question :question_type_id))))))
     [:div.d-flex.justify-content-end
      (for [[ident {text :text type :type default :default}] (type :settings)]
        (let [form-id (str "option-" (question :id) "-" (name ident))]
          ^{:key form-id} [switch
                           {:id form-id
                            :checked (get-in question [:settings ident] default)
                            :on-change (change-setting-handler state question ident)
                            :style {:margin-right "20px"}
                            :label text}]))
      (let [form-id (str "option-" (question :id) "-required")]
        ^{:key form-id} [switch
                         {:id form-id
                          :checked (question :required)
                          :on-change (change-required-handler state question)
                          :style {:margin-right "20px"}
                          :label "Required"}])])])
   
(defn- change-type-handler
  [state question]
  (fn [event]
    (swap! state
           assoc-in
           [:survey :questions (question :id) :question_type_id]
           (-> event .-target .-value (js/parseInt 10)))))

(defn question-type-selector
  [state question]
  [:select.form-select.w-25
   {:aria-label "Select Question Type"
    :on-change (change-type-handler state question)
    :value (:question_type_id question)}
   (for [type (question-type-list state)]
     [:option
      {:key (question-type-key (str "question-" (:id question)) type)
       :value (:id type)}
      (type :name)])])

(defn str-length->px
  [s]
  (-> s
      .-length
      (* 10.3)
      Math/round
      (str "px")))

; TODO: rewrite to use a channel for input
(defn- resize-question-title
  [state question]
  (fn [e]
    (let [sizes (get @state :question-title-sizes {})
          value (-> e .-target .-value)
          length (str-length->px value)]
      (swap! state assoc :question-title-sizes (assoc sizes (question :id) length)))))

(defn question-card
  [state question]
  [:div.card.question.mb-4
   [:div.card-body
    [:div.card-title.d-flex.justify-content-between
     [:div.question-title.w-100.d-flex.me-3
      [:span
       [:input.h5.question-title-input
        {:default-value (question :text)
         :on-key-up (resize-question-title state question)
         :style {:border "none" :width (get-in @state [:question-title-sizes (question :id)] (str-length->px (question :text)))}}]]
      (if (question :required) [:span {:title "Required"} "*"])]
     [question-type-selector state question]]
    [question-card-body state question]]
    [question-card-footer state question]])

(defn survey-questions
  [state]
  [:div.questions
   (let [qs (->> (survey state :questions) vals (sort-by :display_order))]
     (for [q qs] ^{:key (str "question-card-" (:id q))} [question-card state q]))])

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
