(ns dragnet.submitter.shell
  "The reply submitter UI shell"
  (:require
    [cljs.core.async :refer [go <!]]
    [cljs-http.client :as http]
    [reagent.core :as r]
    [reagent.dom :as rdom]
    [dragnet.shared.utils :as utils :refer [blank? ex-blank] :include-macros true]
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
  "Initialize reply submission UI with the root element,
  survey-id and reply-id, the third argument (normally a Reply ID)
  can also be a flag currently only a 'preview' flag is supported.
  All three arguments should be non-nil."
  [root-elem survey-id reply-id]
  (utils/validate-presence! root-elem survey-id reply-id)
  (let [current (r/atom nil)
        preview (= "preview" reply-id)
        id      (if preview survey-id reply-id)]
    (add-watch current :render-ui (ui-renderer root-elem reply-id :preview preview))
    (go (let [state (<! (fetch-reply-data id :preview preview))]
          (reset! current state)))))
