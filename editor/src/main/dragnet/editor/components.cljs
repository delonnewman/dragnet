(ns dragnet.editor.components)

(def question-types [{:id 1 :name "Short Answer" :slug "short-answer"}
                     {:id 2 :name "Paragraph" :slug "paragraph"}
                     {:id 3 :name "Multiple Choice" :slug "multiple-choice"}
                     {:id 4 :name "Checkboxes" :slug "checkboxes"}])

(defn question-type-id
  [question]
  (get-in question [:question_type :id]))

(defn question-type-slug
  [question]
  (get-in question [:question_type :slug]))

(defn question-type-key
  [ns type]
  (str ns "-type-" (:id type)))

(defn question-options-body
  [question]
  (println "options-body" (:question_options question))
  [:div.question-options
   (for [option (:question_options question)]
     [:div.question-option {:key (str "question-" (:id question) "-options-" (:id option))}
      (:text option)]
     )])

(defn short-answer-body [question]
  [:pre (str "short-answer-body" (prn-str question))])

(defn paragraph-body [question]
  [:pre (str "paragraph-body" (prn-str question))])

(defn question-card-body
  [question]
  (case (question-type-slug question)
    "short-answer" [short-answer-body question]
    "paragraph" [paragraph-body question]
    "multiple-choice" [question-options-body question]
    "checkboxes" [question-options-body question]
    [question-options-body question]))

(defn question-card
  [survey question]
  [:div.card.question.mb-4 {:key (str "question-card-" (:id question))}
   [:div.card-body
    [:div.card-title.d-flex.justify-content-between
     [:h5 (:text question)]
     [:select.form-select.w-25 {:aria-label "Select Question Type" :on-change #(js/console.log %)}
      (for [type question-types]
        [:option {:key (question-type-key (str "question-" (:id question)) type)
                  :value (:id type)
                  :selected (= (:id type) (question-type-id question))}
         (:name type)])]]
      [question-card-body question]]])

(defn survey-questions
  [survey]
  [:div.questions
   (for [question (->> @survey :questions (sort-by :display_order))]
     [question-card survey question])])

(defn survey-details
  [survey]
  [:div.card.survey-details.mb-5
   [:div.card-body
    [:div.card-title
     [:h3 (:name @survey)]]
    [:textarea.form-control {:rows 3 :placeholder "Description" :name "survey[description]"}
     (:description @survey)]]])

(defn survey-editor
  [survey]
  [:div {:class "container"}
   [survey-details survey]
   [survey-questions survey]])
