(ns dragnet.shared.utils-test
  (:require
   [dragnet.shared.utils :refer [form-name pluralize root-url *window*]]
   [clojure.test :refer [deftest testing is]]))

(deftest form-name-test
  (is (= "form[field][option]" (form-name :form :field :option))
      "generates Rails style form names from args")
  (is (= "form[field][option]" (form-name [:form :field :option]))
      "generates Rails style form names from a collection"))

(deftest pluralize-test
  (testing "When n is 1"
    (is (= "1 tester" (pluralize "tester" 1))
        "the word will be returned without change"))
  (testing "When n is not 1"
    (testing "and when the word does not end in 's'"
      (is (= "2 testers" (pluralize "tester" 2))
          "the word is returned with an 's' appended"))
    (testing "and when the word ends in 's'"
      (is (= "2 joneses" (pluralize "jones" 2))
          "the word is return with an 'es' appended"))))

(deftest root-url-test
  (binding [*window* #js{:location #js{:origin "https://example.com"}}]
    (is (= "https://example.com" (root-url))
        "returns the browsers current origin location")))
