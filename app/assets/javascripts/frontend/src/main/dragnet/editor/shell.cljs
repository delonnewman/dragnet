(ns dragnet.editor.shell
  "The survey editor UI shell"
  (:require
    [cljs-http.client :as http]
    [cljs.core.async :refer [<! go]]
    [reagent.core :as r]
    [reagent.dom :as rdom]
    [dragnet.shared.utils :refer [blank? validate-presence! pp pp-str http-request] :include-macros true]
    [dragnet.editor.core :refer [survey-url]]
    [dragnet.editor.components :refer [survey-editor]]
    [dragnet.entities.survey :refer [make-survey survey->update]]))

(defn fetch-survey-data
  [survey-id]
  (go (let [res (<! (http/get (survey-url survey-id)))]
        (res :body))))

(defn error-handler
  [state]
  (fn [res]
    (println "handling error" (pp-str res))
    (swap! state assoc :errors (conj (state :errors)) (res :body))))

(defn update-survey
  [state]
  (let [survey (state :survey)]
    (println "update-survey" (survey-url survey))
    (go (let [res (<! (http-request :method :put :url (survey-url survey) :transit-params survey :error-fn (error-handler state)))]
          (pp res)
          (res :body)))))

(defn ui-renderer
  "Return a watcher for the editor's state that will
  render the editor UI to the given root element."
  [root-elem]
  (fn [_ ref old new]
    (when (or (:errors new) (not= (:survey old) (:survey new)))
          (println "Last update" (-> new :updated_at))
          (rdom/render [survey-editor ref] root-elem))))

(defn auto-updater
  "Return a watcher for the editor's state that will
  auto save the survey's latest edit"
  []
  (fn [_ ref old new]
    (if (and old (not= (:survey old) (:survey new)))
      (go (let [edit (<! (update-survey new))]
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
          (try
            (let [survey-data (state :survey)
                  survey (make-survey survey-data)
                  update (survey->update survey)]
              (println 'survey-data (pp-str survey-data))
              (println 'survey (pp-str survey))
              (println 'update (pp-str update)))
            (catch js/Object e
              ;; TODO: extract this into a macro make use of expound
              (.error js/console (ex-message e) (pp-str (ex-data e)))))
          (reset! current state)))))
