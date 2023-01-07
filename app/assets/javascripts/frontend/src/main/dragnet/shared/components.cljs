(ns dragnet.shared.components
  (:require [clojure.string :as s]))

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
