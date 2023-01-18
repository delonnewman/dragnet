(ns dragnet.shared.utils-test
  (:require
   [dragnet.shared.utils :refer [form-name]]
   [clojure.test :refer [deftest testing is]]))

(deftest form-name-test
  (testing "Will generate a Rails style nested form name from args"
    (is (= "form[field][option]" (form-name :form :field :option))))
  (testing "Will generate a Rails style nested form name from a collection"
    (is (= "form[field][option]" (form-name [:form :field :option])))))
