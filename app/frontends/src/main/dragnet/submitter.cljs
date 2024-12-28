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

(defn find-element [element-id]
  (if-let [elem (js/document.getElementById element-id)]
    elem
    (throw (js/Error. (str "Can't find element by id: " (pr-str element-id))))))

(defn ^:export init
  "Initialize reply submission UI with the root element ID and optionally a reply-id."
  [element-id reply-id]
  (let [root-elem (find-element element-id)
        reply-id (or reply-id (.getAttribute root-elem "data-reply-id"))
        preview (= "true" (.getAttribute root-elem "data-is-preview"))]
    (utils/validate-presence! root-elem reply-id)
    (add-watch state :render-ui (ui-renderer root-elem reply-id :preview preview))
    (go (let [data (<! (fetch-reply-data reply-id))]
          (swap! state merge data)))))


(defn ^:export init-with-new-reply
  "Initialize a new reply and reply submission UI with the root element ID and survey-id."
  [root-elem-id survey-id]
  (if-let [rid (storage/stored-reply-id survey-id)]
    (init root-elem-id rid)
    (go (let [res  (<! (http/post (reply-url survey-id)))
              rid  (get-in res [:body :reply_id])]
          (storage/store-reply-id! survey-id rid)
          (init root-elem-id rid)))))
