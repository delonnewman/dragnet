(ns dragnet.editor.core
  (:require-macros [cljs.core.async.macros :refer [go]])
  (:require [cljs-http.client :as http]
            [cljs.core.async :refer [<! chan]]
            [cljs.pprint :as pp]
            [reagent.core :as r]
            [reagent.dom :as rdom]
            [dragnet.editor.components :refer [survey-editor]]))

; TODO: add validation
(def current-state (r/atom nil))
(def root-url "http://localhost:3000")
(def dom-id "survey-editor")

(defn api-data
  [url]
  (go (let [res (<! (http/get url))]
        (res :body))))

(defn api-update
  [url data]
  (println "api-update" url data)
  (go (let [res (<! (http/put url {:transit-params data}))]
        res)))

(defn survey-endpoint
  [survey-id]
  (str root-url "/api/v1/editing/surveys/" survey-id))

(defn refresh-editor
  [state]
  (let [elem (.getElementById js/document dom-id)]
    (rdom/render [survey-editor state] elem)))

(add-watch current-state :editor-refresh (fn [_ ref _ new-data] (refresh-editor ref)))
(add-watch current-state :updates
           (fn [_ ref old new]
             (if (and old new)
               (api-update (survey-endpoint (get-in new [:survey :id])) (:survey new)))))

(defn init []
  (go (let [survey-id (-> (.querySelector js/document "input[name=survey_id]") .-value)
            data (<! (api-data (survey-endpoint survey-id)))]
        (reset! current-state data))))
