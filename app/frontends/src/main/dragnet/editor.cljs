(ns dragnet.editor
  "The survey editor UI shell"
  (:require
   [cljs-http.client :as http]
   [cljs.core.async :refer [<! go]]
   [dragnet.editor.components :refer [survey-editor]]
   [dragnet.editor.core :refer [survey-url]]
   [dragnet.editor.entities
    :refer [make-survey survey->update make-question-types]]
   [dragnet.common.utils
    :refer [validate-presence! pp pp-str http-request]
    :include-macros true]
   [reagent.core :as r]
   [reagent.dom :as rdom]))


(def ^:dynamic *element-id* "survey-editor")
(def survey-id-attribute "data-survey-id")
(def state (r/atom {}))


(defn root-element []
  (js/document.getElementById *element-id*))


(defn survey-id []
  (when-let [elem (root-element)]
    (.getAttribute elem survey-id-attribute)))


(defn on-valid-page! []
  (validate-presence! (root-element) (survey-id)))


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
    (go (let [res
              (<! (http-request
                   :method :put
                   :url (survey-url survey)
                   :transit-params update
                   :error-fn (error-handler state)))]
          (res :body)))))


(defn ui-renderer
  "Return a watcher for the editor's state that will
  render the editor UI to the given root element."
  []
  (fn [_ ref old new]
    (when (or (:errors new) (not= (:survey old) (:survey new)))
      (js/console.info "Last update" (-> new :survey/updated-at))
      (rdom/render [survey-editor ref] (root-element)))))


(defn auto-updater
  "Return a watcher for the editor's state that will
  auto save the survey's latest edit"
  []
  (fn [_ ref old new]
    (when (and old (not= (:survey old) (:survey new)))
      (go (let [edit (<! (update-survey new))]
            (swap! ref assoc :edits (conj (@ref :edits) edit)))))))


(defn make-ui-state
  [data]
  (assoc data
         :survey (make-survey (data :survey))
         :question-types (make-question-types (data :question_types))))


(defn add-watchers
  []
  (add-watch state :render-ui (ui-renderer))
  (add-watch state :auto-update (auto-updater)))


(defn -main
  "Initialize survey editor UI"
  []
  (on-valid-page!)
  (js/console.info "Initializing editor for " (survey-id))
  (add-watchers)
  (go
    (let [res (<! (http/get (survey-url (survey-id))))]
      (swap! state merge (make-ui-state (res :body))))))
