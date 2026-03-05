#!/bin/sh
#|
CHEZ_QT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_LIB="$(objdump -p "$CHEZ_QT_DIR/qt_chez_shim.so" 2>/dev/null | sed -n 's/.*RUNPATH *//p')"
export LD_LIBRARY_PATH="${VENDOR_LIB:+$VENDOR_LIB:}$CHEZ_QT_DIR:$LD_LIBRARY_PATH"
export CHEZ_QT_LIB="$CHEZ_QT_DIR"
exec scheme --libdirs "$CHEZ_QT_DIR" --script "$0" "$@"
|#
;;; datainput.ss — Data input widgets demo
;;; Demonstrates QDoubleSpinBox, QDateEdit, QTimeEdit, QFrame,
;;; QProgressDialog, and QInputDialog.

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-vbox-layout-create central))

           ;; --- Section: Price input ---
           (price-frame (qt-frame-create))
           (price-layout (qt-vbox-layout-create price-frame))
           (price-label (qt-label-create "Price:"))
           (price-spin (qt-double-spin-box-create))

           ;; --- Section: Date & Time ---
           (dt-frame (qt-frame-create))
           (dt-layout (qt-vbox-layout-create dt-frame))
           (date-label (qt-label-create "Appointment Date:"))
           (date-edit (qt-date-edit-create))
           (time-label (qt-label-create "Appointment Time:"))
           (time-edit (qt-time-edit-create))

           ;; --- Separator ---
           (sep (qt-frame-create))

           ;; --- Status ---
           (status-label (qt-label-create "Ready"))

           ;; --- Buttons ---
           (btn-row (qt-widget-create))
           (btn-layout (qt-hbox-layout-create btn-row))
           (btn-name (qt-push-button-create "Enter Name..."))
           (btn-count (qt-push-button-create "Enter Count..."))
           (btn-progress (qt-push-button-create "Run Progress")))

      ;; Configure price
      (qt-double-spin-box-set-range! price-spin 0.0 99999.99)
      (qt-double-spin-box-set-single-step! price-spin 0.01)
      (qt-double-spin-box-set-decimals! price-spin 2)
      (qt-double-spin-box-set-prefix! price-spin "$ ")
      (qt-double-spin-box-set-value! price-spin 9.99)
      (qt-on-double-spin-value-changed! price-spin
        (lambda (val)
          (qt-label-set-text! status-label
            (string-append "Price: $" (number->string val)))))

      ;; Configure date
      (qt-date-edit-set-date! date-edit 2025 6 15)
      (qt-date-edit-set-calendar-popup! date-edit #t)
      (qt-date-edit-set-minimum-date! date-edit 2025 1 1)
      (qt-date-edit-set-maximum-date! date-edit 2030 12 31)
      (qt-on-date-changed! date-edit
        (lambda (iso-str)
          (qt-label-set-text! status-label
            (string-append "Date: " iso-str))))

      ;; Configure time
      (qt-time-edit-set-time! time-edit 14 30 0)
      (qt-time-edit-set-display-format! time-edit "HH:mm")
      (qt-on-time-changed! time-edit
        (lambda (iso-str)
          (qt-label-set-text! status-label
            (string-append "Time: " iso-str))))

      ;; Style frames
      (qt-frame-set-frame-shape! price-frame QT_FRAME_BOX)
      (qt-frame-set-frame-shadow! price-frame QT_FRAME_SUNKEN)
      (qt-frame-set-line-width! price-frame 1)

      (qt-frame-set-frame-shape! dt-frame QT_FRAME_PANEL)
      (qt-frame-set-frame-shadow! dt-frame QT_FRAME_RAISED)

      ;; Separator
      (qt-frame-set-frame-shape! sep QT_FRAME_HLINE)
      (qt-frame-set-frame-shadow! sep QT_FRAME_SUNKEN)

      ;; Layout price frame
      (qt-layout-add-widget! price-layout price-label)
      (qt-layout-add-widget! price-layout price-spin)

      ;; Layout date/time frame
      (qt-layout-add-widget! dt-layout date-label)
      (qt-layout-add-widget! dt-layout date-edit)
      (qt-layout-add-widget! dt-layout time-label)
      (qt-layout-add-widget! dt-layout time-edit)

      ;; Layout buttons
      (qt-layout-add-widget! btn-layout btn-name)
      (qt-layout-add-widget! btn-layout btn-count)
      (qt-layout-add-widget! btn-layout btn-progress)

      ;; Main layout
      (qt-layout-add-widget! layout price-frame)
      (qt-layout-add-widget! layout dt-frame)
      (qt-layout-add-widget! layout sep)
      (qt-layout-add-widget! layout btn-row)
      (qt-layout-add-widget! layout status-label)
      (qt-layout-add-stretch! layout)

      ;; Button: Enter Name (QInputDialog::getText)
      (qt-on-clicked! btn-name
        (lambda ()
          (let ((name (qt-input-dialog-get-text win "Name" "Enter your name:" "Alice")))
            (qt-label-set-text! status-label
              (if name (string-append "Name: " name) "Canceled")))))

      ;; Button: Enter Count (QInputDialog::getInt)
      (qt-on-clicked! btn-count
        (lambda ()
          (let ((n (qt-input-dialog-get-int win "Count" "How many items?" 1 0 100 1)))
            (qt-label-set-text! status-label
              (if n (string-append "Count: " (number->string n)) "Canceled")))))

      ;; Button: Run Progress (QProgressDialog)
      (qt-on-clicked! btn-progress
        (lambda ()
          (let ((pd (qt-progress-dialog-create "Processing..." "Cancel" 0 100 win)))
            (qt-progress-dialog-set-minimum-duration! pd 0)
            ;; Simulate progress using a timer
            (let ((timer (qt-timer-create))
                  (step 0))
              (qt-timer-set-interval! timer 50)
              (qt-on-timeout! timer
                (lambda ()
                  (set! step (+ step 1))
                  (qt-progress-dialog-set-value! pd step)
                  (when (or (>= step 100) (qt-progress-dialog-was-canceled? pd))
                    (qt-timer-stop! timer)
                    (qt-timer-destroy! timer)
                    (qt-label-set-text! status-label
                      (if (qt-progress-dialog-was-canceled? pd)
                        "Progress canceled"
                        "Progress complete!"))
                    (qt-widget-destroy! pd))))
              (qt-timer-start! timer 50)))))

      ;; Window setup
      (qt-main-window-set-central-widget! win central)
      (qt-main-window-set-title! win "Data Input Demo")
      (qt-widget-resize! win 400 350)
      (qt-widget-show! win)
      (qt-app-exec! app))))

(main)
