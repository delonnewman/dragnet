(ns dragnet.submitter.core
  (:require [dragnet.shared.utils :refer [root-url form-name]]))

(defn reply-path
  [reply-id]
  (str "/api/v1/submission/replies/" reply-id))

(defn reply-url
  [id & {:keys [preview]}]
  (if preview
    (str (root-url) (reply-path id) "/preview")
    (str (root-url) (reply-path id))))

(defn submission-path
  [reply-id]
  (str (reply-path reply-id) "/submit"))

(defn answer-form-name
  [& keys]
  (form-name (concat [:reply :answers_attributes] keys)))
