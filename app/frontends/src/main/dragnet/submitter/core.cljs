(ns dragnet.submitter.core
  (:require
    [dragnet.common.utils :as utils]))


(defn submission-url
  [reply-id]
  (str "/replies/" reply-id "/submit"))


(defn answer-form-name
  [& keys]
  (utils/form-name (concat [:reply :answers_attributes] keys)))
