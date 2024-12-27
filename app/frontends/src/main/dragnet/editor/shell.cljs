(ns dragnet.editor.shell
  "The survey editor UI shell"
  (:require
    [cljs-http.client :as http]
    [cljs.core.async :refer [<! go take!]]
    [cljs.repl :refer [ex-triage ex-str]]
    [dragnet.editor.components :refer [survey-editor]]
    [dragnet.editor :refer [survey-url]]
    [dragnet.entities.core :refer [make-survey survey->update make-question-types]]
    [dragnet.shared.utils :refer [validate-presence! pp pp-str http-request] :include-macros true]
    [reagent.core :as r]
    [reagent.dom :as rdom]))


(defn error-handler
  [state]
  (fn [res]
    (js/console.error "handling error" (pp-str res))
    (swap! state assoc :errors (conj (state :errors)) (res :body))))


(defn update-survey
  [state]
  (let [survey (state :survey)
        update (survey->update survey)]
    (js/console.info "update-survey" (survey-url survey))
    (go (let [res (<! (http-request :method :put :url (survey-url survey) :transit-params update :error-fn (error-handler state)))]
          (pp res)
          (res :body)))))


(defn ui-renderer
  "Return a watcher for the editor's state that will
  render the editor UI to the given root element."
  [root-elem]
  (fn [_ ref old new]
    (when (or (:errors new) (not= (:survey old) (:survey new)))
      (js/console.info "Last update" (-> new :survey/updated-at))
      (rdom/render [survey-editor ref] root-elem))))


(defn auto-updater
  "Return a watcher for the editor's state that will
  auto save the survey's latest edit"
  []
  (fn [_ ref old new]
    (when (and old (not= (:survey old) (:survey new)))
      (go (let [edit (<! (update-survey new))]
            (swap! ref assoc :edits (conj (@ref :edits) edit)))))))


(defn survey-data->ui-state
  [data]
  (assoc data
         :survey (make-survey (data :survey))
         :question-types (make-question-types (data :question_types))))


(def element-id "survey-editor")
(def survey-id-attribute "data-survey-id")
(def state (r/atom {})) ;; TODO: add a validator using spec


(defn add-watchers
  [root-element]
  (add-watch state :render-ui (ui-renderer root-element))
  (add-watch state :auto-update (auto-updater)))


(defn init
  "Initialize survey editor UI"
  []
  (let [root-elem (js/document.getElementById element-id)
        survey-id (.getAttribute root-elem survey-id-attribute)]
    (validate-presence! root-elem survey-id)
    (add-watchers root-elem)
    (js/console.info "Initializing editor for " survey-id)
    (go
      (let [res (<! (http/get (survey-url survey-id)))]
        (swap! state merge (survey-data->ui-state (res :body)))))))
