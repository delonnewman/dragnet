(ns dragnet.common.utils-test
  (:require
    [clojure.test :refer [deftest testing is]]
    [dragnet.common.utils :refer
     [blank?
      dom-id
      form-name
      path-helper
      pluralize
      presence
      root-url
      *window*
      ->sentence
      url-helper]]))


(deftest test-form-name
  (is (= "form[field][option]" (form-name :form :field :option))
      "generates Rails style form names from args")
  (is (= "form[field][option]" (form-name [:form :field :option]))
      "generates Rails style form names from a collection"))


(deftest test-dom-id
  (is (= "question-1" (dom-id {:entity/id 1 :entity/type :question})))
  (is (= "test-1" (dom-id {:entity/id 1 :entity/type :question} {:prefix "test"})))
  (is (= "question-1-option-2"
         (dom-id {:entity/id 1 :entity/type :question}
                 {:entity/id 2 :entity/type :option}))))


(deftest test-pluralize
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


(deftest test-root-url
  (binding [*window* #js{:location #js{:origin "https://example.com"}}]
    (is (= "https://example.com" (root-url))
        "returns the browsers current origin location")))


(deftest test-sentence
  (is (= "1" (->sentence [1])) "a single value should just be coerced into a string")
  (is (= "1, 2, and 3" (->sentence [1 2 3])) "constructs a sentence from a sequence")
  (is (= "1 and 2" (->sentence [1 2])) "two element sequences are a special case")
  (is (= "1-2-3" (->sentence [1 2 3] :delimiter "-" :last-delimiter nil)) "delimiter is configurable")
  (is (= "1, 2, or 3" (->sentence [1 2 3] :last-delimiter ", or ")) "last delimiter is configurable")
  (is (= "1 or 2" (->sentence [1 2] :two-word-delimiter " or ")) "two-word-delimiter is configurable"))


(deftest test-url-helper
  (binding [*window* #js{:location #js{:origin "https://example.com"}}]
    (let [hey (url-helper (fn [x] (str "/hey/" x)))]
      (is (= "https://example.com/hey/you" (hey "you"))
          "returns a helper function that generates a full url"))))


(deftest test-path-helper-test
  (let [hey (path-helper ["/hey" :name])]
    (is (= "/hey/you" (hey "you")) "returns a function that generates a path")
    (is (= "/hey/you" (hey {:name "you"}))
        "the function can take a map whose keys correspond to the keywords in the path-spec")
    (is (= "/hey/you" (hey {:name "you" :age 36}))
        "it should ignore extra keys if a map is given")))


(deftest test-blank
  (is (blank? "") "an empty string is blank")
  (is (blank? "   \t \n") "a string with only whitespace is blank")
  (is (blank? []) "an empty collection is blank")
  (is (blank? nil) "nil is blank")
  (is (blank? "" "" "" "") "it accepts multiple arguments"))


(deftest test-presence
  (is (nil? (presence "")) "it's nil if the argument is blank")
  (is (= "Ha!" (presence "Ha!")) "it's the value if the argument is present"))
