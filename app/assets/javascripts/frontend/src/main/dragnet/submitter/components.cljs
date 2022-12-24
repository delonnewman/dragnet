(ns dragnet.submitter.components)

(defn reply-submitter
  [state]
  [:div.reply-submitter
   [:h1 (-> state :survey :name)]
   (for [question (->> state :survey :questions vals)]
      ^{:key (question :id)} [:h2 (question :text)])])
