;;; keyboard.ss — Key event viewer and shortcut demo.
;;;
;;; Demonstrates: qt-on-key-press!, qt-last-key-code, qt-last-key-modifiers,
;;; qt-last-key-text, QShortcut (create, set-key, enabled, on-activated, destroy),
;;; key constants (QT_KEY_*), modifier constants (QT_MOD_*).

(import (chez-qt qt))

;; Qt key codes for letters and digits (not in the core constants)
(define QT_KEY_A 65) (define QT_KEY_B 66) (define QT_KEY_C 67)
(define QT_KEY_D 68) (define QT_KEY_E 69) (define QT_KEY_F 70)
(define QT_KEY_G 71) (define QT_KEY_H 72) (define QT_KEY_I 73)
(define QT_KEY_J 74) (define QT_KEY_K 75) (define QT_KEY_L 76)
(define QT_KEY_M 77) (define QT_KEY_N 78) (define QT_KEY_O 79)
(define QT_KEY_P 80) (define QT_KEY_Q 81) (define QT_KEY_R 82)
(define QT_KEY_S 83) (define QT_KEY_T 84) (define QT_KEY_U 85)
(define QT_KEY_V 86) (define QT_KEY_W 87) (define QT_KEY_X 88)
(define QT_KEY_Y 89) (define QT_KEY_Z 90)
(define QT_KEY_0 48) (define QT_KEY_1 49) (define QT_KEY_2 50)
(define QT_KEY_3 51) (define QT_KEY_4 52) (define QT_KEY_5 53)
(define QT_KEY_6 54) (define QT_KEY_7 55) (define QT_KEY_8 56)
(define QT_KEY_9 57)

