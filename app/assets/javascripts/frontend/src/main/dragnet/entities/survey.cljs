(ns dragnet.entities.survey
  (:require [cljs.spec.alpha :as s]))

(s/def :user/id pos?)
(s/def :user/name string?)
(s/def :user/nickname string?)

(s/def :question.type/id pos?)
(s/def :question.type/name string?)
(s/def :question.type/slug string?)
(s/def :question.type/entity (s/keys :req [:question.type/id :question.type/name :question.type/slug]))

(s/def :question.option/id pos?)
(s/def :question.option/text string?)
(s/def :question.option/weight (s/or pos? zero?))
(s/def :question.option/entity
  (s/keys :req [:question.option/text :question.option/weight]
          :opt [:question.option/id]))

(s/def :question/id uuid?)
(s/def :question/text string?)
(s/def :question/display-order (s/or pos? zero?))
(s/def :question/required boolean?)
(s/def :question/settings map?)
(s/def :question/options (s/coll-of :question.option/entity))
(s/def :question/type :question.type/entity)
(s/def :question/entity
  (s/keys :req [:question/text :question/type]
          :opt [:question/id :question/display-order :question/required :question/settings :question/options]))

(s/def :survey/id uuid?)
(s/def :survey/name string?)
(s/def :survey/description string?)
(s/def :survey/updated-at inst?)
(s/def :survey/author (s/keys :req [:user/id :user/name :user/nickname]))
(s/def :survey/questions (s/coll-of :question/entity))
(s/def :survey/entity (s/keys :req [:survey/id :survey/name :survey/updated-at :survey/author]
                              :opt [:survey/description :survey/questions]))

(defn valid-survey?
  [data] (s/valid? :survey/entity data))

(defn validate-entity!
  [spec data & {:keys [error-message]}]
  (if-let [ex-data (s/explain-data spec data)]
    (throw (ex-info (or error-message (s/explain-str spec data)) ex-data))
    data))

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
  (-> {:question.type/id id
       :question.type/name name
       :question.type/slug slug}
      validate-question-type!))

(defn make-question-option
  [& {:keys [id text weight] :or {weight 0}}]
  (-> {:question.option/id id
       :question.option/text text
       :question.option/weight weight}
      validate-question-option!))

(defn make-question
  [& {:keys [id text display-order required settings options type]
      :or {id (random-uuid) display-order 0 required false}}]
  (-> {:question/id id
       :question/text text
       :question/display-order display-order
       :question/required required
       :question/settings settings
       :question/options (->> options (map make-question-option) doall)
       :question/type (make-question-type type)}
      validate-question!))

(defn make-survey
  [& {:keys [id name description author questions updated-at]
      :or {id (random-uuid) updated-at (js/Date.)}}]
  (-> {:survey/id id
       :survey/name name
       :survey/description description
       :survey/author author
       :survey/questions (->> questions (map make-question) doall)
       :survey/updated-at updated-at}
      validate-survey!))

(defn survey-questions
  [survey] (:survey/questions survey))
