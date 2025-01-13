(ns dragnet.editor
  "The survey editor UI shell"
  (:require
   [cljs-http.client :as http]
   [cljs.core.async :refer [<! go]]
   [dragnet.editor.components :refer [survey-editor]]
   [dragnet.editor.core :as editor :refer [create-basis survey->update]]
   [dragnet.common.utils :as utils]
   [reagent.core :as r]
   [reagent.dom :as rdom]))


(def ^:dynamic *element-id* "survey-editor")
(def survey-id-attribute "data-survey-id")
(def state (r/atom {}))


(defn root-element []
  (js/document.getElementById *element-id*))


(defn survey-id []
  (when-let [elem (root-element)]
    (.getAttribute elem survey-id-attribute)))


(defn on-valid-page! []
  (utils/validate-presence! (root-element) (survey-id)))


(defn error-handler
  [state]
  (fn [res]
    (js/console.error "handling error" (utils/pp-str res))
    (swap! state assoc :errors (conj (state :errors)) (res :body))))


(defn update-survey
  [state]
  (let [survey (state :survey)
        update (survey->update survey)]
    (js/console.info "update-survey" (editor/survey-url survey))
    (go (let [res
              (<! (utils/http-request
                   :method :put
                   :url (editor/survey-url survey)
                   :transit-params update
                   :error-fn (error-handler state)))]
          (res :body)))))


(defn ui-renderer
  "Return a watcher for the editor's state that will
  render the editor UI to the given root element."
  []
  (fn [_ ref old new]
    (js/console.info "Rendering...")
    (when (or (:errors new) (editor/state-change? old new))
      (js/console.info "Last update" (editor/updated-at new))
      (rdom/render [survey-editor ref] (root-element)))))


(defn auto-updater
  "Return a watcher for the editor's state that will
  auto save the survey's latest edit"
  []
  (fn [_ ref old new]
    (when (editor/state-change? old new)
      (js/console.info "Saving changes...")
      (go (let [edit (<! (update-survey new))]
            (swap! ref assoc :edits (conj (@ref :edits) edit)))))))


(defn add-watchers
  []
  (add-watch state :render-ui (ui-renderer))
  (add-watch state :auto-update (auto-updater)))


(defn -main
  "Initialize survey editor UI"
  []
  (on-valid-page!)
  (js/console.info "Initializing editor for " (survey-id))
  (add-watchers)
  (go
    (let [res (<! (http/get (editor/survey-url (survey-id))))
          ui (create-basis (:body res))]
      (swap! state merge ui))))

