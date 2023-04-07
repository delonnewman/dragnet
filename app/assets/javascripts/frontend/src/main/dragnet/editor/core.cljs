(ns dragnet.editor.core
  "Core logic for the Editor UI"
  (:require
    [clojure.spec.alpha :as s]
    [cljs.core.async :refer [<! go]]
    [dragnet.shared.utils :as utils :refer [->int pp pp-str http-request] :include-macros true]))

(def survey-path (utils/path-helper ["/api/v1/editing/surveys" :id]))
(def survey-url (utils/url-helper survey-path))

(def apply-survey-edits-path (utils/path-helper ["/api/v1/editing/surveys" :id "apply"]))
(def apply-survey-edits-url (utils/url-helper apply-survey-edits-path))

(defn survey
  [state & key-path]
  (if (empty? key-path)
    (state :survey)
    (get-in state (cons :survey key-path))))

(defn errors?
  [state] (-> (state :errors) seq))

(defn survey-edited?
  "Return true if the survey state has edits otherwise return false"
  [state] (-> (state :edits) seq))

(defn question-types
  "Return the question types map from the survey state"
  [state]
  (-> state :question_types))

(defn question-type-list
  "Return the list of question types from the survey state"
  [state]
  (-> state :question_types vals))

(defn question-type
  "Return the question type of the question or nil if not present.

  For the editor we can't rely on pulling the slug structurally
  (i.e. (-> q :question_type :slug)) because the question type is
  updated by it's id."
  [state question]
  (let [types (question-types state)]
    (-> question :question_type_id types)))

(defn question-type-slug
  "Return the question type slug of the question or nil if not present."
  [state question]
  (:slug (question-type state question)))

(defn question-type-id
  "Return the question type id of the question"
  [question]
  (-> question :question_type_id))

(defn question-type-uid
  "Return a universally unique id for a question type.

  When a type is given that type id will be used otherwise the question's
  type id will be used. The type can be specified as a map with an :id key
  or as a scalar value."
  ([question]
   (question-type-uid question (question-type-id question)))
  ([question type]
   (let [id (if (map? type) (type :id) type)]
     (str "question-" (question :id) "-type-" id))))

(defn assoc-question-field
  [state question field value]
  (assoc-in state [:survey :questions (question :id) field] value))

(defn update-question-text!
  [state question]
  (fn [e]
    (swap! assoc-question-field state question :text (-> e .-target .-value))))

(defn remove-question
  [state question]
  (assoc-in state [:survey :questions (question :id) :_destroy] true))

(defn update-survey-field
  [state field value]
  (assoc-in state [:survey field] value))

(defn reset-edit-state
  [state])

(defn error-handler
  [state]
  (fn [res]
    (println "handling error" (pp-str res))
    (swap! state assoc :errors (res :body))))

(defn save-survey!
  [ref]
  (fn []
    (go
     (let [res (<! (http-request :method :post
                                 :url (apply-survey-edits-url (@ref :survey))
                                 :error-fn (error-handler ref)))
           t   (-> res :body :updated_at)]
       (pp res)
       (swap! ref assoc :edits nil :updated_at t)))))

(defn update-survey-field!
  [ref field]
  (fn [e]
    (swap! ref update-survey-field field (-> e .-target .-value))))

(defn new-text-generator
  [text-template]
  (let [n (atom -1)]
    (fn []
      (swap! n inc)
      (if (zero? @n)
        text-template
        (str text-template " (" @n ")")))))

(def new-question-text (new-text-generator "New Question"))
(def new-option-text (new-text-generator "New Option"))

(defn assoc-option
  [state question option]
  (assoc-in state [:survey :questions (question :id) :question_options (option :id)] option))

(defn assoc-question
  [state question]
  (assoc-in state [:survey :questions (question :id)] question))

(let [temp-id (atom 0)]
  (defn new-option []
    {:id (swap! temp-id dec) :text (new-option-text)})

  (defn new-question []
    {:id (swap! temp-id dec) :text (new-question-text)}))

(defn add-question!
  [ref]
  (fn []
    (swap! ref assoc-question (new-question))))

(defn add-option!
  [ref question]
  (fn [e]
    (swap! ref assoc-option question (new-option))
    (-> e .-nativeEvent .preventDefault)
    (-> e .-nativeEvent .stopPropagation)))

(defn remove-option
  [state question option]
  (assoc-in state [:survey :questions (question :id) :question_options (option :id) :_destroy] true))

(defn remove-option!
  [ref question option]
  (fn [e]
    (swap! ref remove-option question option)
    (-> e .-nativeEvent .preventDefault)
    (-> e .-nativeEvent .stopPropagation)))

(defn remove-question!
  [ref question]
  (fn []
    (swap! ref remove-question question)))

(defn assoc-in-option
  [state question option field value]
  (assoc-in state [:survey :questions (question :id) :question_options (option :id) field] value))

(defn option-updater
  [field value-fn]
  (fn [ref question option]
    (fn [event]
      (let [value (-> event .-target .-value value-fn)]
        (swap! ref assoc-in-option question option field value)))))

(def update-option-text! (option-updater :text identity))
(def update-option-weight! (option-updater :weight ->int))

(defn change-setting!
  [ref question setting]
  (fn [event]
    (println "change-setting-handler" event)
    (let [checked (-> event .-target .-checked)
          path [:survey :questions (question :id) :settings]
          settings (assoc (get-in @ref path {}) setting checked)]
      (println "path" path)
      (println "settings" settings)
      (println "state" (-> @ref :survey))
      (swap! ref assoc-in path settings))))

(defn change-required!
  [ref question]
  (fn [event]
    (let [checked (-> event .-target .-checked)]
      (swap! ref assoc-in [:survey :questions (question :id) :required] checked))))

(defn assoc-question-type-id
  "Associate the type-id with the question"
  [state question type-id]
  (assoc-in state [:survey :questions (question :id) :question_type_id] type-id))

(s/fdef change-type!
  :args (s/cat :ref #(instance? Atom %) :question map?)
  :ret fn?)

(defn change-type!
  [ref question]
  (fn [event]
    (let [type-id (-> event .-target .-value)]
      (swap! ref assoc-question-type-id question type-id))))
