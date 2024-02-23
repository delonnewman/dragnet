(ns dragnet.entities.survey
  (:require
    [clojure.spec.alpha :as s]
    [dragnet.shared.utils :as utils :refer [->uuid echo] :include-macros true]
    [expound.alpha :refer [expound-str]]))


(s/def :number/natural (s/or :positive pos? :zero zero?))

(s/def :entity/id (s/or :int int? :uuid uuid?))
(s/def :entity/type keyword?)
(s/def :entity/_destroy boolean?)

(s/def :user/name string?)
(s/def :user/nickname string?)

(s/def :question.type/name string?)
(s/def :question.type/slug string?)
(s/def :question.type/entity (s/keys :req [:entity/id :entity/type :question.type/name :question.type/slug]))
(s/def :question.type/settings (s/nilable map?))

(s/def :question.option/text string?)
(s/def :question.option/weight integer?)


(s/def :question.option/entity
  (s/keys :req [:entity/type :question.option/text :question.option/weight]
          :opt [:entity/id :entity/_destroy]))


(s/def :question/id uuid?)
(s/def :question/text string?)
(s/def :question/display-order :number/natural)
(s/def :question/required boolean?)
(s/def :question/settings (s/nilable map?))
(s/def :question/options (s/map-of :entity/id :question.option/entity))
(s/def :question/type :question.type/entity)


(s/def :question/entity
  (s/keys :req [:entity/type :question/text :question/type]
          :opt [:entity/id :question/display-order :question/required :question/settings :question/options :entity/_destroy]))


(s/def :survey/id uuid?)
(s/def :survey/name string?)
(s/def :survey/description string?)
(s/def :survey/updated-at inst?)
(s/def :survey/author (s/keys :req [:entity/id :entity/type :user/name :user/nickname]))
(s/def :survey/questions (s/map-of :entity/id :question/entity))


(s/def :survey/entity
  (s/keys :req [:entity/id :entity/type :survey/name :survey/updated-at :survey/author]
          :opt [:survey/description :survey/questions]))


(defn- entity-validator
  [spec]
  (fn [data]
    (if-let [ex-data (s/explain-data spec data)]
      (throw (ex-info (expound-str spec data) ex-data))
      data)))


(def validate-author! (entity-validator :survey/author))
(def validate-survey! (entity-validator :survey/entity))
(def validate-question! (entity-validator :question/entity))
(def validate-question-type! (entity-validator :question.type/entity))
(def validate-question-option! (entity-validator :question.option/entity))


(defn valid-survey?
  [data]
  (s/valid? :survey/entity data))


(defn valid-question?
  [data]
  (s/valid? :question/entity data))


(defn valid-question-option?
  [data]
  (s/valid? :question.option/entity data))


(defn make-question-type
  [& {:keys [id name slug settings :as all]}]
  (-> {:entity/id (->uuid id)
       :entity/type :question-type
       :question.type/name name
       :question.type/slug slug
       :question.type/settings settings}
      ((fn [x] (prn x) x))
      validate-question-type!))


(defn make-question-types
  [types]
  (reduce (fn [m [id type]]
            (assoc m (->uuid id) (make-question-type type))) {} types))


(defn make-question-option
  [& {:keys [id text weight] :or {weight 0}}]
  (-> {:entity/id id
       :entity/type :question-option
       :question.option/text text
       :question.option/weight weight}
      validate-question-option!))


(defn make-question
  [& {:keys [id text display_order required settings question_options question_type :as all]
      :or {id (random-uuid) display_order 0 required false}}]
  (-> {:entity/id (->uuid id)
       :entity/type :question
       :question/text text
       :question/display-order display_order
       :question/required required
       :question/settings settings
       :question/options (->> question_options (map #(vector (% 0) (make-question-option (% 1)))) (into {}))
       :question/type (make-question-type question_type)}
      validate-question!))


(defn make-author
  [& {:keys [id name nickname]}]
  (let [user {:entity/type :user}
        user (if id (assoc user :entity/id (->uuid id)) user)
        user (if name (assoc user :user/name name) user)
        user (if nickname (assoc user :user/nickname nickname) user)]
    (println user)
    (validate-author! user)))


(defn make-survey
  [& {:keys [id name description author questions updated_at]
      :or {id (random-uuid) updated_at (js/Date.)}}]
  (echo questions)
  (let [survey
        {:entity/id (->uuid id)
         :entity/type :survey
         :survey/name name
         :survey/author (make-author author)
         :survey/questions (->> questions (map #(vector (->uuid (% 0)) (make-question (% 1)))) (into {}))
         :survey/updated-at updated_at}
        survey (if description (assoc survey :survey/description description) survey)]
    (validate-survey! survey)))


(defn survey-questions
  [survey]
  (:survey/questions survey))


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
