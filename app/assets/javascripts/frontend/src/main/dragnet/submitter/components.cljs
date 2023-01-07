(ns dragnet.submitter.components
  (:require [dragnet.shared.core :refer
             [long-answer? multiple-answers? include-time? include-date? question-type-slug]]
            [dragnet.submitter.core :refer [submission-path]]))

(defn prompt
  [& {:keys [id label required children]}]
  [:div.card.prompt.mb-4
   [:div.card-body
    [:div.card-title [:h4 label]]
    children]])

(defn text-prompt
  [& {:keys [id value long]}]
  (if long
    [:textarea.form-control {:id id :rows 3} value]
    [:input.form-control {:id id :type "text"}]))

(defn choice-prompt
  [& {:keys [id options value multi]}]
  (let [type (if multi "checkbox" "radio")]
    (for [{text :text opt-id :id} options]
      (let [dom-id (str id "-option-" opt-id)]
        ^{:key dom-id} [:div.form-check
                        [:input.form-check-input {:type type :id dom-id :name id :default-checked (= opt-id value)}]
                        [:label.form-check-label {:for dom-id} text]]))))

(defn time-prompt
  [& {:keys [id value time date]}]
  (let [type (cond (and time date) "datetime-local"
                   time "time"
                   date "date"
                   :else "datetime-local")]
    (println "time-type" type)
    [:input.form-control {:id id :type type}]))

(defn number-prompt
  [& {:keys [id value]}]
  [:input.form-control {:id id :type "number"}])

(def prompt-bodies
  {"text" #(text-prompt :id (:id %) :long (long-answer? %))
   "choice" #(choice-prompt :id (:id %) :options (->> % :question_options vals) :multi (multiple-answers? %))
   "time" #(time-prompt :id (:id %) :time (include-time? %) :date (include-date? %))
   "number" #(number-prompt :id (:id %))})

(defn prompt-body
  [q]
  (if-let [body (prompt-bodies (-> q :question_type :slug))]
    (body q)))

(defn reply-submitter
  [reply-id state]
  (let [survey (-> state :survey)]
    [:div.reply-submitter
     [:h1 (survey :name)]
     [:form {:action (submission-path reply-id) :data-method "patch"}
      (for [question (->> survey :questions vals)]
        ^{:key (question :id)} [prompt :label (question :text)
                                      :children (prompt-body question)])
      [:button.btn.btn-primary {:type "submit"} "Submit"]]]))
