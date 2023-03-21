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
  `(do (println ~(name sym) ~sym) ~sym))
