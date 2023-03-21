(ns dragnet.editor.shell
  "The survey editor UI shell"
  (:require-macros [cljs.core.async.macros :refer [go]])
  (:require
    [cljs-http.client :as http]
    [cljs.core.async :refer [<!]]
    [reagent.core :as r]
    [reagent.dom :as rdom]
    [dragnet.shared.utils :refer [blank? validate-presence!] :include-macros true]
    [dragnet.editor.core :refer [survey-url]]
    [dragnet.editor.components :refer [survey-editor]]))

(defn fetch-survey-data
  [survey-id]
  (go (let [res (<! (http/get (survey-url survey-id)))]
        (res :body))))

(defn update-survey
  [survey data]
  (go (let [res (<! (http/put (survey-url survey) {:transit-params data}))]
        (res :body))))

(defn ui-renderer
  "Return a watcher for the editor's state that will
  render the editor UI to the given root element."
  [root-elem]
  (fn [_ ref old new]
    (when (not= (:survey old) (:survey new))
          (println "Last update" (-> new :updated_at))
          (rdom/render [survey-editor ref] root-elem))))

(defn auto-updater
  "Return a watcher for the editor's state that will
  auto save the survey's latest edit"
  []
  (fn [_ ref old new]
    (if (and old (not= (:survey old) (:survey new)))
      (go (let [edit (<! (update-survey new (:survey new)))]
            (swap! ref assoc :edits (conj (@ref :edits) edit)))))))

(defn init
  "Initialize survey editor UI with the root element and
  survey-id both arguments should be present."
  [root-elem survey-id]
  (validate-presence! root-elem survey-id)
  (println "initializing editor for " survey-id)
  (let [current (r/atom nil)]
    (add-watch current :render-ui (ui-renderer root-elem))
    (add-watch current :auto-update (auto-updater))
    (go (let [state (<! (fetch-survey-data survey-id))]
          (reset! current state)))))
