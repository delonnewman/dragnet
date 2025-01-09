(ns dragnet.editor.core
  "Core logic for the Editor UI"
  (:require
   [cljs.core.async :refer [<! go]]
   [clojure.spec.alpha :as s]
   [dragnet.common.utils
    :as utils
    :refer [->int ->uuid pp-str echo http-request]
    :include-macros true]))


(def survey-path (utils/path-helper ["/api/v1/editing/surveys" :entity/id]))
(def survey-url (utils/url-helper survey-path))

(def apply-survey-edits-path (utils/path-helper ["/api/v1/editing/surveys" :entity/id "apply"]))
(def apply-survey-edits-url (utils/url-helper apply-survey-edits-path))

(comment
  survey-url
  (survey-url 1)
  )

(defn survey
  [state & key-path]
  (if (empty? key-path)
    (state :survey)
    (get-in state (cons :survey key-path))))


(defn errors
  [state]
  (state :errors))


(defn errors?
  [state]
  (-> state errors seq))


(defn updated-at
  [state]
  (state :updated_at))


(defn survey-edited?
  "Return true if the survey state has edits otherwise return false"
  [state]
  (-> (state :edits) seq))


(defn question-types
  "Return the question types map from the survey state"
  [state]
  (-> state :question-types))


(defn question-type-list
  "Return the list of question types from the survey state"
  [state]
  (-> state :question-types vals))


(defn ex-question-type
  "Return an ex-info exception with a message and data
  regarding a question type look up error."
  [type-id]
  (ex-info (str "couldn't find a question type with id: " type-id)
           {:ex-question-type/id type-id}))


(s/fdef question-type
  :args (s/cat :state map? :type-id uuid?)
  :ret map?)


(defn question-type
  "Return the question type of the question or nil if not present.

  For the editor we can't rely on pulling the slug structurally
  (i.e. (-> q :question/type :question.type/slug)) because the
  question type is updated by it's id."
  [state type-id]
  (echo type-id)
  (if-let [type (get-in state [:question-types type-id])]
    type
    (throw (ex-question-type type-id))))


(defn question-type-id
  "Return the question type id of the question"
  [question]
  (-> question :question/type :entity/id))


(defn question-type-slug
  "Return the question type slug of the question or nil if not present."
  [state question]
  (:question.type/slug (question-type state (question-type-id question))))


(defn question-type-uid
  "Return a universally unique id for a question type.

  When a type is given that type id will be used otherwise the question's
  type id will be used. The type can be specified as a map with an :id key
  or as a scalar value."
  ([question]
   (question-type-uid question (question-type-id question)))
  ([question type]
   (let [id (if (map? type) (type :entity/id) type)]
     (str "question-" (question :entity/id) "-type-" id))))


(defn assoc-question-field
  [state question field value]
  (assoc-in state [:survey :survey/questions (question :entity/id) field] value))


(defn update-question-text!
  [state question]
  (fn [e]
    (swap! state assoc-question-field question :question/text (-> e .-target .-value))))


(defn remove-question
  [state question]
  (assoc-in state [:survey :survey/questions (question :entity/id) :_destroy] true))


(defn update-survey-field
  [state field value]
  (assoc-in state [:survey field] value))


(defn error-handler
  [state]
  (fn [res]
    (println "handling error" (pp-str res))
    (swap! state assoc :errors (res :body))))


(defn save-survey-handler
  [ref]
  (fn []
    (go
      (let [res
            (<! (http-request
                 :method :post
                 :url (apply-survey-edits-url (@ref :survey))
                 :error-fn (error-handler ref)))
            t   (-> res :body :updated_at)]
        (swap! ref assoc :edits nil :updated_at t)))))


(defn update-survey-field-handler
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
  (assoc-in
   state
   [:survey :survey/questions (question :entity/id) :question/options (option :entity/id)]
   option))


(defn assoc-question
  [state question]
  (assoc-in state [:survey :survey/questions (question :entity/id)] question))


(let [temp-id (atom 0)]
  (defn new-option []
    {:id (swap! temp-id dec) :question.option/text (new-option-text)})

  (defn new-question []
    {:id (swap! temp-id dec) :question/text (new-question-text)}))


(defn add-question-handler
  [ref]
  (fn []
    (swap! ref assoc-question (new-question))))


(defn add-option-handler
  [ref question]
  (fn [e]
    (swap! ref assoc-option question (new-option))
    (-> e .-nativeEvent .preventDefault)
    (-> e .-nativeEvent .stopPropagation)))


(defn remove-option
  [state question option]
  (assoc-in
   state
   [:survey :survey/questions (question :entity/id) :question/options (option :entity/id) :_destroy]
   true))


(defn remove-option-handler
  [ref question option]
  (fn [e]
    (swap! ref remove-option question option)
    (-> e .-nativeEvent .preventDefault)
    (-> e .-nativeEvent .stopPropagation)))


(defn remove-question-handler
  [ref question]
  (fn []
    (swap! ref remove-question question)))


(defn assoc-in-option
  [state question option field value]
  (assoc-in
   state
   [:survey :survey/questions (question :entity/id) :question/options (option :entity/id) field]
   value))


(defn make-option-handler
  [field value-fn]
  (fn [ref question option]
    (fn [event]
      (let [value (-> event .-target .-value value-fn)]
        (swap! ref assoc-in-option question option field value)))))


(def update-option-text-handler (make-option-handler :question.option/text identity))
(def update-option-weight-handler (make-option-handler :question.option/weight ->int))


(defn change-setting-handler
  [ref question setting]
  (fn [event]
    (println "change-setting-handler" event)
    (let [checked (-> event .-target .-checked)
          path [:survey :survey/questions (question :entity/id) :question/settings]
          settings (assoc (get-in @ref path {}) setting checked)]
      (println "path" path)
      (println "settings" settings)
      (println "state" (-> @ref :survey))
      (swap! ref assoc-in path settings))))


(defn change-required-handler
  [ref question]
  (fn [event]
    (let [checked (-> event .-target .-checked)]
      (swap!
       ref
       assoc-in
       [:survey :survey/questions (question :entity/id) :question/required]
       checked))))


(defn assoc-question-type-id
  "Associate the type-id with the question"
  [state question type-id]
  (let [type (question-type state type-id)]
    (assoc-in
     state
     [:survey :survey/questions (question :entity/id) :question/type]
     type)))


(s/fdef change-type-handler
  :args (s/cat :ref #(instance? Atom %) :question map?)
  :ret fn?)


(defn change-type-handler
  [ref question]
  (fn [event]
    (let [type-id (-> event .-target .-value)]
      (swap! ref assoc-question-type-id question (->uuid type-id)))))


(defn survey-questions
  [state]
  (->> state
       :survey
       :survey/questions
       vals
       (remove :entity/_destroy)
       (sort-by :question/display-order)))


(defn question-setting
  [question setting & {:keys [default] :or {default false}}]
  (get-in question [:question/settings setting] default))
