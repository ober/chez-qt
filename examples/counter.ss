#!/bin/sh
#|
CHEZ_QT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_LIB="$(objdump -p "$CHEZ_QT_DIR/qt_chez_shim.so" 2>/dev/null | sed -n 's/.*RUNPATH *//p')"
export LD_LIBRARY_PATH="${VENDOR_LIB:+$VENDOR_LIB:}$CHEZ_QT_DIR:$LD_LIBRARY_PATH"
export CHEZ_QT_LIB="$CHEZ_QT_DIR"
exec scheme --libdirs "$CHEZ_QT_DIR" --script "$0" "$@"
|#
;;; Counter example: button click increments a label

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-vbox-layout-create central))
           (count 0)
           (label (qt-label-create "Count: 0"))
           (button (qt-push-button-create "Click me!")))
      (qt-label-set-alignment! label QT_ALIGN_CENTER)
      (qt-widget-set-font-size! label 24)
      (qt-layout-add-widget! layout label)
      (qt-layout-add-widget! layout button)
      (qt-layout-set-spacing! layout 20)
      (qt-layout-set-margins! layout 20 20 20 20)
      (qt-on-clicked! button
        (lambda ()
          (set! count (+ count 1))
          (qt-label-set-text! label
            (string-append "Count: " (number->string count)))))
      (qt-main-window-set-title! win "Counter")
      (qt-main-window-set-central-widget! win central)
      (qt-widget-resize! win 300 200)
      (qt-widget-show! win)
      (qt-app-exec! app))))

(main)
