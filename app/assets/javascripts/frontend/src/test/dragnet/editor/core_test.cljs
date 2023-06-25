(ns dragnet.editor.core-test
  (:require
   [dragnet.editor.core :as core]
   [dragnet.editor.testing-utils :as utils :refer [state]]
   [clojure.test :refer [deftest is testing]]))

(deftest question-type-test
  (testing "When the question type ID is not present"
    (is (nil? (core/question-type @state 99))))
  (testing "When the question type ID is present"
    (doseq [id (keys utils/question-types)]
      (is (= (-> id utils/question-types)
             (core/question-type @state id))))))

(deftest question-type-slug-test
  (testing "When the question_type_id is not present"
    (is (nil? (core/question-type-slug @state {}))))
  (testing "When the question_type_id is present"
    (doseq [id (keys utils/question-types)]
      (is (= (-> id utils/question-types :slug)
             (core/question-type-slug @state {:question/type {:entity/id id}}))))))

(deftest question-types-test
  (is (= utils/question-types (core/question-types @state))))

(deftest question-type-list-test
  (is (= (vals utils/question-types) (core/question-type-list @state))))

(deftest survey-edited-test
  (testing "When survey does not have edits"
    (swap! state assoc :edits [])
    (is (not (core/survey-edited? @state))))
  (testing "When survey has edits"
    (swap! state assoc :edits [1])
    (is (core/survey-edited? @state))))

(deftest question-type-id-test
  (is (= 1 (core/question-type-id {:question_type_id 1}))))

(deftest question-type-uid-test
  (testing "When a question type is not given"
    (let [q (utils/question-of-type "time")]
      (is (= (str "question-" (q :id) "-type-" (-> q :question_type_id))
             (core/question-type-uid q)))))
  (testing "When a question type is given"
    (let [q (utils/question-of-type "time")]
      (is (= (str "question-" (q :id) "-type-" (-> q :question_type_id))
             (core/question-type-uid q (core/question-type @state q)))))))

(deftest assoc-question-type-id-test
  (is (= (core/assoc-question-type-id {} {:id "question-123"} "type-345")
         {:survey {:questions {"question-123" {:question_type_id "type-345"}}}})
      "associates the type id with the specified question"))

(deftest change-type!-test
  (let [changer (core/change-type! (atom {}) {:id "question-123"})]
    (is (= (changer #js{:target #js{:value "type-345"}})
           {:survey {:questions {"question-123" {:question_type_id "type-345"}}}}))))
