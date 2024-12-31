(ns build
  (:require [clojure.tools.build.api :as b]
            [clojure.string :as s]
            [clojure.edn :as edn]
            [cljs.compiler.api :as cljs]))

(defn git-current-sha []
  (b/git-process {:git-args "log -n 1 --format=\"%H\""}))

(def version (delay (->> (git-current-sha) (drop 1) (take 8) (s/join ""))))
(def basis (delay (b/create-basis {:project "deps.edn"})))
(def node-deps (delay (-> "./npm-deps.edn" slurp edn/read-string)))

(def source-dir "src/main")
(def root-out-dir "../../public/js")
(def editor-out-dir (str root-out-dir "/editor"))

(def editor-options
  {:output-dir "../../public/js/editor"
   :asset-path "/js/editor"
   :source-map true
   :install-deps true})

(def editor-dev-options
  (merge editor-options
         {:optimizations :none
          :browser-repl true
          :pretty-print true
          }))

(defn editor [_]
  (println (str "Building editor...\nVersion: " @version))
  (let [options (assoc editor-options :node-deps @node-deps)]
    (cljs/compile-root source-dir editor-out-dir options)))

(editor nil)
