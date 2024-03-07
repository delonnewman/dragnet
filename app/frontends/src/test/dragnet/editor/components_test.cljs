(ns dragnet.editor.components-test
  (:require
    [clojure.test :refer [deftest is]]
    [dragnet.editor.components :as comp]
    [dragnet.editor.testing-utils :as utils :refer [state question-of-type]]
    [reagent.dom.server :refer [render-to-string]]))


(deftest question-card-body-test
  (let [input-types {"text" #(re-seq #"type=.text." %),
                     "time" #(re-seq #"type=.datetime-local." %),
                     "number" #(re-seq #"type=.number." %)
                     "choice" #(re-seq #"Add Option" %)}]
    (doseq [[type test] input-types]
      (let [html (render-to-string (comp/question-card-body state (question-of-type type)))]
        (is (test html))))))
