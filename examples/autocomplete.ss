;;; autocomplete.ss — QSettings, QCompleter, QToolTip demo
;;; Search with history, auto-complete from past searches

(import (chez-qt qt))

(define *max-history* 50)

;; Simple string split on newline
(define (split-newlines s)
  (let loop ((i 0) (start 0) (result '()))
    (cond
      ((= i (string-length s))
       (reverse (if (= start i) result (cons (substring s start i) result))))
      ((char=? (string-ref s i) #\newline)
       (loop (+ i 1) (+ i 1) (cons (substring s start i) result)))
      (else (loop (+ i 1) start result)))))

;; Simple string join
(define (join-newlines lst)
  (if (null? lst) ""
    (let loop ((rest (cdr lst)) (acc (car lst)))
      (if (null? rest) acc
        (loop (cdr rest) (string-append acc "\n" (car rest)))))))

(define (take lst n)
  (if (or (zero? n) (null? lst)) '()
    (cons (car lst) (take (cdr lst) (- n 1)))))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-vbox-layout-create central))

           ;; Settings
           (settings (qt-settings-create "ChezQt" "autocomplete"))

           ;; Search bar
           (search-frame (qt-frame-create))
           (search-layout (qt-hbox-layout-create search-frame))
           (search-edit (qt-line-edit-create))
           (search-btn (qt-push-button-create "Search"))
           (clear-btn (qt-push-button-create "Clear History"))

           ;; Results area
           (results (qt-text-browser-create))

           ;; Load saved history
           (saved (qt-settings-value-string settings "history" ""))
           (history (if (string=? saved "")
                      '()
                      (split-newlines saved)))

           ;; Completer from history
           (completer (qt-completer-create history)))

      ;; Configure search bar
      (qt-line-edit-set-placeholder! search-edit "Type to search...")
      (qt-widget-set-tooltip! search-edit "Enter a search term — previous searches auto-complete")
      (qt-widget-set-whats-this! search-edit "Type a search query. Previous searches are remembered.")
      (qt-widget-set-tooltip! search-btn "Add this search to history")
      (qt-widget-set-tooltip! clear-btn "Remove all saved searches")
      (qt-frame-set-frame-shape! search-frame QT_FRAME_STYLED_PANEL)
      (qt-frame-set-frame-shadow! search-frame QT_FRAME_RAISED)

      ;; Attach completer
      (qt-completer-set-case-sensitivity! completer #f)
      (qt-completer-set-filter-mode! completer QT_MATCH_CONTAINS)
      (qt-completer-set-max-visible-items! completer 10)
      (qt-line-edit-set-completer! search-edit completer)

      ;; Build search layout
      (qt-layout-add-widget! search-layout search-edit)
      (qt-layout-add-widget! search-layout search-btn)
      (qt-layout-add-widget! search-layout clear-btn)

      ;; Initial results
      (qt-text-browser-set-html! results
        (string-append
          "<h2>Search Demo</h2>"
          "<p>Type a search term and press <b>Search</b>.</p>"
          "<p><i>" (number->string (length history)) " saved searches.</i></p>"))

      ;; Build main layout
      (qt-layout-add-widget! layout search-frame)
      (qt-layout-add-widget! layout results)
      (qt-layout-set-spacing! layout 8)
      (qt-layout-set-margins! layout 10 10 10 10)

      ;; Status bar
      (qt-main-window-set-status-bar-text! win
        (string-append (number->string (length history)) " searches in history"))

      ;; Search action
      (let ((do-search
              (lambda ()
                (let ((query (qt-line-edit-text search-edit)))
                  (when (not (string=? query ""))
                    ;; Add to history (deduplicate)
                    (when (not (member query history))
                      (set! history (cons query history))
                      ;; Trim to max
                      (when (> (length history) *max-history*)
                        (set! history (take history *max-history*)))
                      ;; Update completer model
                      (qt-completer-set-model-strings! completer history)
                      ;; Persist
                      (qt-settings-set-string! settings "history"
                        (join-newlines history))
                      (qt-settings-sync! settings))
                    ;; Show result
                    (qt-text-browser-set-html! results
                      (string-append
                        "<h2>Search Results</h2>"
                        "<p>You searched for: <b>" query "</b></p>"
                        "<hr>"
                        "<p><i>(This is a demo — no actual search is performed.)</i></p>"
                        "<h3>History (" (number->string (length history)) " entries)</h3>"
                        "<ul>"
                        (apply string-append
                          (map (lambda (h) (string-append "<li>" h "</li>")) history))
                        "</ul>"))
                    ;; Update status
                    (qt-main-window-set-status-bar-text! win
                      (string-append "Searched: \"" query "\" — "
                        (number->string (length history)) " in history"))
                    ;; Clear input
                    (qt-line-edit-set-text! search-edit ""))))))

        ;; Connect search button
        (qt-on-clicked! search-btn do-search)

        ;; Connect Enter key
        (qt-on-return-pressed! search-edit do-search)

        ;; Connect completer selection
        (qt-on-completer-activated! completer
          (lambda (text)
            (qt-text-browser-set-html! results
              (string-append
                "<h2>Re-search</h2>"
                "<p>Auto-completed: <b>" text "</b></p>"
                "<hr>"
                "<p><i>Selected from history.</i></p>"))
            (qt-main-window-set-status-bar-text! win
              (string-append "Auto-completed: \"" text "\""))))

        ;; Clear history button
        (qt-on-clicked! clear-btn
          (lambda ()
            (set! history '())
            (qt-completer-set-model-strings! completer history)
            (qt-settings-clear! settings)
            (qt-settings-sync! settings)
            (qt-text-browser-set-html! results
              "<h2>History Cleared</h2><p>All saved searches have been removed.</p>")
            (qt-main-window-set-status-bar-text! win "History cleared"))))

      ;; Window setup
      (qt-main-window-set-central-widget! win central)
      (qt-main-window-set-title! win "Auto-Complete Search")
      (qt-widget-resize! win 600 500)
      (qt-widget-show! win)

      ;; Show tooltip at startup
      (qt-tooltip-show-text! 300 200 "Start typing to see auto-complete suggestions!" search-edit)

      (qt-app-exec! app)

      ;; Cleanup
      (qt-settings-destroy! settings))))

(main)
