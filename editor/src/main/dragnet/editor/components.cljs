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

(defn choice-body
  [question]
  [:div.question-options
   (for [option (:question_options question)]
     [:div.question-option {:key (str "question-" (:id question) "-options-" (:id option))}
      (:text option)])])

(defn text-body [question]
  [:pre (str "text-body" (prn-str question))])

(defn number-body [question]
  [:pre (str "number-body" (prn-str question))])

(defn time-body [question]
  [:pre (str "time-body" (prn-str question))])

(def question-card-bodies
  {"text" text-body
   "choice" choice-body
   "number" number-body
   "time" time-body})

(defn question-card-body
  [question-types question]
  (let [type (question-type-slug question-types question)
        body (question-card-bodies type)]
    (if body
      [body question]
      (throw (js/Error. (str "Invalid question type '" type "'"))))))

(defn change-setting-handler
  [state question setting]
  (fn [event]
    (let [checked (-> event .-target .-checked)
          path [:survey :questions (question :id) :settings]
          settings (assoc (get-in @state path {}) setting checked)]
      (swap! state assoc-in path settings))))

(defn question-card-footer
  [state question]
  [:div.card-footer
   (let [types (question-types state)
         type (types (question :question_type_id))]
     (if type
       [:div.row
        (for [[ident {text :text type :type default :default}] (type :settings)]
          (let [form-id (str "option-" (question :id) "-" (name ident))]
            [:div.col
             [:div.form-check.form-switch
              [:input.form-check-input {:id form-id
                                        :type "checkbox"
                                        :checked (get-in question [:settings ident] default)
                                        :on-change (change-setting-handler state question ident)}]
              [:label.form-check-label {:for form-id} text]]]))]
       (throw (js/Error. (str "Couldn't find question type with id=" (question :question_type_id))))))])
   
(defn change-type-handler
  [state question]
  (fn [event]
    (swap! state
           assoc-in
           [:survey :questions (question :id) :question_type_id]
           (-> event .-target .-value (js/parseInt 10)))))

(defn question-card
  [_ state question]
  [:div.card.question.mb-4
   [:div.card-body
    [:div.card-title.d-flex.justify-content-between
     [:h5 (:text question)]
     [:select.form-select.w-25 {:aria-label "Select Question Type"
                                :on-change (change-type-handler state question)
                                :value (:question_type_id question)}
      (for [type (question-type-list state)]
        [:option {:key (question-type-key (str "question-" (:id question)) type)
                  :value (:id type)}
         (type :name)])]]
    [question-card-body (question-types state) question]]
    [question-card-footer state question]])

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
