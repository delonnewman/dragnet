(ns dragnet.shared.utils)

(defmacro validate-presence!
  [& variables]
  (let [vars (vec variables)]
    `(when (any-blank? ~vars)
      (let [missing#
            (->> (zipmap (quote ~variables) ~vars)
                 (filter #(blank? (%1 1)))
                 (into {}))]
        (throw (ex-blank :missing-variables missing#))))))

(defmacro echo
  [sym]
  `(do (println ~(name sym) (pr-str ~sym)) ~sym))

(defmacro pp
  [val]
  `(cljs.pprint/pprint ~val))

(defmacro pp-str
  [val]
  `(with-out-str (cljs.pprint/pprint ~val)))
