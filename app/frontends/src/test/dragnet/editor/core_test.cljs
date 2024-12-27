(ns dragnet.editor.core-test
  (:require
    [clojure.test :refer [deftest is testing]]
    [dragnet.editor :as core]
    [dragnet.editor.testing-utils :as utils :refer [state]]))


(deftest test-question-type
  (testing "When the question type ID is not present"
    (is (thrown? js/Error (core/question-type @state 99))))
  (testing "When the question type ID is present"
    (doseq [id (keys utils/question-types)]
      (is (= (-> id utils/question-types)
             (core/question-type @state id))))))


(deftest test-question-type-slug
  (testing "When the question_type_id is not present"
    (is (thrown? js/Error (core/question-type-slug @state {}))))
  (testing "When the question_type_id is present"
    (doseq [id (keys utils/question-types)]
      (is (= (-> id utils/question-types :slug)
             (core/question-type-slug @state {:question/type {:entity/id id}}))))))


(deftest test-question-types
  (is (= utils/question-types (core/question-types @state))))


(deftest test-question-type-list
  (is (= (vals utils/question-types) (core/question-type-list @state))))


(deftest test-survey-edited
  (testing "When survey does not have edits"
    (swap! state assoc :edits [])
    (is (not (core/survey-edited? @state))))
  (testing "When survey has edits"
    (swap! state assoc :edits [1])
    (is (core/survey-edited? @state))))


(deftest test-question-type-id
  (is (= 1 (core/question-type-id {:question_type_id 1}))))


(deftest test-question-type-uid
  (testing "When a question type is not given"
    (let [q (utils/question-of-type "time")]
      (is (= (str "question-" (q :id) "-type-" (-> q :question_type_id))
             (core/question-type-uid q)))))
  (testing "When a question type is given"
    (let [q (utils/question-of-type "time")]
      (is (= (str "question-" (q :id) "-type-" (-> q :question_type_id))
             (core/question-type-uid q (core/question-type @state q)))))))


(deftest test-assoc-question-type-id
  (is (= (core/assoc-question-type-id {} {:id "question-123"} "type-345")
         {:survey {:questions {"question-123" {:question_type_id "type-345"}}}})
      "associates the type id with the specified question"))


(deftest test-change-type
  (let [changer (core/change-type! (atom {}) {:id "question-123"})]
    (is (= (changer #js{:target #js{:value "type-345"}})
           {:survey {:questions {"question-123" {:question_type_id "type-345"}}}}))))
