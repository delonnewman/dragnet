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
  [state question]
  [:div.question-options
   (for [option (:question_options question)]
     [:div.question-option {:key (str "question-" (:id question) "-options-" (:id option))}
      (:text option)])])

(defn long-answer?
  [question]
  (get-in question [:settings :long_answer] false))

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
  [:pre (str "time-body" (prn-str question))])

(def question-card-bodies
  {"text" text-body
   "choice" choice-body
   "number" number-body
   "time" time-body})

(defn question-card-body
  [state question]
  (let [type (question-type-slug (question-types state) question)
        body (question-card-bodies type)]
    (if body
      [body state question]
      (throw (js/Error. (str "Invalid question type " (prn-str type)))))))

(defn change-setting-handler
  [state question setting]
  (fn [event]
    (let [checked (-> event .-target .-checked)
          path [:survey :questions (question :id) :settings]
          settings (assoc (get-in @state path {}) setting checked)]
      (swap! state assoc-in path settings))))

(defn change-required-handler
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
     [:div.d-flex
      (let [form-id (str "option-" (question :id) "-required")]
        ^{:key form-id} [switch {:id form-id
                                 :checked (question :required)
                                 :on-change (change-required-handler state question)
                                 :style {:margin-right "20px"}
                                 :label "Required"}])
      (for [[ident {text :text type :type default :default}] (type :settings)]
        (let [form-id (str "option-" (question :id) "-" (name ident))]
          ^{:key form-id} [switch {:id form-id
                                   :checked (get-in question [:settings ident] default)
                                   :on-change (change-setting-handler state question ident)
                                   :style {:margin-right "20px"}
                                   :label text}]))])])
   
(defn change-type-handler
  [state question]
  (fn [event]
    (swap! state
           assoc-in
           [:survey :questions (question :id) :question_type_id]
           (-> event .-target .-value (js/parseInt 10)))))

(defn question-card
  [state question]
  [:div.card.question.mb-4
   [:div.card-body
    [:div.card-title.d-flex.justify-content-between
     [:h5 (:text question) (if (question :required) [:span {:title "Required"} "*"])]
     [:select.form-select.w-25 {:aria-label "Select Question Type"
                                :on-change (change-type-handler state question)
                                :value (:question_type_id question)}
      (for [type (question-type-list state)]
        [:option {:key (question-type-key (str "question-" (:id question)) type)
                  :value (:id type)}
         (type :name)])]]
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
