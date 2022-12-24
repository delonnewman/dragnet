(ns dragnet.editor.shell
  (:require-macros [cljs.core.async.macros :refer [go]])
  (:require
    [cljs-http.client :as http]
    [cljs.core.async :refer [<!]]
    [reagent.core :as r]
    [reagent.dom :as rdom]
    [dragnet.editor.components :refer [survey-editor]]))

; TODO: add validation
(def current-state (r/atom nil))
(def root-url "http://dragnet.test")
(def root-element (atom nil))

(defn get-root-element
  []
  (let [id @root-element]
    (if id id (throw (ex-message "Root element has not be set")))))

(defn api-data
  [url]
  (go (let [res (<! (http/get url))]
        (res :body))))

(defn api-update
  [url data]
  (go (let [res (<! (http/put url {:transit-params data}))]
        (res :body))))

(defn survey-endpoint
  [survey-id]
  (str root-url "/api/v1/editing/surveys/" survey-id))

(defn refresh-editor
  [state]
  (rdom/render [survey-editor state] (get-root-element)))

(add-watch current-state :editor-refresh
           (fn [_ ref old new]
             (when (not= (:survey old) (:survey new))
               (println "Last update" (-> new :updated_at))
               (refresh-editor ref))))

(add-watch current-state :updates
           (fn [_ ref old new]
             (if (and old (not= (:survey old) (:survey new)))
               (go
                 (let [edit (<! (api-update (survey-endpoint (get-in new [:survey :id])) (:survey new)))]
                   (swap! ref assoc :edits (conj (@ref :edits) edit)))))))

(defn init
  [elem survey-id]
  (when (and elem survey-id)
    (println "initializing editor for " survey-id)
    (go (let [data (<! (api-data (survey-endpoint survey-id)))]
          (reset! root-element elem)
          (reset! current-state data)))))