(define (key-name code)
  "Convert a key code to a human-readable name."
  (cond
    ;; Letters
    ((= code QT_KEY_A) "A") ((= code QT_KEY_B) "B") ((= code QT_KEY_C) "C")
    ((= code QT_KEY_D) "D") ((= code QT_KEY_E) "E") ((= code QT_KEY_F) "F")
    ((= code QT_KEY_G) "G") ((= code QT_KEY_H) "H") ((= code QT_KEY_I) "I")
    ((= code QT_KEY_J) "J") ((= code QT_KEY_K) "K") ((= code QT_KEY_L) "L")
    ((= code QT_KEY_M) "M") ((= code QT_KEY_N) "N") ((= code QT_KEY_O) "O")
    ((= code QT_KEY_P) "P") ((= code QT_KEY_Q) "Q") ((= code QT_KEY_R) "R")
    ((= code QT_KEY_S) "S") ((= code QT_KEY_T) "T") ((= code QT_KEY_U) "U")
    ((= code QT_KEY_V) "V") ((= code QT_KEY_W) "W") ((= code QT_KEY_X) "X")
    ((= code QT_KEY_Y) "Y") ((= code QT_KEY_Z) "Z")
    ;; Digits
    ((= code QT_KEY_0) "0") ((= code QT_KEY_1) "1") ((= code QT_KEY_2) "2")
    ((= code QT_KEY_3) "3") ((= code QT_KEY_4) "4") ((= code QT_KEY_5) "5")
    ((= code QT_KEY_6) "6") ((= code QT_KEY_7) "7") ((= code QT_KEY_8) "8")
    ((= code QT_KEY_9) "9")
    ;; Special keys
    ((= code QT_KEY_ESCAPE) "Escape") ((= code QT_KEY_TAB) "Tab")
    ((= code QT_KEY_BACKSPACE) "Backspace") ((= code QT_KEY_RETURN) "Return")
    ((= code QT_KEY_ENTER) "Enter") ((= code QT_KEY_INSERT) "Insert")
    ((= code QT_KEY_DELETE) "Delete") ((= code QT_KEY_SPACE) "Space")
    ((= code QT_KEY_UP) "Up") ((= code QT_KEY_DOWN) "Down")
    ((= code QT_KEY_LEFT) "Left") ((= code QT_KEY_RIGHT) "Right")
    ((= code QT_KEY_HOME) "Home") ((= code QT_KEY_END) "End")
    ((= code QT_KEY_PAGE_UP) "PageUp") ((= code QT_KEY_PAGE_DOWN) "PageDown")
    ;; Function keys
    ((= code QT_KEY_F1) "F1") ((= code QT_KEY_F2) "F2")
    ((= code QT_KEY_F3) "F3") ((= code QT_KEY_F4) "F4")
    ((= code QT_KEY_F5) "F5") ((= code QT_KEY_F6) "F6")
    ((= code QT_KEY_F7) "F7") ((= code QT_KEY_F8) "F8")
    ((= code QT_KEY_F9) "F9") ((= code QT_KEY_F10) "F10")
    ((= code QT_KEY_F11) "F11") ((= code QT_KEY_F12) "F12")
    (else (format #f "0x~x" code))))

(define (modifier-string mods)
  "Build a modifier string like 'Ctrl+Shift+'."
  (string-append
    (if (not (= (bitwise-and mods QT_MOD_CONTROL) 0)) "Ctrl+" "")
    (if (not (= (bitwise-and mods QT_MOD_SHIFT) 0)) "Shift+" "")
    (if (not (= (bitwise-and mods QT_MOD_ALT) 0)) "Alt+" "")
    (if (not (= (bitwise-and mods QT_MOD_META) 0)) "Meta+" "")))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-vbox-layout-create central))

           ;; Key display area
           (key-display (qt-label-create "Press any key..."))
           (code-label (qt-label-create "Code: -"))
           (mods-label (qt-label-create "Modifiers: none"))
           (text-label (qt-label-create "Text: -"))
           (combo-label (qt-label-create "Combo: -"))

           ;; Key history
           (history (qt-plain-text-edit-create))

           ;; Shortcut demo area
           (shortcut-group (qt-group-box-create "Keyboard Shortcuts"))
           (shortcut-layout (qt-vbox-layout-create shortcut-group))
           (shortcut-log (qt-label-create "No shortcut triggered yet"))
           (sc-enable-btn (qt-push-button-create "Toggle Ctrl+E shortcut"))

           ;; Shortcuts
           (sc1 (qt-shortcut-create "Ctrl+G" win))
           (sc2 (qt-shortcut-create "Ctrl+E" win))
           (sc3 (qt-shortcut-create "F5" win))
           (key-count 0))

      ;; --- Key display styling ---
      (qt-widget-set-style-sheet! key-display
        "font-size: 48px; font-weight: bold; padding: 20px; background: #2c3e50; color: #ecf0f1; border-radius: 8px;")
      (qt-label-set-alignment! key-display QT_ALIGN_CENTER)
      (qt-widget-set-minimum-size! key-display 400 100)

      (for-each
        (lambda (lbl) (qt-widget-set-style-sheet! lbl "font-family: monospace; font-size: 13px;"))
        (list code-label mods-label text-label combo-label))

      ;; --- Key event handler ---
      (qt-on-key-press! win
        (lambda ()
          (let* ((code (qt-last-key-code))
                 (mods (qt-last-key-modifiers))
                 (text (qt-last-key-text))
                 (name (key-name code))
                 (mod-str (modifier-string mods))
                 (combo (string-append mod-str name)))
            (set! key-count (+ key-count 1))
            (qt-label-set-text! key-display combo)
            (qt-label-set-text! code-label (format #f "Code: ~a (0x~x)" code code))
            (qt-label-set-text! mods-label
              (format #f "Modifiers: ~a"
                (if (= mods QT_MOD_NONE) "none" mod-str)))
            (qt-label-set-text! text-label (format #f "Text: ~s" text))
            (qt-label-set-text! combo-label (format #f "Combo: ~a" combo))
            (qt-plain-text-edit-append! history
              (format #f "#~a ~a  code=~a mods=~a text=~s"
                key-count combo code mods text))
            (qt-main-window-set-status-bar-text! win
              (format #f "~a key events captured" key-count)))))

      ;; --- History ---
      (qt-plain-text-edit-set-read-only! history #t)
      (qt-plain-text-edit-set-max-block-count! history 100)

      ;; --- Shortcuts ---
      (qt-on-shortcut-activated! sc1
        (lambda ()
          (qt-label-set-text! shortcut-log "Ctrl+G triggered! (Chez)")
          (qt-plain-text-edit-append! history ">>> SHORTCUT: Ctrl+G")))

      (qt-on-shortcut-activated! sc2
        (lambda ()
          (qt-label-set-text! shortcut-log "Ctrl+E triggered! (Edit)")
          (qt-plain-text-edit-append! history ">>> SHORTCUT: Ctrl+E")))

      (qt-on-shortcut-activated! sc3
        (lambda ()
          (qt-label-set-text! shortcut-log "F5 triggered! (Refresh)")
          (qt-plain-text-edit-append! history ">>> SHORTCUT: F5")))

      ;; Toggle Ctrl+E enabled/disabled
      (qt-on-clicked! sc-enable-btn
        (lambda ()
          (let ((currently (qt-shortcut-enabled? sc2)))
            (qt-shortcut-set-enabled! sc2 (not currently))
            (qt-label-set-text! shortcut-log
              (format #f "Ctrl+E shortcut: ~a" (if currently "DISABLED" "ENABLED"))))))

      ;; Assemble shortcut group
      (qt-layout-add-widget! shortcut-layout
        (qt-label-create "Registered: Ctrl+G, Ctrl+E, F5"))
      (qt-layout-add-widget! shortcut-layout shortcut-log)
      (qt-layout-add-widget! shortcut-layout sc-enable-btn)

      ;; --- Main layout ---
      (qt-layout-add-widget! layout key-display)
      (qt-layout-add-spacing! layout 5)
      (qt-layout-add-widget! layout code-label)
      (qt-layout-add-widget! layout mods-label)
      (qt-layout-add-widget! layout text-label)
      (qt-layout-add-widget! layout combo-label)
      (qt-layout-add-spacing! layout 10)
      (qt-layout-add-widget! layout shortcut-group)
      (qt-layout-add-widget! layout history)

      ;; --- Show ---
      (qt-main-window-set-central-widget! win central)
      (qt-main-window-set-title! win "Keyboard Event Viewer")
      (qt-widget-resize! win 600 650)
      (qt-widget-show! win)
      (qt-main-window-set-status-bar-text! win "Press any key to see its code and modifiers")
      (qt-app-exec! app)

      ;; Cleanup shortcuts
      (qt-shortcut-destroy! sc1)
      (qt-shortcut-destroy! sc2)
      (qt-shortcut-destroy! sc3))))

(main)
