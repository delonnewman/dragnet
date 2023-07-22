(ns dragnet.submitter.local-storage)

(defn local-storage-key
  [survey-id]
  (str "dragnet-" survey-id "-reply-id"))

(defn stored-reply-id
  [survey-id]
  (.getItem js/localStorage (local-storage-key survey-id)))

(defn store-reply-id!
  [survey-id reply-id]
  (.setItem js/localStorage (local-storage-key survey-id) reply-id))

(defn remove-stored-id-code
  [survey-id]
  (str "localStorage.removeItem('" (local-storage-key survey-id) "')"))
