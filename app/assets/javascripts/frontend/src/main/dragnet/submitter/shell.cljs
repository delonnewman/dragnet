(ns dragnet.submitter.shell
  (:require
    [cljs.core.async :refer [go <!]]
    [cljs-http.client :as http]
    [reagent.core :as r]
    [reagent.dom :as rdom]
    [dragnet.submitter.components :refer [reply-submitter]]
    [dragnet.submitter.core :refer [reply-url]]))

(defn render-ui
  [elem reply-id]
  (fn
    [_ _ old new]
    (when (not= old new)
      (rdom/render [reply-submitter reply-id new] elem))))

(defn fetch-reply-data
  [reply-id]
  (go
    (let [res (<! (http/get (reply-url reply-id)))]
      (:body res))))

(defn init
  "Initialize reply submission UI with the root element an reply ID.
  Both the root element and reply ID should be non-nil."
  [elem reply-id]
  (when (and elem reply-id)
    (let [current (r/atom nil)]
      (add-watch current :render-ui (render-ui elem reply-id))
      (go
        (let [state (<! (fetch-reply-data reply-id))]
          (reset! current state))))))
