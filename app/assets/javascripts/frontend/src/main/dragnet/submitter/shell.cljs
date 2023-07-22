(ns dragnet.submitter.shell
  "The reply submitter UI shell"
  (:require
    [cljs.core.async :refer [go <!]]
    [cljs-http.client :as http]
    [reagent.core :as r]
    [reagent.dom :as rdom]
    [dragnet.shared.utils :as utils :refer [blank? ex-blank] :include-macros true]
    [dragnet.submitter.local-storage :as storage]
    [dragnet.submitter.components :refer [reply-submitter]]
    [dragnet.submitter.core :refer [reply-url]]))

(defn ui-renderer
  [elem reply-id & {:keys [preview]}]
  (fn
    [_ _ old new]
    (when (not= old new)
      (rdom/render [reply-submitter reply-id new :preview preview] elem))))

(defn fetch-reply-data
  [id & {:keys [preview]}]
  (go (let [res (<! (http/get (reply-url id :preview preview)))]
        (:body res))))

(defn ^:export init
  "Initialize reply submission UI with the root element, survey-id and reply-id,
  the third argument (normally a Reply ID) can also be a flag currently only a
  'preview' flag is supported. All three arguments should be non-nil."
  [root-elem survey-id reply-id]
  (utils/validate-presence! root-elem survey-id reply-id)
  (let [current (r/atom nil)
        preview (= "preview" reply-id)
        id      (if preview survey-id reply-id)]
    (add-watch current :render-ui (ui-renderer root-elem reply-id :preview preview))
    (go (let [state (<! (fetch-reply-data id :preview preview))]
          (reset! current state)))))

(defn ^:export initWithNewReply
  "Initialize a new reply and reply submission UI with the root element and survey-id."
  [root-elem-id survey-id]
  (let [elem (.getElementById js/document root-elem-id)]
    (if-let [rid (storage/stored-reply-id survey-id)]
      (init elem survey-id, rid)
      (go (let [res  (<! (http/post (reply-url survey-id)))
                rid  (get-in res [:body :reply_id])]
            (storage/store-reply-id! survey-id rid)
            (init elem survey-id rid))))))