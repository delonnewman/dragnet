(ns dragnet.editor.core
  (:require-macros [cljs.core.async.macros :refer [go]])
  (:require [cljs-http.client :as http]
            [cljs.core.async :refer [<! chan]]
            [reagent.dom :as rdom]
            [dragnet.editor.components :refer [survey-editor]]))

(def current-survey (atom nil))
(def root-url "http://localhost:3000")
(def survey-id #uuid "111f53fe-8de2-4658-9e2a-68d005189a3f")
(def dom-id "survey-editor")

(defn api-data [url]
  (go (let [res (<! (http/get url {:with_credentials? false}))]
        (:body res))))

(defn survey-endpoint [survey-id]
  (str root-url "/api/v1/editing/surveys/" survey-id))

(defn init-editor [survey]
  (println "Initializing editor with: " (prn-str survey))
  (let [elem (.getElementById js/document dom-id)]
    (rdom/render [survey-editor survey] (.getElementById js/document dom-id))))

(add-watch current-survey :editor-init (fn [_ _ _ new] (init-editor new)))

(defn init []
  (go (let [survey (<! (api-data (survey-endpoint survey-id)))]
        (reset! current-survey survey))))
