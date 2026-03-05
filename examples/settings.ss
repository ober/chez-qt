#!/bin/sh
#|
CHEZ_QT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_LIB="$(objdump -p "$CHEZ_QT_DIR/qt_chez_shim.so" 2>/dev/null | sed -n 's/.*RUNPATH *//p')"
export LD_LIBRARY_PATH="${VENDOR_LIB:+$VENDOR_LIB:}$CHEZ_QT_DIR:$LD_LIBRARY_PATH"
export CHEZ_QT_LIB="$CHEZ_QT_DIR"
exec scheme --libdirs "$CHEZ_QT_DIR" --script "$0" "$@"
|#
;;; settings.ss — Radio buttons, button groups, group boxes
;;;
;;; Demonstrates:
;;; - QGroupBox with title and checkable mode
;;; - QRadioButton with exclusive button groups
;;; - QButtonGroup for mutual exclusion
;;; - Style sheet theming

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-vbox-layout-create central))

           ;; --- Theme Group Box ---
           (theme-group (qt-group-box-create "Theme"))
           (theme-layout (qt-vbox-layout-create theme-group))
           (theme-bg (qt-button-group-create))
           (r-light (qt-radio-button-create "Light"))
           (r-dark  (qt-radio-button-create "Dark"))
           (r-auto  (qt-radio-button-create "System Default"))

           ;; --- Font Size Group Box ---
           (font-group (qt-group-box-create "Font Size"))
           (font-layout (qt-vbox-layout-create font-group))
           (font-bg (qt-button-group-create))
           (r-small  (qt-radio-button-create "Small (10pt)"))
           (r-medium (qt-radio-button-create "Medium (12pt)"))
           (r-large  (qt-radio-button-create "Large (14pt)"))

           ;; --- Optional Features (checkable group box) ---
           (features-group (qt-group-box-create "Optional Features"))
           (features-layout (qt-vbox-layout-create features-group))
           (cb-spell   (qt-check-box-create "Spell check"))
           (cb-auto    (qt-check-box-create "Auto-save"))
           (cb-line    (qt-check-box-create "Show line numbers"))

           ;; --- Status ---
           (status-label (qt-label-create "Select your preferences"))

           ;; --- Buttons ---
           (btn-row (qt-widget-create))
           (btn-layout (qt-hbox-layout-create btn-row))
           (btn-apply (qt-push-button-create "Apply"))
           (btn-reset (qt-push-button-create "Reset")))

      ;; Setup theme radio buttons
      (qt-button-group-add-button! theme-bg r-light 0)
      (qt-button-group-add-button! theme-bg r-dark  1)
      (qt-button-group-add-button! theme-bg r-auto  2)
      (qt-layout-add-widget! theme-layout r-light)
      (qt-layout-add-widget! theme-layout r-dark)
      (qt-layout-add-widget! theme-layout r-auto)
      (qt-radio-button-set-checked! r-light #t)

      ;; Setup font size radio buttons
      (qt-button-group-add-button! font-bg r-small  0)
      (qt-button-group-add-button! font-bg r-medium 1)
      (qt-button-group-add-button! font-bg r-large  2)
      (qt-layout-add-widget! font-layout r-small)
      (qt-layout-add-widget! font-layout r-medium)
      (qt-layout-add-widget! font-layout r-large)
      (qt-radio-button-set-checked! r-medium #t)

      ;; Setup checkable features group
      (qt-group-box-set-checkable! features-group #t)
      (qt-group-box-set-checked! features-group #t)
      (qt-layout-add-widget! features-layout cb-spell)
      (qt-layout-add-widget! features-layout cb-auto)
      (qt-layout-add-widget! features-layout cb-line)
      (qt-check-box-set-checked! cb-spell #t)
      (qt-check-box-set-checked! cb-auto #t)

      ;; Layout buttons
      (qt-layout-add-stretch! btn-layout)
      (qt-layout-add-widget! btn-layout btn-apply)
      (qt-layout-add-widget! btn-layout btn-reset)

      ;; Main layout
      (qt-layout-add-widget! layout theme-group)
      (qt-layout-add-widget! layout font-group)
      (qt-layout-add-widget! layout features-group)
      (qt-layout-add-widget! layout status-label)
      (qt-layout-add-widget! layout btn-row)
      (qt-layout-add-stretch! layout)
      (qt-layout-set-spacing! layout 10)
      (qt-layout-set-margins! layout 15 15 15 15)

      ;; --- Callbacks ---

      ;; Theme group clicked
      (qt-on-button-group-clicked! theme-bg
        (lambda (id)
          (let ((name (cond ((= id 0) "Light")
                            ((= id 1) "Dark")
                            (else "System Default"))))
            (qt-label-set-text! status-label
              (string-append "Theme: " name))
            ;; Apply dark/light style
            (cond
              ((= id 1) ;; Dark
               (qt-app-set-style-sheet! app
                 "QWidget { background-color: #2b2b2b; color: #e0e0e0; }
                  QGroupBox { border: 1px solid #555; border-radius: 4px;
                              margin-top: 10px; padding-top: 15px; }
                  QGroupBox::title { subcontrol-origin: margin;
                                     left: 10px; padding: 0 3px; }
                  QPushButton { background-color: #3c3f41; border: 1px solid #555;
                                padding: 5px 15px; border-radius: 3px; }
                  QPushButton:hover { background-color: #4c4f51; }"))
              (else
               (qt-app-set-style-sheet! app ""))))))

      ;; Font group clicked
      (qt-on-button-group-clicked! font-bg
        (lambda (id)
          (let ((size (cond ((= id 0) 10)
                            ((= id 1) 12)
                            (else 14))))
            (qt-label-set-text! status-label
              (string-append "Font size: " (number->string size) "pt"))
            (qt-widget-set-font-size! central size))))

      ;; Features group toggled
      (qt-on-group-box-toggled! features-group
        (lambda (checked)
          (qt-label-set-text! status-label
            (if checked "Features: enabled" "Features: disabled"))))

      ;; Apply button
      (qt-on-clicked! btn-apply
        (lambda ()
          (let ((theme-id (qt-button-group-checked-id theme-bg))
                (font-id  (qt-button-group-checked-id font-bg))
                (features (qt-group-box-checked? features-group)))
            (qt-label-set-text! status-label
              (string-append
                "Applied! Theme=" (number->string theme-id)
                " Font=" (number->string font-id)
                " Features=" (if features "on" "off"))))))

      ;; Reset button
      (qt-on-clicked! btn-reset
        (lambda ()
          (qt-radio-button-set-checked! r-light #t)
          (qt-radio-button-set-checked! r-medium #t)
          (qt-group-box-set-checked! features-group #t)
          (qt-check-box-set-checked! cb-spell #t)
          (qt-check-box-set-checked! cb-auto #t)
          (qt-check-box-set-checked! cb-line #f)
          (qt-app-set-style-sheet! app "")
          (qt-label-set-text! status-label "Reset to defaults")))

      ;; Show window
      (qt-main-window-set-title! win "Settings")
      (qt-main-window-set-central-widget! win central)
      (qt-widget-resize! win 400 500)
      (qt-widget-show! win)

      (qt-app-exec! app)

      ;; Cleanup non-widget resources
      (qt-button-group-destroy! theme-bg)
      (qt-button-group-destroy! font-bg))))

(main)
