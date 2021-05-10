(import urllib.error re webbrowser requests argparse
        [urllib.request [urlopen]] [sys [argv]])

(setv TITLE-REGEX (re.compile r"<\W*title\W*(.*)</title")
      WIKIPEDIA-TITLE-REGEX (re.compile "(.*) - Wikipedia")
      WIKI-RAND-URL "https://en.wikipedia.org/wiki/Special:Random"
      WIKI-RAND-IN-CAT-URL "https://en.wikipedia.org/wiki/Special:RandomInCategory/"
      RAND-WIKI-PAGE-NAME "Random page in category - Wikipedia")

(defn main [args]
  (setv args (CmdArgs args)
        cat (. args cat)
        only-art (. args only-art)
        no-conf (. args no-conf)
        again True)
  (while again
    (setv p (random-wikipedia-page cat)
          page-title (get-page-title p))
    (if (= page-title RAND-WIKI-PAGE-NAME)
        (exit-invalid-cat cat)
    (if (or (not only-art) (article? page-title))
        (do (if (or no-conf (= "y" (setx r (ask-open-wiki page-title))))
                (webbrowser.open p))
            (if (or no-conf (= "q" r))
                (setv again False)))))))

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
      urlopen .geturl))

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
        (.add-argument "-n" "--no-conf" :action "store_true"
          :help "open a page without asking for confirmation")
        (.add-argument "-a" "--only-articles" :action "store_true"
          :help "exclude categories and other non-article pages")
        (.add-argument "-c" "--cat" :help "category of the page"))
      (.parse-args cmd-args)
      (. __dict__)))
    (setv self.cat (if (none? (setx cat (get args-dict "cat")))
                       None
                       (.replace cat " " "_"))
          self.only-art (get args-dict "only_articles")
          self.no-conf (get args-dict "no_conf"))))

(if (= __name__ "__main__")
  (try
    (main (rest argv))
  (except [e urllib.error.URLError]
    (exit (+ "URLError: " (-> e (. reason) str))))
  (except [e Exception]
    (exit e))))
