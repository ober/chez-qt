#!/bin/sh
#|
CHEZ_QT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_LIB="$(objdump -p "$CHEZ_QT_DIR/qt_chez_shim.so" 2>/dev/null | sed -n 's/.*RUNPATH *//p')"
export LD_LIBRARY_PATH="${VENDOR_LIB:+$VENDOR_LIB:}$CHEZ_QT_DIR:$LD_LIBRARY_PATH"
export CHEZ_QT_LIB="$CHEZ_QT_DIR"
exec scheme --libdirs "$CHEZ_QT_DIR" --script "$0" "$@"
|#
;;; dialogs.ss — Showcase of all dialog types.
;;;
;;; Demonstrates: QProgressDialog, QInputDialog (get-text, get-int,
;;; get-double, get-item), QFontDialog, QColorDialog, QMessageBox,
;;; QFileDialog (open, save, directory).

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (main-layout (qt-vbox-layout-create central))
           (log-area (qt-plain-text-edit-create))

           ;; --- Input Dialogs Section ---
           (input-group (qt-group-box-create "Input Dialogs"))
           (input-layout (qt-grid-layout-create input-group))
           (btn-text (qt-push-button-create "Get Text"))
           (btn-int (qt-push-button-create "Get Integer"))
           (btn-double (qt-push-button-create "Get Double"))
           (btn-item (qt-push-button-create "Get Item"))

           ;; --- Message Box Section ---
           (msg-group (qt-group-box-create "Message Boxes"))
           (msg-layout (qt-grid-layout-create msg-group))
           (btn-info (qt-push-button-create "Information"))
           (btn-warn (qt-push-button-create "Warning"))
           (btn-question (qt-push-button-create "Question"))
           (btn-critical (qt-push-button-create "Critical"))

           ;; --- File Dialog Section ---
           (file-group (qt-group-box-create "File Dialogs"))
           (file-layout (qt-hbox-layout-create file-group))
           (btn-open (qt-push-button-create "Open File"))
           (btn-save (qt-push-button-create "Save File"))
           (btn-dir (qt-push-button-create "Open Directory"))

           ;; --- Chooser Section ---
           (chooser-group (qt-group-box-create "Chooser Dialogs"))
           (chooser-layout (qt-hbox-layout-create chooser-group))
           (btn-font (qt-push-button-create "Font Dialog"))
           (btn-color (qt-push-button-create "Color Dialog"))
           (btn-progress (qt-push-button-create "Progress Dialog")))

      (define (log! msg)
        (qt-plain-text-edit-append! log-area msg))

      (qt-plain-text-edit-set-read-only! log-area #t)
      (qt-plain-text-edit-set-max-block-count! log-area 200)

      ;; === Input Dialogs ===
      (qt-on-clicked! btn-text
        (lambda ()
          (let ((result (qt-input-dialog-get-text win "Text Input" "Enter your name:" "World")))
            (if result
              (log! (format #f "Text: ~a" result))
              (log! "Text: (cancelled)")))))

      (qt-on-clicked! btn-int
        (lambda ()
          (let ((result (qt-input-dialog-get-int win "Integer Input" "Pick a number:" 42 0 100 5)))
            (if result
              (log! (format #f "Integer: ~a" result))
              (log! "Integer: (cancelled)")))))

      (qt-on-clicked! btn-double
        (lambda ()
          (let ((result (qt-input-dialog-get-double win "Double Input" "Enter temperature:" 98.6 -100.0 200.0 2)))
            (if result
              (log! (format #f "Double: ~a" result))
              (log! "Double: (cancelled)")))))

      (qt-on-clicked! btn-item
        (lambda ()
          (let ((result (qt-input-dialog-get-item win "Item Selection" "Choose a language:"
                          (list "Chez" "Scheme" "Racket" "Clojure" "Haskell") 0 #f)))
            (if result
              (log! (format #f "Item: ~a" result))
              (log! "Item: (cancelled)")))))

      (qt-grid-layout-add-widget! input-layout btn-text 0 0)
      (qt-grid-layout-add-widget! input-layout btn-int 0 1)
      (qt-grid-layout-add-widget! input-layout btn-double 1 0)
      (qt-grid-layout-add-widget! input-layout btn-item 1 1)

      ;; === Message Boxes ===
      (qt-on-clicked! btn-info
        (lambda ()
          (qt-message-box-information win "Information" "This is an informational message.")
          (log! "Message: Information shown")))

      (qt-on-clicked! btn-warn
        (lambda ()
          (qt-message-box-warning win "Warning" "Something might go wrong!")
          (log! "Message: Warning shown")))

      (qt-on-clicked! btn-question
        (lambda ()
          (let ((result (qt-message-box-question win "Question" "Do you want to continue?")))
            (log! (format #f "Question result: ~a" result)))))

      (qt-on-clicked! btn-critical
        (lambda ()
          (qt-message-box-critical win "Error" "A critical error has occurred!")
          (log! "Message: Critical shown")))

      (qt-grid-layout-add-widget! msg-layout btn-info 0 0)
      (qt-grid-layout-add-widget! msg-layout btn-warn 0 1)
      (qt-grid-layout-add-widget! msg-layout btn-question 1 0)
      (qt-grid-layout-add-widget! msg-layout btn-critical 1 1)

      ;; === File Dialogs ===
      (qt-on-clicked! btn-open
        (lambda ()
          (let ((path (qt-file-dialog-open-file win "Open File" "All Files (*)")))
            (if (> (string-length path) 0)
              (log! (format #f "Open: ~a" path))
              (log! "Open: (cancelled)")))))

      (qt-on-clicked! btn-save
        (lambda ()
          (let ((path (qt-file-dialog-save-file win "Save File" "All Files (*)")))
            (if (> (string-length path) 0)
              (log! (format #f "Save: ~a" path))
              (log! "Save: (cancelled)")))))

      (qt-on-clicked! btn-dir
        (lambda ()
          (let ((path (qt-file-dialog-open-directory win "Choose Directory")))
            (if (> (string-length path) 0)
              (log! (format #f "Directory: ~a" path))
              (log! "Directory: (cancelled)")))))

      (qt-layout-add-widget! file-layout btn-open)
      (qt-layout-add-widget! file-layout btn-save)
      (qt-layout-add-widget! file-layout btn-dir)

      ;; === Chooser Dialogs ===
      (qt-on-clicked! btn-font
        (lambda ()
          (let ((f (qt-font-dialog-get-font win)))
            (if f
              (begin
                (log! (format #f "Font: ~a ~apt~a~a"
                  (qt-font-family f) (qt-font-point-size f)
                  (if (qt-font-bold? f) " Bold" "")
                  (if (qt-font-italic? f) " Italic" "")))
                (qt-font-destroy! f))
              (log! "Font: (cancelled)")))))

      (qt-on-clicked! btn-color
        (lambda ()
          (let ((c (qt-color-dialog-get-color "#3498db" win)))
            (if c
              (begin
                (log! (format #f "Color: ~a (R:~a G:~a B:~a A:~a)"
                  (qt-color-name c)
                  (qt-color-red c) (qt-color-green c)
                  (qt-color-blue c) (qt-color-alpha c)))
                (qt-color-destroy! c))
              (log! "Color: (cancelled)")))))

      (qt-on-clicked! btn-progress
        (lambda ()
          (let ((pd (qt-progress-dialog-create "Processing items..." "Cancel" 0 100 win)))
            (qt-progress-dialog-set-minimum-duration! pd 0)
            (qt-progress-dialog-set-auto-close! pd #f)
            (qt-progress-dialog-set-auto-reset! pd #f)
            (qt-widget-show! pd)
            ;; Simulate work with timer
            (let ((step 0)
                  (timer (qt-timer-create)))
              (qt-on-timeout! timer
                (lambda ()
                  (if (or (>= step 100) (qt-progress-dialog-was-canceled? pd))
                    (begin
                      (qt-timer-stop! timer)
                      (qt-timer-destroy! timer)
                      (if (qt-progress-dialog-was-canceled? pd)
                        (log! (format #f "Progress: Canceled at ~a%" step))
                        (log! "Progress: Completed!"))
                      (qt-progress-dialog-reset! pd)
                      (qt-widget-close! pd))
                    (begin
                      (set! step (+ step 2))
                      (qt-progress-dialog-set-value! pd step)
                      (qt-progress-dialog-set-label-text! pd
                        (format #f "Processing item ~a of 100..." step))))))
              (qt-timer-start! timer 50)))))

      (qt-layout-add-widget! chooser-layout btn-font)
      (qt-layout-add-widget! chooser-layout btn-color)
      (qt-layout-add-widget! chooser-layout btn-progress)

      ;; === Main Layout ===
      (qt-layout-add-widget! main-layout input-group)
      (qt-layout-add-widget! main-layout msg-group)
      (qt-layout-add-widget! main-layout file-group)
      (qt-layout-add-widget! main-layout chooser-group)
      (qt-layout-add-widget! main-layout log-area)

      ;; === Show ===
      (qt-main-window-set-central-widget! win central)
      (qt-main-window-set-title! win "Dialog Showcase")
      (qt-widget-resize! win 550 650)
      (qt-widget-show! win)
      (qt-app-exec! app))))

(main)
