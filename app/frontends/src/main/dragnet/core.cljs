(ns dragnet.core
  (:require [clojure.string :as s]))


(defn ->type [key]
  (let [string (if (string? key) key (-> key name (s/replace "_" "-")))]
    (keyword "dragnet.core.type" string)))


(defn ->type-hierarchy [type-info]
  (let [types
        (->> type-info
             (map
              (fn [[parent children]]
                [(->type parent) (map ->type children)]))
             (into {::type [:dragnet.core.type/basic]}))]
    (reduce
     (fn [h [parent children]]
       (reduce
        (fn [h type]
          (derive h type parent)) h children))
       (make-hierarchy) types)))


(defn ->type-registry [type-registry]
  (reduce
   (fn [m [key data]]
     (assoc m (->type key) data))
   {}
   type-registry))


(defn type-name [type-registry type]
  (-> type-registry type :name))


(defn type-meta [type-registry type]
  (-> type-registry type :meta))


(defn ex-type
  "Return an ex-info exception with a message and data
  regarding a type look up error."
  [type-key]
  (ex-info (str "couldn't find a type named: " type-key)
           {:ex-type/key type-key}))


(comment
   (->type-hierarchy
    {:basic [:temporal :countable :boolean],
     :temporal [:time :date_and_time :date],
     :countable [:text :number :choice],
     :text [:phone :link :email :address :long_text],
     :number [:integer :decimal]})


   (->type-registry
 {:email
  {:name "Email",
   :meta {:fa_icon_class "fa-regular fa-envelope"}},
  :date
  {:name "Date",
   :meta {:fa_icon_class "fa-regular fa-clock"}},
  :long_text
  {:name "Paragraphs",
   :meta
   {:options
    {:countable
     {:type "boolean",
      :text "Calculate sentiment analysis score for text"}},
    :fa_icon_class "fa-regular fa-keyboard"}},
  :phone
  {:name "Phone Number",
   :meta {:fa_icon_class "fa-regular fa-envelope"}},
  :time
  {:name "Time",
   :meta {:fa_icon_class "fa-regular fa-clock"}},
  :integer
  {:name "Whole Number",
   :meta
   {:options
    {:countable
     {:type "boolean", :text "Calculate statistics", :default true}},
    :fa_icon_class "fa-regular fa-calculator"}},
  :decimal
  {:name "Decimal",
   :meta
   {:options
    {:countable
     {:type "boolean", :text "Calculate statistics", :default true}},
    :fa_icon_class "fa-regular fa-calculator"}},
  :choice
  {:name "Choice",
   :meta
   {:options
    {:multiple_answers
     {:type "boolean", :text "Allow multiple answers"},
     :countable {:type "boolean", :text "Calculate statistics"}},
    :fa_icon_class "fa-regular fa-square-check"}},
  :boolean
  {:name "Yes or No",
   :meta {:fa_icon_class "fa-regular fa-toggle-on"}},
  :date_and_time
  {:name "Date & Time",
   :meta {:fa_icon_class "fa-regular fa-clock"}},
  :text
  {:name "Text",
   :meta {:fa_icon_class "fa-regular fa-keyboard"}}}
    )
)
