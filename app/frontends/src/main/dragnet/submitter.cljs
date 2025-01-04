(ns dragnet.submitter
  "The reply submitter UI shell"
  (:require
   [cljs-http.client :as http]
   [cljs.core.async :refer [go <!]]
   [dragnet.common.utils :as utils :include-macros true]
   [dragnet.submitter.components :refer [reply-submitter]]
   [dragnet.submitter.core :refer [reply-url]]
   [dragnet.submitter.local-storage :as storage]
   [reagent.core :as r]
   [reagent.dom :as rdom]))


(defn ui-renderer
  [elem reply-id & {:keys [preview]}]
  (fn [_ _ old new]
    (when (not= old new)
      (rdom/render [reply-submitter reply-id new :preview preview] elem))))


(defn fetch-reply-data
  [id & {:keys [preview]}]
  (go (let [res (<! (http/get (reply-url id :preview preview)))]
        (:body res))))


(def state (r/atom {}))

(def ^:dynamic *element-id* "survey-submitter")
(def is-preview-attributes "data-is-preview")
(def reply-id-attribute "data-reply-id")
(def survey-id-attribute "data-survey-id")


(defn root-element []
  (js/document.getElementById *element-id*))


(defn get-element-attribute
  "Get and attribute value from the root element."
  [attribute]
  (when-let [elem (root-element)]
    (.getAttribute elem attribute)))


(def get-survey-id (partial get-element-attribute survey-id-attribute))


(defn get-reply-id
  "Return the reply id from the page or nil if it's not present."
  [] (-> (get-element-attribute reply-id-attribute) utils/presence))


(defn preview?
  "Return preview status from the page, it will only return true if
  the preview attribute is set to \"true\"."
  [] (= "true" (get-element-attribute is-preview-attributes)))


(defn ^:export init
  "Initialize reply submission UI. When a reply id is not specified with
  the optional parameter look for it on the root element."
  [& [reply-id]]
  (let [preview (preview?)
        id (if preview (get-survey-id) (or reply-id (get-reply-id)))]
    (utils/validate-presence! (root-element))
    (add-watch state :render-ui (ui-renderer (root-element) id :preview preview))
    (go
      (let [data (<! (fetch-reply-data id :preview preview))]
        (swap! state merge data)))))


(defn ^:export init-with-new-reply
  "Initialize a new reply and reply submission UI with
  the root element ID and survey-id."
  [survey-id]
  (if-let [reply-id (storage/stored-reply-id survey-id)]
    (init reply-id)
    (go
      (let [response (<! (http/post (reply-url survey-id)))
            reply-id (get-in response [:body :reply_id])]
        (storage/store-reply-id! survey-id reply-id)
        (init reply-id)))))
