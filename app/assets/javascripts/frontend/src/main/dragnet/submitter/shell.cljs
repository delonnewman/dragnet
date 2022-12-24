(ns dragnet.submitter.shell
  (:require
    [cljs.core.async :refer [go <!]]
    [cljs-http.client :as http]
    [reagent.core :as r]
    [reagent.dom :as rdom]
    [dragnet.submitter.components :refer [reply-submitter]]
    [dragnet.submitter.core :refer [reply-url]]))

(defn render-ui
  [elem]
  (fn
    [_ _ old new]
    (when (not= old new)
      (rdom/render [reply-submitter new] elem))))

(defn fetch-reply-data
  [reply-id]
  (go
    (let [res (<! (http/get (reply-url reply-id)))]
      (:body res))))

(defn init
  [elem reply-id]
  (when (and elem reply-id)
    (let [current (r/atom nil)]
      (add-watch current :render-ui (render-ui elem))
      (go
        (let [state (<! (fetch-reply-data reply-id))]
          (reset! current state))))))
