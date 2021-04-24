(import urllib.request urllib.error re webbrowser sys requests argparse)

(setv TITLE-REGEX (re.compile r"<\W*title\W*(.*)</title")
      WIKIPEDIA-TITLE-REGEX (re.compile "(.*) - Wikipedia")
      WIKI-RAND-URL "https://en.wikipedia.org/wiki/Special:Random"
      WIKI-RAND-IN-CAT-URL "https://en.wikipedia.org/wiki/Special:RandomInCategory/"
      RAND-WIKI-PAGE-NAME "Random page in category - Wikipedia")

(defn main [args]
  (setv args (CmdArgs args) again True)
  (while again
    (setv p (random-wikipedia-page (.replace (. args cat) " " "_"))
          page-title (get-page-title p))
    (if (= page-title RAND-WIKI-PAGE-NAME)
        (exit-invalid-cat (. args cat)))
    (if (-> (. args only-art) not (or (article? page-title)))
        (if (. args open-first)
            (do
              (webbrowser.open p)
              (setv again False))
            (= "y" (setx r (ask-open-wiki page-title)))
            (webbrowser.open p)
            (= r "q")
            (setv again False)))))

(defn article? [page]
  (not-in ":" page))

(defn get-title [text]
  (.group (re.search TITLE-REGEX text) 1))

(defn exit-invalid-cat [cat]
  (exit (+ "Category '" cat "' is invalid")))

(defn get-page-title [page-url]
  (-> page-url requests.get (. text) get-title))

(defn random-wikipedia-page [cat]
  (-> (if (none? cat) WIKI-RAND-URL
          (+ WIKI-RAND-IN-CAT-URL cat))
      urllib.request.urlopen
      .geturl))

(defn wiki-title [title]
  (.group (re.match WIKIPEDIA-TITLE-REGEX title) 1))

(defn input-lower-char [prompt]
  (-> prompt input .lower .strip first))

(defn ask-open [title]
  (input-lower-char f"Open \"{title}\"? [y/n/q] "))

(defn ask-open-wiki [wikipedia-title]
  (ask-open (wiki-title wikipedia-title)))

(defclass CmdArgs []
  (defn __init__ [self cmd-args]
    (setv args-dict (->
      (doto (argparse.ArgumentParser :prog "rand-wiki-page")
        (.add-argument "-f" "--open-first" :help "open the first random page"
          :action "store_true")
        (.add-argument "-a" "--only-articles"
          :help "exclude categories and other non-article pages" :action "store_true")
        (.add-argument "-c" "--cat" :help "category of the page"))
      (.parse-args cmd-args)
      (. __dict__)))
    (setv self.cat (get args-dict "cat")
          self.only-art (get args-dict "only_articles")
          self.open-first (get args-dict "open_first"))))

(if (= __name__ "__main__")
  (try
    (main (rest sys.argv))
  (except [e urllib.error.URLError]
    (exit (+ "URLError: " (-> e (. reason) str))))
  (except [e Exception]
    (exit e))))
