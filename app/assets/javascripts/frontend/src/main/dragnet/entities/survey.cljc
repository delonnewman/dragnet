(ns dragnet.entities.survey
  (:require
    [clojure.spec.alpha :as s]
    [dragnet.shared.utils :refer [->uuid]]))

(s/def :number/natural (s/or :positive pos? :zero zero?))

(s/def :entity/id (s/or :int int? :uuid uuid?))

(s/def :user/name string?)
(s/def :user/nickname string?)

(s/def :question.type/name string?)
(s/def :question.type/slug string?)
(s/def :question.type/entity (s/keys :req [:entity/id :question.type/name :question.type/slug]))

(s/def :question.option/text string?)
(s/def :question.option/weight integer?)
(s/def :question.option/entity
  (s/keys :req [:question.option/text :question.option/weight]
          :opt [:entity/id]))

(s/def :question/id uuid?)
(s/def :question/text string?)
(s/def :question/display-order :number/natural)
(s/def :question/required boolean?)
(s/def :question/settings (s/nilable map?))
(s/def :question/options (s/map-of :entity/id :question.option/entity))
(s/def :question/type :question.type/entity)
(s/def :question/entity
  (s/keys :req [:question/text :question/type]
          :opt [:entity/id :question/display-order :question/required :question/settings :question/options]))

(s/def :survey/id uuid?)
(s/def :survey/name string?)
(s/def :survey/description string?)
(s/def :survey/updated-at inst?)
(s/def :survey/author (s/keys :req [:entity/id :user/name :user/nickname]))
(s/def :survey/questions (s/map-of :entity/id :question/entity))
(s/def :survey/entity (s/keys :req [:entity/id :survey/name :survey/updated-at :survey/author]
                              :opt [:survey/description :survey/questions]))

(defn valid-survey?
  [data] (s/valid? :survey/entity data))

(defn validate-entity!
  [spec data & {:keys [error-message]}]
  (if-let [ex-data (s/explain-data spec data)]
    (throw (ex-info (or error-message (s/explain-str spec data)) ex-data))
    data))

(defn validate-author!
  [data] (validate-entity! :survey/author data :error-message "invalid author"))

(defn validate-survey!
  [data] (validate-entity! :survey/entity data :error-message "invalid survey"))

(defn validate-question!
  [data] (validate-entity! :question/entity data :error-message "invalid question"))

(defn validate-question-type!
  [data] (validate-entity! :question.type/entity data :error-message "invalid question type"))

(defn validate-question-option!
  [data] (validate-entity! :question.option/entity data :error-message "invalid question option"))

(defn valid-question?
  [data] (s/valid? :question/entity data))

(defn valid-question-option?
  [data] (s/valid? :question.option/entity data))

(defn make-question-type
  [& {:keys [id name slug]}]
  (-> {:entity/id (->uuid id)
       :question.type/name name
       :question.type/slug slug}
      validate-question-type!))

(defn make-question-option
  [& {:keys [id text weight] :or {weight 0}}]
  (-> {:entity/id id
       :question.option/text text
       :question.option/weight weight}
      validate-question-option!))

(defn make-question
  [& {:keys [id text display_order required settings question_options question_type]
      :or {id (random-uuid) display-order 0 required false}}]
  (-> {:entity/id (->uuid id)
       :question/text text
       :question/display-order display_order
       :question/required required
       :question/settings settings
       :question/options (->> question_options (map #(vector (% 0) (make-question-option (% 1)))) (into {}))
       :question/type (make-question-type question_type)}
      validate-question!))

(defn make-author
  [& {:keys [id name nickname]}]
  (let [user (if id {:entity/id id} {})
        user (if name (assoc user :user/name name) user)
        user (if nickname (assoc user :user/nickname nickname) user)]
    (validate-author! user)))

(defn make-survey
  [& {:keys [id name description author questions updated_at]
      :or {id (random-uuid) updated_at (js/Date.)}}]
  (let [survey
        {:entity/id (->uuid id)
         :survey/name name
         :survey/author (make-author author)
         :survey/questions (->> questions (map #(vector (->uuid (% 0)) (make-question (% 1)))) (into {}))
         :survey/updated-at updated_at}
        survey (if description (assoc survey :survey/description description) survey)]
    (validate-survey! survey)))

(defn survey-questions
  [survey] (:survey/questions survey))

(defn question->update
  [question])

(defn survey->update
  [survey]
  {:id (str (:entity/id survey))
   :name (:survey/name survey)
   :author (:survey/author survey)
   :updated_at (:survey/updated-at survey)
   :description (:survey/description survey)
   :questions (->> survey :survey/questions (map question->update))})
