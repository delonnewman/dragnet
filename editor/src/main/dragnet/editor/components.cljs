(ns dragnet.editor.components)

(defn survey-details [survey]
  [:div {:class "survey-details"}
   [:h1 (:name survey)]])

(defn survey-editor [survey]
  [survey-details survey])
