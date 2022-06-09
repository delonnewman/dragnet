(ns dragnet.editor.core
  (:require-macros [cljs.core.async.macros :refer [go]])
  (:require [cljs-http.client :as http]
            [cljs.core.async :refer [<! chan]]
            [reagent.core :as r]
            [reagent.dom :as rdom]
            [dragnet.editor.components :refer [survey-editor]]))

(def current-survey (r/atom nil))
(def root-url "http://localhost:3000")
(def dom-id "survey-editor")

(defn api-data [url]
  (go (let [res (<! (http/get url {:with_credentials? false}))]
        (:body res))))

(defn survey-endpoint [survey-id]
  (str root-url "/api/v1/editing/surveys/" survey-id))

(defn refresh-editor [survey]
  (println "Initializing editor with: " (prn-str @survey))
  (let [elem (.getElementById js/document dom-id)]
    (rdom/render
     [survey-editor survey]
     (.getElementById js/document dom-id))))

(add-watch current-survey :editor-refresh (fn [_ ref _ _] (refresh-editor ref)))

(defn init []
  (go (let [survey-id (-> (.querySelector js/document "input[name=survey_id]") .-value)
            survey (<! (api-data (survey-endpoint survey-id)))]
        (reset! current-survey survey))))
