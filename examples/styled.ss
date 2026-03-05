#!/bin/sh
#|
CHEZ_QT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_LIB="$(objdump -p "$CHEZ_QT_DIR/qt_chez_shim.so" 2>/dev/null | sed -n 's/.*RUNPATH *//p')"
export LD_LIBRARY_PATH="${VENDOR_LIB:+$VENDOR_LIB:}$CHEZ_QT_DIR:$LD_LIBRARY_PATH"
export CHEZ_QT_LIB="$CHEZ_QT_DIR"
exec scheme --libdirs "$CHEZ_QT_DIR" --script "$0" "$@"
|#
;;; styled.ss — Dark-themed split-pane app with scroll area, key events
;;;
;;; Demonstrates:
;;; - App-wide style sheet (dark theme)
;;; - QSplitter (horizontal split pane)
;;; - QScrollArea (scrollable content)
;;; - Keyboard event handling (F11 fullscreen, Ctrl+Q quit, key display)
;;; - Window state management (fullscreen toggle)

(import (chez-qt qt))

(define QT_KEY_Q 81)

(define (main)
  (with-qt-app app

    ;; Apply dark theme via app-wide style sheet
    (qt-app-set-style-sheet! app "
      QWidget { background-color: #2b2b2b; color: #e0e0e0; }
      QLabel { font-size: 14px; }
      QSplitter::handle { background-color: #555; }
      QTextEdit { background-color: #1e1e1e; color: #d4d4d4;
                  border: 1px solid #555; font-family: monospace; }
    ")

    ;; Main window
    (let* ((win (qt-main-window-create))
           (splitter (qt-splitter-create QT_HORIZONTAL))
           ;; Left pane: scrollable labels
           (scroll (qt-scroll-area-create))
           (scroll-content (qt-widget-create))
           (scroll-layout (qt-vbox-layout-create scroll-content))
           ;; Right pane: key event log
           (right-panel (qt-widget-create))
           (right-layout (qt-vbox-layout-create right-panel))
           (key-label (qt-label-create "Press any key..."))
           (log (qt-text-edit-create)))

      ;; Populate scroll area with many labels
      (let loop ((i 0))
        (when (< i 30)
          (qt-layout-add-widget! scroll-layout
            (qt-label-create (string-append "Item " (number->string i))))
          (loop (+ i 1))))

      (qt-scroll-area-set-widget! scroll scroll-content)
      (qt-scroll-area-set-widget-resizable! scroll #t)

      ;; Configure right panel
      (qt-text-edit-set-read-only! log #t)
      (qt-text-edit-set-placeholder! log "Key events will appear here...")
      (qt-layout-add-widget! right-layout key-label)
      (qt-layout-add-widget! right-layout log)

      ;; Set up splitter
      (qt-splitter-add-widget! splitter scroll)
      (qt-splitter-add-widget! splitter right-panel)
      (qt-splitter-set-sizes! splitter 300 500)
      (qt-splitter-set-handle-width! splitter 4)

      ;; Key handler
      (qt-on-key-press! win
        (lambda ()
          (let ((code (qt-last-key-code))
                (mods (qt-last-key-modifiers))
                (text (qt-last-key-text)))
            ;; Display current key
            (qt-label-set-text! key-label
              (string-append "Key: " (number->string code)
                             " Mods: " (number->string mods)
                             " Text: \"" text "\""))
            ;; Log it
            (qt-text-edit-append! log
              (string-append "code=" (number->string code)
                             " mods=" (number->string mods)
                             " text=\"" text "\""))
            ;; F11 = toggle fullscreen
            (when (= code QT_KEY_F11)
              (if (= (qt-widget-window-state win) QT_WINDOW_FULL_SCREEN)
                (qt-widget-show-normal! win)
                (qt-widget-show-fullscreen! win)))
            ;; Ctrl+Q = quit
            (when (and (= code QT_KEY_Q)
                       (not (= 0 (bitwise-and mods QT_MOD_CONTROL))))
              (qt-app-quit! app)))))

      ;; Assemble and show
      (qt-main-window-set-central-widget! win splitter)
      (qt-main-window-set-title! win "Styled App (F11=fullscreen, Ctrl+Q=quit)")
      (qt-widget-resize! win 800 600)
      (qt-widget-show! win)

      (qt-app-exec! app))))

(main)
