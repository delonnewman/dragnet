(ns dragnet.editor.shell
  "The survey editor UI shell"
  (:require
    [cljs-http.client :as http]
    [cljs.core.async :refer [<! go]]
    [cljs.repl :refer [ex-triage ex-str]]
    [dragnet.editor.components :refer [survey-editor]]
    [dragnet.editor.core :refer [survey-url]]
    [dragnet.entities.survey :refer [make-survey survey->update make-question-types]]
    [dragnet.shared.utils :refer [blank? validate-presence! pp pp-str http-request] :include-macros true]
    [reagent.core :as r]
    [reagent.dom :as rdom]))


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
  (let [survey (state :survey)
        update (survey->update survey)]
    (println "update-survey" (survey-url survey))
    (go (let [res (<! (http-request :method :put :url (survey-url survey) :transit-params update :error-fn (error-handler state)))]
          (pp res)
          (res :body)))))


(defn ui-renderer
  "Return a watcher for the editor's state that will
  render the editor UI to the given root element."
  [root-elem]
  (fn [_ ref old new]
    (when (or (:errors new) (not= (:survey old) (:survey new)))
      (println "Last update" (-> new :survey/updated-at))
      (rdom/render [survey-editor ref] root-elem))))


(defn auto-updater
  "Return a watcher for the editor's state that will
  auto save the survey's latest edit"
  []
  (fn [_ ref old new]
    (if (and old (not= (:survey old) (:survey new)))
      (go (let [edit (<! (update-survey new))]
            (swap! ref assoc :edits (conj (@ref :edits) edit)))))))


(defn ^:export init
  "Initialize survey editor UI with the root element and
  survey-id both arguments should be present."
  [root-elem survey-id]
  (validate-presence! root-elem survey-id)
  (js/console.warn "initializing editor for " survey-id)
  (let [current (r/atom nil)]
    (add-watch current :render-ui (ui-renderer root-elem))
    (add-watch current :auto-update (auto-updater))
    (go
      (let [state (<! (fetch-survey-data survey-id))]
        (try
          (let [state
                (assoc state
                       :survey (make-survey (state :survey))
                       :question-types (make-question-types (state :question_types)))]
            (reset! current state))
          (catch js/Object e
            (js/console.error (ex-message e))
            (js/console.log (.split (.-stack e) "\n"))
            (pp state)))))))
