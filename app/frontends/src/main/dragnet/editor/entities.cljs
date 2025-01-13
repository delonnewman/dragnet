(ns dragnet.editor.entities
  (:require
   [clojure.spec.alpha :as s]
   [dragnet.common.utils
    :as utils
    :refer [->uuid map-values]]
   [expound.alpha :refer [expound-str]]))


(s/def :number/natural (s/or :positive pos? :zero zero?))

(s/def :entity/id (s/or :int int? :uuid uuid?))
(s/def :entity/type keyword?)
(s/def :entity/_destroy boolean?)

(s/def :user/name string?)
(s/def :user/nickname string?)

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
(s/def :question/type keyword?)


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
  [& {:keys [id text order display_order required settings options question_options type]
      :or {id (random-uuid) required false}}]
  (let [options (or options question_options)
        order (or order display_order 0)]
    (-> {:entity/id (->uuid id)
         :entity/type :question
         :question/text text
         :question/display-order order
         :question/required required
         :question/settings settings
         :question/options (map-values make-question-option options)
         :question/type type}
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