(comment
  (editor/survey-url (survey-id))

  (go
    (let [result (<! (http/get (editor/survey-url (survey-id))))]
      (utils/pp (:body result))
    ))

  (def data
{:survey
 {:id "66f3d7ce-8e93-4379-9c13-c9d89e059f24",
  :name "Metropolis",
  :updated_at #inst "2025-01-06T22:30:56.543-00:00",
  :author_id "732b564e-1e68-46c1-a176-da45e2027902",
  :edits_status "saved",
  :author
  {:id "732b564e-1e68-46c1-a176-da45e2027902",
   :name "Delon Newman",
   :nickname "Delon"},
  :questions
  {"2e85312c-807c-4ac1-99d2-c9255efc9c60"
   {:id "2e85312c-807c-4ac1-99d2-c9255efc9c60",
    :text "Here's looking at you, kid.",
    :display_order 0,
    :required true,
    :question_options {},
    :type :boolean},
   "4108803e-870f-4f59-a1bf-610ca4956793"
   {:id "4108803e-870f-4f59-a1bf-610ca4956793",
    :text "Fasten your seatbelts. It's going to be a bumpy night.",
    :display_order 0,
    :required false,
    :question_options {},
    :type :integer},
   "e6e4547b-a993-42af-b239-309dbbaff2a5"
   {:id "e6e4547b-a993-42af-b239-309dbbaff2a5",
    :text "You will find only what you bring in.",
    :display_order 0,
    :required false,
    :question_options {},
    :type :text},
   "835ba3e4-8910-4a19-92e0-9a8243139f34"
   {:id "835ba3e4-8910-4a19-92e0-9a8243139f34",
    :text "Around the survivors a perimeter create.",
    :display_order 0,
    :required true,
    :question_options
    {10 {:id 10, :text "Sequi eius reprehenderit et.", :weight -2},
     11 {:id 11, :text "Quasi dolore numquam nobis.", :weight -1},
     12 {:id 12, :text "Quod atque est enim.", :weight 0},
     13 {:id 13, :text "Molestiae amet eum ut.", :weight 1},
     14 {:id 14, :text "Aperiam minus ullam dolorum.", :weight 2}},
    :type :choice},
   "4fee5c52-f7f6-4bf6-82c5-2acc1fe6aee4"
   {:id "4fee5c52-f7f6-4bf6-82c5-2acc1fe6aee4",
    :text "What we've got here is failure to communicate.",
    :display_order 0,
    :required false,
    :question_options
    {1 {:id 1, :text "Placeat qui sit voluptate.", :weight -2},
     2 {:id 2, :text "Consectetur eaque sit tempora.", :weight -1},
     3 {:id 3, :text "Et tempore rerum velit.", :weight 0},
     4 {:id 4, :text "Impedit consectetur fugit magni.", :weight 1},
     5 {:id 5, :text "Consequatur iusto porro ab.", :weight 2}},
    :type :choice},
   "1c7bef5e-36ed-42f5-a9c5-4eb7ae9bf2e9"
   {:id "1c7bef5e-36ed-42f5-a9c5-4eb7ae9bf2e9",
    :text "Good relations with the Wookiees, I have.",
    :display_order 0,
    :required false,
    :question_options {},
    :type :long_text},
   "3c33b4cb-c175-44b6-9dc6-91b9b3e34764"
   {:id "3c33b4cb-c175-44b6-9dc6-91b9b3e34764",
    :text "You talking to me?",
    :display_order 0,
    :required true,
    :question_options {},
    :type :date_and_time},
   "c85ae83b-f6eb-4001-a5b4-5fd02aab21cf"
   {:id "c85ae83b-f6eb-4001-a5b4-5fd02aab21cf",
    :text "Go ahead, make my day.",
    :display_order 0,
    :required false,
    :question_options {},
    :type :phone},
   "6ff2412f-cfb5-47e0-8f6a-6a90ca434524"
   {:id "6ff2412f-cfb5-47e0-8f6a-6a90ca434524",
    :text "Toto, I've got a feeling we're not in Kansas anymore.",
    :display_order 0,
    :required false,
    :question_options {},
    :type :phone},
   "f6979140-b1fa-4adb-a4a9-4b8116d71ff0"
   {:id "f6979140-b1fa-4adb-a4a9-4b8116d71ff0",
    :text "I'm going to make him an offer he can't refuse.",
    :display_order 0,
    :required false,
    :question_options {},
    :type :date},
   "a10217fe-9248-4fd1-98dd-f3a44f8c5183"
   {:id "a10217fe-9248-4fd1-98dd-f3a44f8c5183",
    :text "Frankly, my dear, I don’t give a damn.",
    :display_order 0,
    :required false,
    :question_options {},
    :type :date},
   "3179d592-6346-4325-b520-9beeda962158"
   {:id "3179d592-6346-4325-b520-9beeda962158",
    :text "Truly wonderful, the mind of a child is.",
    :display_order 0,
    :required false,
    :question_options
    {15
     {:id 15, :text "Quis vero veritatis reprehenderit.", :weight -1},
     16 {:id 16, :text "Iure illum nam sed.", :weight 0}},
    :type :choice},
   "ea7b4f73-1e24-42e4-bd00-f1ca2a41ded4"
   {:id "ea7b4f73-1e24-42e4-bd00-f1ca2a41ded4",
    :text "Greetings, programs!",
    :display_order 0,
    :required true,
    :question_options {},
    :type :decimal},
   "6a924b62-f146-4cf7-986e-b88f663252d0"
   {:id "6a924b62-f146-4cf7-986e-b88f663252d0",
    :text "All right, Mr. DeMille, I'm ready for my closeup.",
    :display_order 0,
    :required false,
    :question_options {},
    :type :long_text},
   "60b60fa4-151b-456f-b7a3-a9b3e5ec911f"
   {:id "60b60fa4-151b-456f-b7a3-a9b3e5ec911f",
    :text "May the Force be with you.",
    :display_order 0,
    :required false,
    :question_options {},
    :type :time},
   "d2fd9cea-df45-4a34-afa9-73d592e2aea6"
   {:id "d2fd9cea-df45-4a34-afa9-73d592e2aea6",
    :text "I love the smell of napalm in the morning.",
    :display_order 0,
    :required false,
    :question_options {},
    :type :time},
   "700af0d7-b6a7-4816-b7f7-41d6fd12bb11"
   {:id "700af0d7-b6a7-4816-b7f7-41d6fd12bb11",
    :text "Mudhole? Slimy? My home this is!",
    :display_order 0,
    :required true,
    :question_options
    {6 {:id 6, :text "Voluptas voluptas harum aut.", :weight -2},
     7 {:id 7, :text "Et et suscipit qui.", :weight -1},
     8 {:id 8, :text "A eaque sit quam.", :weight 0},
     9 {:id 9, :text "Quibusdam velit omnis possimus.", :weight 1}},
    :type :choice}}},
 :updated_at #inst "2025-01-06T22:30:56.543-00:00",
 :edits [],
:type_hierarchy
 {:basic [:temporal :countable :boolean],
  :temporal [:time :date_and_time :date],
  :countable [:text :number :choice],
  :text [:phone :link :email :address :long_text],
  :number [:integer :decimal]},
 :type_registry
 {:email
  {:name "Email",
   :slug "email",
   :symbol :email,
   :tags [:email :text :countable :basic],
   :meta {:fa_icon_class "fa-regular fa-envelope"}},
  :date
  {:name "Date",
   :slug "date",
   :symbol :date,
   :tags [:date :temporal :basic],
   :meta {:fa_icon_class "fa-regular fa-clock"}},
  :long_text
  {:name "Paragraphs",
   :slug "long_text",
   :symbol :long_text,
   :tags [:long_text :text :countable :basic],
   :meta
   {:options
    {:countable
     {:type "boolean",
      :text "Calculate sentiment analysis score for text"}},
    :fa_icon_class "fa-regular fa-keyboard"}},
  :phone
  {:name "Phone Number",
   :slug "phone",
   :symbol :phone,
   :tags [:phone :text :countable :basic],
   :meta {:fa_icon_class "fa-regular fa-envelope"}},
  :time
  {:name "Time",
   :slug "time",
   :symbol :time,
   :tags [:time :temporal :basic],
   :meta {:fa_icon_class "fa-regular fa-clock"}},
  :integer
  {:name "Whole Number",
   :slug "integer",
   :symbol :integer,
   :tags [:integer :number :countable :basic],
   :meta
   {:options
    {:countable
     {:type "boolean", :text "Calculate statistics", :default true}},
    :fa_icon_class "fa-regular fa-calculator"}},
  :decimal
  {:name "Decimal",
   :slug "decimal",
   :symbol :decimal,
   :tags [:decimal :number :countable :basic],
   :meta
   {:options
    {:countable
     {:type "boolean", :text "Calculate statistics", :default true}},
    :fa_icon_class "fa-regular fa-calculator"}},
  :choice
  {:name "Choice",
   :slug "choice",
   :symbol :choice,
   :tags [:choice :countable :basic],
   :meta
   {:options
    {:multiple_answers
     {:type "boolean", :text "Allow multiple answers"},
     :countable {:type "boolean", :text "Calculate statistics"}},
    :fa_icon_class "fa-regular fa-square-check"}},
  :boolean
  {:name "Yes or No",
   :slug "boolean",
   :symbol :boolean,
   :tags [:boolean :basic],
   :meta {:fa_icon_class "fa-regular fa-toggle-on"}},
  :date_and_time
  {:name "Date & Time",
   :slug "date_and_time",
   :symbol :date_and_time,
   :tags [:date_and_time :temporal :basic],
   :meta {:fa_icon_class "fa-regular fa-clock"}},
  :text
  {:name "Text",
   :slug "text",
   :symbol :text,
   :tags [:text :countable :basic],
   :meta {:fa_icon_class "fa-regular fa-keyboard"}}}
 }
)
  (editor/create-basis data)
  (do
    (reset! state {})
    (add-watchers)
    (swap! state merge (editor/create-basis data)))

  (dragnet.editor.components/question-card-body {:question/type {:test 1}})


  (def ui (create-basis data))
  (isa? (:dragnet.editor.core/type-hierarchy ui) :dragnet.core.type/boolean :dragnet.core/type)

  (-main)
  )
