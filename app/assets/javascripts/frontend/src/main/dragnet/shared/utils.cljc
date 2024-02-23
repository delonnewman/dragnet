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


(defmacro pp
  [val]
  `(let [val# ~val] (cljs.pprint/pprint val#) val#))


(defmacro pp-str
  [val]
  `(with-out-str (cljs.pprint/pprint ~val)))


(defmacro ppt
  [tag val]
  `(let [val# ~val] (println ~tag (pp-str val#)) val#))


(defmacro echo
  [sym]
  `(ppt ~(name sym) ~sym))
