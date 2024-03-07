(ns dragnet.submitter.core
  (:require
    [dragnet.shared.utils :as utils]))


(defn reply-path
  [reply-id]
  (str "/api/v1/submission/replies/" reply-id))


(defn reply-url
  [id & {:keys [preview]}]
  (if preview
    (str (utils/root-url) (reply-path id) "/preview")
    (str (utils/root-url) (reply-path id))))


(defn submission-url
  [reply-id]
  (str (reply-url reply-id) "/submit"))


(defn answer-form-name
  [& keys]
  (utils/form-name (concat [:reply :answers_attributes] keys)))
