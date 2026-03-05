#!/bin/sh
#|
CHEZ_QT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_LIB="$(objdump -p "$CHEZ_QT_DIR/qt_chez_shim.so" 2>/dev/null | sed -n 's/.*RUNPATH *//p')"
export LD_LIBRARY_PATH="${VENDOR_LIB:+$VENDOR_LIB:}$CHEZ_QT_DIR:$LD_LIBRARY_PATH"
export CHEZ_QT_LIB="$CHEZ_QT_DIR"
exec scheme --libdirs "$CHEZ_QT_DIR" --script "$0" "$@"
|#
;;; Minimal Chez-Qt example: window with a label

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (label (qt-label-create "Hello from Chez-Qt!")))
      (qt-label-set-alignment! label QT_ALIGN_CENTER)
      (qt-widget-set-font-size! label 18)
      (qt-main-window-set-title! win "Hello World")
      (qt-main-window-set-central-widget! win label)
      (qt-widget-resize! win 400 200)
      (qt-widget-show! win)
      (qt-app-exec! app))))

(main)
