(ns dragnet.submitter.shell)

(defn init
  [elem survey-id]
  (when (and elem survey-id)
    (.log js/console "initializing submitter for " survey-id elem)
    ))
