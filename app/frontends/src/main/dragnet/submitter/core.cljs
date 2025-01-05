(ns dragnet.submitter.core
  (:require
   [dragnet.common.utils :as utils]))


(def reply-path (utils/path-helper ["/api/v1/submission/replies" :entity/id]))

(comment
  (reply-path 1)
  )

(defn reply-url
  [entity-or-id & {:keys [preview]}]
  (if preview
    (str (utils/root-url) (reply-path entity-or-id) "/preview")
    (str (utils/root-url) (reply-path entity-or-id))))

(comment
  (reply-url 1)
  (reply-url 1 :preview true)
  )


(def submission-path (utils/path-helper ["/replies" :entity/id "submit"]))
(def submission-url (utils/url-helper submission-path))

(comment
  (submission-path 1)
  (submission-url 1)
  )

(defn answer-form-name
  [& keys]
  (utils/form-name (concat [:reply :answers_attributes] keys)))

(comment
  (answer-form-name :hey)
  )
