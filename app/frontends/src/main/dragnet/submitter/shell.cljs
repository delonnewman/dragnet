(ns dragnet.submitter.shell
  "The reply submitter UI shell"
  (:require
    [cljs-http.client :as http]
    [cljs.core.async :refer [go <!]]
    [dragnet.shared.utils :as utils :include-macros true]
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

(defn ^:export init
  "Initialize reply submission UI with the root element, survey-id and reply-id,
  the third argument (normally a Reply ID) can also be a flag currently only a
  'preview' flag is supported. All three arguments should be non-nil."
  [element-id & {:keys [reply-id]}]
  (let [root-elem (js/document.getElementById element-id)
        survey-id (.getAttribute root-elem "data-survey-id")
        reply-id (or reply-id (.getAttribute root-elem "data-reply-id"))
        preview (= "true" (.getAttribute root-elem "data-is-preview"))
        csrf-token (.getAttribute root-elem "data-authenticity-token")]
    (utils/validate-presence! root-elem survey-id reply-id)
    (add-watch state :render-ui (ui-renderer root-elem reply-id :preview preview))
    (go (let [data (<! (fetch-reply-data reply-id))]
          (swap! state merge (assoc data :csrf-token csrf-token))))))


(defn ^:export initWithNewReply
  "Initialize a new reply and reply submission UI with the root element and survey-id."
  [root-elem-id survey-id]
  (if-let [rid (storage/stored-reply-id survey-id)]
    (init root-elem-id :reply-id rid)
    (go (let [res  (<! (http/post (reply-url survey-id)))
              rid  (get-in res [:body :reply_id])]
          (storage/store-reply-id! survey-id rid)
          (init root-elem-id)))))
