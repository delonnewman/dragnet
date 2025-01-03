(ns dragnet.editor.entities
  (:require
   [clojure.spec.alpha :as s]
   [dragnet.common.utils
    :as utils
    :refer [->uuid map-values]
    :include-macros true]
   [expound.alpha :refer [expound-str]]))


(s/def :number/natural (s/or :positive pos? :zero zero?))

(s/def :entity/id (s/or :int int? :uuid uuid?))
(s/def :entity/type keyword?)
(s/def :entity/_destroy boolean?)

(s/def :user/name string?)
(s/def :user/nickname string?)

(s/def :question.type/name string?)
(s/def :question.type/slug string?)
(s/def :question.type/settings (s/nilable map?))
(s/def :question.type/entity (s/keys :req [:entity/id :entity/type :question.type/name :question.type/slug]))

(s/def :question.option/text string?)
(s/def :question.option/weight integer?)
(s/def :question.option/entity
  (s/keys :req [:entity/type :question.option/text :question.option/weight]
          :opt [:entity/id :entity/_destroy]))


(s/def :question/text string?)
(s/def :question/display-order :number/natural)
(s/def :question/required boolean?)
(s/def :question/settings (s/nilable map?))
(s/def :question/options (s/map-of :entity/id :question.option/entity))
(s/def :question/type :question.type/entity)


(s/def :survey/name string?)
(s/def :survey/description string?)
(s/def :survey/updated-at inst?)
(s/def :survey/questions (s/map-of :entity/id :question/entity))


(defn- entity-validator
  [spec]
  (fn [data]
    (if-let [ex-data (s/explain-data spec data)]
      (throw (ex-info (expound-str spec data) ex-data))
      data)))


(def ^{:doc "Validate a type map. Throw an exception if the map is invalid otherwise return the map."}
  validate-question-type! (entity-validator :question.type/entity))

(defn make-question-type
  "Constuct a valid type map or throw an exception.

  Valid keys are: :id, :name, :slug and :settings.

  Only :name and :slug are required."
  [& {:keys [id name slug settings]}]
  (-> {:entity/id (->uuid id)
       :entity/type :question-type
       :question.type/name name
       :question.type/slug slug
       :question.type/settings settings}
      validate-question-type!))


(defn make-question-types
  "Construct a map of type maps with their reified UUIDs as keys."
  [types]
  (reduce (fn [m [id type]]
            (assoc m (->uuid id) (make-question-type type))) {} types))


(def ^{:doc "Validate an option map. Thow an exception if the map is invalid otherwise return the map."}
  validate-question-option! (entity-validator :question.option/entity))

(defn make-question-option
  [& {:keys [id text weight] :or {weight 0}}]
  (-> {:entity/id id
       :entity/type :question-option
       :question.option/text text
       :question.option/weight weight}
      validate-question-option!))


(s/def :question/entity
  (s/keys :req [:entity/type :question/text :question/type]
          :opt [:entity/id :question/display-order :question/required :question/settings :question/options :entity/_destroy]))

(def ^{:doc "Validate a question map. Throw an exception if the map is invalid otherwise return the map."}
  validate-question! (entity-validator :question/entity))

(defn make-question
  "Constuct a valid question map or throw an exception.

  Valid keys are: :id, :text, :order (also :display_order), :required,
  :settings, :options (also :question_options), :type (also :question_type).

  Only :text and :type are required."
  [& {:keys [id text order display_order required settings options question_options type question_type]
      :or {id (random-uuid) required false}}]
  (let [options (or options question_options)
        order (or order display_order 0)
        type (or type question_type)]
    (-> {:entity/id (->uuid id)
         :entity/type :question
         :question/text text
         :question/display-order order
         :question/required required
         :question/settings settings
         :question/options (map-values make-question-option options)
         :question/type (make-question-type type)}
        validate-question!)))


(s/def :survey/author (s/keys :req [:entity/id :entity/type :user/name :user/nickname]))

(def validate-author! (entity-validator :survey/author))

(defn make-author
  "Construct a valid author map or throw an exception.

  Valid keys are: :id, :name, :nickname. Only :name, and :nickname are required."
  [& {:keys [id name nickname]}]
  (let [user {:entity/type :user}
        user (if id (assoc user :entity/id (->uuid id)) user)
        user (if name (assoc user :user/name name) user)
        user (if nickname (assoc user :user/nickname nickname) user)]
    (validate-author! user)))


(s/def :survey/entity
  (s/keys :req [:entity/id :entity/type :survey/name :survey/updated-at :survey/author]
          :opt [:survey/description :survey/questions]))

(def ^{:doc "Validate a survey map. Throw an exception if the map is invalid otherwise return the map."}
  validate-survey! (entity-validator :survey/entity))

(defn make-survey
  "Constuct a valid survey map or throw an exception.

  Valid keys are: :id, :name, :description, :author, :questions, :updated-at (also :update_at).

  Only :name and :author are required."
  [& {:keys [id name description author questions updated-at updated_at]
      :or {id (random-uuid)}}]
  (let [updated-at (or updated-at updated_at (js/Date.))
        survey
        {:entity/id (->uuid id)
         :entity/type :survey
         :survey/name name
         :survey/author (make-author author)
         :survey/questions (->> questions (map #(vector (->uuid (% 0)) (make-question (% 1)))) (into {}))
         :survey/updated-at updated-at}
        survey (if description (assoc survey :survey/description description) survey)]
    (validate-survey! survey)))


(defn options->update
  [[id option]]
  [id
   {:id id
    :text (:question.option/text option)
    :weight (:question.option/weight option)
    :_destroy (:entity/_destroy option)}])


(defn question-type->update
  [type]
  {:id (str (type :entity/id))
   :name (type :question.type/name)
   :slug (type :question.type/slug)
   :settings (type :question.type/settings)})


(defn question->update
  [[id question]]
  [(str id)
   {:id (str id)
    :text (:question/text question)
    :display_order (:question/display-order question)
    :required (:question/required question)
    :settings (:question/settings question)
    :question_type (question-type->update (:question/type question))
    :question_options (->> question :question/options (map options->update) (into {}))
    :_destroy (:entity/_destroy question)}])


(defn user->update
  [user]
  {:id (:entity/id user)
   :name (:user/name user)
   :nickname (:user/nickname user)})


(defn survey->update
  [survey]
  {:id (str (:entity/id survey))
   :name (:survey/name survey)
   :author_id (get-in survey [:survey/author :entity/id])
   :author (user->update (:survey/author survey))
   :updated_at (:survey/updated-at survey)
   :description (:survey/description survey)
   :questions (->> survey :survey/questions (map question->update) (into {}))})
