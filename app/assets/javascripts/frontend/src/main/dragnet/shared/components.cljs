(ns dragnet.shared.components
  (:require
   [clojure.string :as s]
   [dragnet.shared.core :refer
    [question-id long-answer? multiple-answers? include-time? include-date?]]
   [dragnet.shared.utils :refer [form-name]]))

(defn icon
  ([style name]
   (icon style name nil {}))
  ([style name x]
   (if (map? x)
     (icon style name nil x)
     (icon style name x {})))
  ([style name text opts]
   (let [cls (conj [style (str "fa-" name)] (opts :class))
         ico [:i (merge opts {:class (s/join " " cls)})]]
     (if-not text
       ico
       [:span ico " " text]))))

(defn icon-button
  [& {:keys [on-click icon-style icon-name title]}]
  [:button.btn.btn-light
   {:type "button"
    :on-click on-click
    :title title}
   (icon icon-style icon-name)])

(defn remove-button
  [opts]
  (icon-button (merge opts {:icon-style "fa-solid" :icon-name "xmark" :title "Remove"})))

(defn switch
  [& {:keys [id checked on-change label style class-name]}]
  [:div.form-check.form-switch {:style style :class-name class-name}
   [:input.form-check-input
    {:id id
     :type "checkbox"
     :on-change on-change
     :checked checked}]
   [:label.form-check-label {:for id} label]])

;; FIXME: the styling is editor specific
(defn text-field
  [& {:keys [id class style default-value on-change title]}]
  [:input.text-field.w-100.border-bottom
   {:class class
    :default-value default-value
    :title title
    :aria-label title
    :type "text"
    :on-blur on-change
    :style (merge style {:border "none"})}])

(defn text-prompt
  [& {:keys [id name value long]}]
  (if long
    [:textarea.form-control {:id id :name name :rows 3 :data-question-type "text"} value]
    [:input.form-control {:id id :name name :type "text" :data-question-type "text" :default-value value}]))

(defn choice-prompt
  [& {:keys [id name options value multi]}]
  (let [type (if multi "checkbox" "radio")]
    (for [{text :text opt-id :id} options]
      (let [dom-id (str id "-option-" opt-id)]
        ^{:key dom-id} [:div.form-check
                        [:input.form-check-input
                         {:type type :id dom-id :name name :value opt-id
                          :data-question-type "choice"
                          :default-checked (= opt-id value)}]
                        [:label.form-check-label {:for dom-id} text]]))))

(defn- time-opts->input-type
  [time date]
  (cond
    (and time date) "datetime-local"
    time "time"
    date "date"
    :else "datetime-local"))

(defn time-prompt
  [& {:keys [id name time date]}]
  [:input.form-control
   {:id id :type (time-opts->input-type time date)
    :name name
    :data-quesiton-type "time"
    :data-time-options (cond (and time date) "time date" time "time" date "date")}])

(defn number-prompt
  [& {:keys [id name]}]
  [:input.form-control {:id id :type "number" :name name}])

(def ^:private prompt-bodies
  {"text"
   (fn [q & {:keys [prefix class-name]}]
     (text-prompt
      :id (question-id q)
      :class-name class-name
      :name (form-name (concat prefix [(:id q) :value]))
      :long (long-answer? q)))
   "choice"
   (fn [q & {:keys [prefix class-name]}]
     (choice-prompt
      :id (question-id q)
      :class-name class-name
      :name (form-name (concat prefix [(:id q) :value]))
      :options (->> q :question_options vals)
      :multi (multiple-answers? q)))
   "time"
   (fn [q & {:keys [prefix class-name]}]
     (time-prompt
      :id (question-id q)
      :class-name class-name
      :name (form-name (concat prefix [(:id q) :value]))
      :time (include-time? q)
      :date (include-date? q)))
   "number"
   (fn [q & {:keys [prefix class-name]}]
     (number-prompt
      :id (question-id q)
      :class-name class-name
      :name (form-name (concat prefix [(:id q) :value]))))
   })

(defn prompt-body
  [q & {:keys [form-name-prefix class-name]}]
  (when-let [body (prompt-bodies (-> q :question_type :slug))]
    (body q :prefix form-name-prefix :class-name class-name)))
