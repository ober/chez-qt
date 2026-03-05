#!/bin/sh
#|
CHEZ_QT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_LIB="$(objdump -p "$CHEZ_QT_DIR/qt_chez_shim.so" 2>/dev/null | sed -n 's/.*RUNPATH *//p')"
export LD_LIBRARY_PATH="${VENDOR_LIB:+$VENDOR_LIB:}$CHEZ_QT_DIR:$LD_LIBRARY_PATH"
export CHEZ_QT_LIB="$CHEZ_QT_DIR"
exec scheme --libdirs "$CHEZ_QT_DIR" --script "$0" "$@"
|#
;;; polished.ss — Practical Polish demo
;;; QToolButton, validators, QPlainTextEdit, layout spacers, QSizePolicy

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (vlayout (qt-vbox-layout-create central))

           ;; Toolbar row
           (toolbar-row (qt-widget-create))
           (toolbar-layout (qt-hbox-layout-create toolbar-row))
           (tb-up (qt-tool-button-create))
           (tb-down (qt-tool-button-create))
           (tb-actions (qt-tool-button-create))

           ;; Input fields
           (form-widget (qt-widget-create))
           (form-layout (qt-vbox-layout-create form-widget))

           ;; Integer input (1-999)
           (int-row (qt-widget-create))
           (int-layout (qt-hbox-layout-create int-row))
           (int-label (qt-label-create "Quantity (1-999):"))
           (int-input (qt-line-edit-create))
           (int-validator (qt-int-validator-create 1 999))

           ;; Double input (0.0-100.0)
           (dbl-row (qt-widget-create))
           (dbl-layout (qt-hbox-layout-create dbl-row))
           (dbl-label (qt-label-create "Price (0-100):"))
           (dbl-input (qt-line-edit-create))
           (dbl-validator (qt-double-validator-create 0.0 100.0 2))

           ;; Regex input (AAA-999)
           (re-row (qt-widget-create))
           (re-layout (qt-hbox-layout-create re-row))
           (re-label (qt-label-create "Code (AAA-999):"))
           (re-input (qt-line-edit-create))
           (re-validator (qt-regex-validator-create "^[A-Z]{3}-[0-9]{3}$"))

           ;; Validate button
           (btn-validate (qt-push-button-create "Validate All"))

           ;; Log area
           (log-area (qt-plain-text-edit-create)))

      ;; Window setup
      (qt-main-window-set-title! win "Polished Form")
      (qt-widget-resize! win 500 450)
      (qt-main-window-set-central-widget! win central)

      ;; Toolbar buttons
      (qt-tool-button-set-arrow-type! tb-up QT_UP_ARROW)
      (qt-tool-button-set-auto-raise! tb-up #t)
      (qt-tool-button-set-arrow-type! tb-down QT_DOWN_ARROW)
      (qt-tool-button-set-auto-raise! tb-down #t)

      ;; Actions dropdown
      (qt-tool-button-set-text! tb-actions "Actions")
      (qt-tool-button-set-tool-button-style! tb-actions QT_TOOL_BUTTON_TEXT_ONLY)
      (qt-tool-button-set-auto-raise! tb-actions #t)

      ;; Add toolbar widgets
      (qt-layout-add-widget! toolbar-layout tb-up)
      (qt-layout-add-widget! toolbar-layout tb-down)
      (qt-layout-add-spacing! toolbar-layout 10)
      (qt-layout-add-widget! toolbar-layout tb-actions)
      (qt-layout-add-stretch! toolbar-layout)

      ;; Setup validators
      (qt-line-edit-set-validator! int-input int-validator)
      (qt-line-edit-set-placeholder! int-input "Enter 1-999")
      (qt-layout-add-widget! int-layout int-label)
      (qt-layout-add-widget! int-layout int-input)

      (qt-line-edit-set-validator! dbl-input dbl-validator)
      (qt-line-edit-set-placeholder! dbl-input "Enter 0.00-100.00")
      (qt-layout-add-widget! dbl-layout dbl-label)
      (qt-layout-add-widget! dbl-layout dbl-input)

      (qt-line-edit-set-validator! re-input re-validator)
      (qt-line-edit-set-placeholder! re-input "e.g. ABC-123")
      (qt-layout-add-widget! re-layout re-label)
      (qt-layout-add-widget! re-layout re-input)

      ;; Form layout with spacing
      (qt-layout-add-widget! form-layout int-row)
      (qt-layout-add-spacing! form-layout 5)
      (qt-layout-add-widget! form-layout dbl-row)
      (qt-layout-add-spacing! form-layout 5)
      (qt-layout-add-widget! form-layout re-row)

      ;; Log area setup
      (qt-plain-text-edit-set-read-only! log-area #t)
      (qt-plain-text-edit-set-max-block-count! log-area 100)
      (qt-plain-text-edit-set-placeholder! log-area "Validation log...")

      ;; Size policies
      (qt-widget-set-size-policy! form-widget QT_SIZE_PREFERRED QT_SIZE_FIXED)
      (qt-widget-set-size-policy! log-area QT_SIZE_EXPANDING QT_SIZE_EXPANDING)

      ;; Main layout assembly
      (qt-layout-add-widget! vlayout toolbar-row)
      (qt-layout-add-spacing! vlayout 10)
      (qt-layout-add-widget! vlayout form-widget)
      (qt-layout-add-spacing! vlayout 10)
      (qt-layout-add-widget! vlayout btn-validate)
      (qt-layout-add-spacing! vlayout 5)
      (qt-layout-add-widget! vlayout log-area)

      ;; Stretch factors
      (qt-layout-set-stretch-factor! vlayout form-widget 0)
      (qt-layout-set-stretch-factor! vlayout log-area 1)

      ;; Button handlers
      (qt-on-tool-button-clicked! tb-up
        (lambda ()
          (qt-plain-text-edit-append! log-area "Up pressed")))

      (qt-on-tool-button-clicked! tb-down
        (lambda ()
          (qt-plain-text-edit-append! log-area "Down pressed")))

      (qt-on-tool-button-clicked! tb-actions
        (lambda ()
          (qt-plain-text-edit-append! log-area "Actions clicked")))

      ;; Validate All
      (qt-on-clicked! btn-validate
        (lambda ()
          (let ((results '()))
            ;; Check quantity
            (let ((val (qt-line-edit-text int-input)))
              (if (qt-line-edit-has-acceptable-input? int-input)
                (set! results (cons (format #f "  Quantity '~a': OK" val) results))
                (set! results (cons (format #f "  Quantity '~a': INVALID" val) results))))
            ;; Check price
            (let ((val (qt-line-edit-text dbl-input)))
              (if (qt-line-edit-has-acceptable-input? dbl-input)
                (set! results (cons (format #f "  Price '~a': OK" val) results))
                (set! results (cons (format #f "  Price '~a': INVALID" val) results))))
            ;; Check code
            (let ((val (qt-line-edit-text re-input)))
              (if (qt-line-edit-has-acceptable-input? re-input)
                (set! results (cons (format #f "  Code '~a': OK" val) results))
                (set! results (cons (format #f "  Code '~a': INVALID" val) results))))
            ;; Log results
            (qt-plain-text-edit-append! log-area "--- Validation ---")
            (for-each (lambda (r)
                        (qt-plain-text-edit-append! log-area r))
                      (reverse results)))))

      ;; Show and run
      (qt-widget-show! win)
      (qt-app-exec! app)

      ;; Cleanup validators
      (qt-validator-destroy! int-validator)
      (qt-validator-destroy! dbl-validator)
      (qt-validator-destroy! re-validator))))

(main)
