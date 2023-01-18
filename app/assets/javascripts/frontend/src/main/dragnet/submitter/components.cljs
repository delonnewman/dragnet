(ns dragnet.submitter.components
  (:require
   [dragnet.shared.core :refer [long-answer? multiple-answers? include-time? include-date? question-type-slug]]
   [dragnet.submitter.core :refer [submission-path answer-id answer-form-name]]))

(defn prompt
  [& {:keys [id label required children]}]
  [:div.card.prompt.mb-4
   [:div.card-body
    [:div.card-title [:h4 label]]
    children]])

(defn text-prompt
  [& {:keys [id name value long]}]
  (if long
    [:textarea.form-control {:id id :name name :rows 3} value]
    [:input.form-control {:id id :name name :type "text"}]))

(defn choice-prompt
  [& {:keys [id name options value multi]}]
  (let [type (if multi "checkbox" "radio")]
    (for [{text :text opt-id :id} options]
      (let [dom-id (str id "-option-" opt-id)]
        ^{:key dom-id} [:div.form-check
                        [:input.form-check-input {:type type :id dom-id :name name :value opt-id :default-checked (= opt-id value)}]
                        [:label.form-check-label {:for dom-id} text]]))))

(defn time-prompt
  [& {:keys [id name value time date]}]
  (let [type (cond (and time date) "datetime-local"
                   time "time"
                   date "date"
                   :else "datetime-local")]
    (println "time-type" type)
    [:input.form-control {:id id :type type :name name}]))

(defn number-prompt
  [& {:keys [id name value]}]
  [:input.form-control {:id id :type "number" :name name}])

(def prompt-bodies
  {"text" #(text-prompt :id (answer-id %) :name (answer-form-name (:id %) :value) :long (long-answer? %))
   "choice" #(choice-prompt :id (answer-id %) :name (answer-form-name (:id %) :value) :options (->> % :question_options vals) :multi (multiple-answers? %))
   "time" #(time-prompt :id (answer-id %) :name (answer-form-name (:id %) :value) :time (include-time? %) :date (include-date? %))
   "number" #(number-prompt :id (answer-id %) :name (answer-form-name (:id %) :value))})

(defn prompt-body
  [reply-id survey-id q]
  (if-let [body (prompt-bodies (-> q :question_type :slug))]
    [:div
     [:input {:type "hidden" :name (answer-form-name (:id q) :question_id) :value (:id q)}]
     [:input {:type "hidden" :name (answer-form-name (:id q) :reply_id) :value reply-id}]
     [:input {:type "hidden" :name (answer-form-name (:id q) :survey_id) :value survey-id}]
     [:input {:type "hidden" :name (answer-form-name (:id q) :question_type_id) :value (:question_type_id q)}]
     (body q)]))

(defn reply-submitter
  [reply-id state]
  (let [survey (-> state :survey)]
    [:div.reply-submitter
     [:h1 (survey :name)]
     [:form {:action (submission-path reply-id) :method "post"}
      (for [question (->> survey :questions vals)]
        ^{:key (question :id)} [prompt :label (question :text) :children (prompt-body reply-id (survey :id) question)])
      [:button.btn.btn-primary {:type "submit"} "Submit"]]]))
