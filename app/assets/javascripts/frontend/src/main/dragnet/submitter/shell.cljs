(ns dragnet.submitter.shell
  (:require
    [cljs.core.async :refer [go <!]]
    [cljs-http.client :as http]
    [reagent.core :as r]
    [reagent.dom :as rdom]
    [dragnet.submitter.components :refer [reply-submitter]]
    [dragnet.submitter.core :refer [reply-url]]))

(defn render-ui
  [elem reply-id & {:keys [preview]}]
  (fn
    [_ _ old new]
    (when (not= old new)
      (rdom/render [reply-submitter reply-id new :preview preview] elem))))

(defn fetch-reply-data
  [id & {:keys [preview]}]
  (go
    (let [res (<! (http/get (reply-url id :preview preview)))]
      (:body res))))

(defn init
  "Initialize reply submission UI with the root element an reply ID.
  Both the root element and reply ID should be non-nil."
  [elem survey-id reply-id]
  (when (and elem survey-id reply-id)
    (let [current (r/atom nil)
          preview (= "preview" reply-id)
          id (if preview survey-id reply-id)]
      (add-watch current :render-ui (render-ui elem reply-id :preview :preview))
      (go
        (let [state (<! (fetch-reply-data id :preview preview))]
          (reset! current state))))))
