#!/bin/sh
#|
CHEZ_QT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_LIB="$(objdump -p "$CHEZ_QT_DIR/qt_chez_shim.so" 2>/dev/null | sed -n 's/.*RUNPATH *//p')"
export LD_LIBRARY_PATH="${VENDOR_LIB:+$VENDOR_LIB:}$CHEZ_QT_DIR:$LD_LIBRARY_PATH"
export CHEZ_QT_LIB="$CHEZ_QT_DIR"
exec scheme --libdirs "$CHEZ_QT_DIR" --script "$0" "$@"
|#
(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-hbox-layout-create central))
           (source-frame (qt-frame-create))
           (source-layout (qt-vbox-layout-create source-frame))
           (source-label (qt-label-create "Drag from here:"))
           (source-list (qt-list-widget-create))
           (target-frame (qt-frame-create))
           (target-layout (qt-vbox-layout-create target-frame))
           (target-label (qt-label-create "Drop here:"))
           (target-list (qt-list-widget-create))
           (status (qt-label-create "Drag items from left to right")))
      ;; frame styling
      (qt-frame-set-frame-shape! source-frame QT_FRAME_STYLED_PANEL)
      (qt-frame-set-frame-shadow! source-frame QT_FRAME_SUNKEN)
      (qt-frame-set-frame-shape! target-frame QT_FRAME_STYLED_PANEL)
      (qt-frame-set-frame-shadow! target-frame QT_FRAME_SUNKEN)
      ;; populate source list
      (for-each
        (lambda (item)
          (qt-list-widget-add-item! source-list item))
        (list "Apple" "Banana" "Cherry" "Date" "Elderberry"
              "Fig" "Grape" "Honeydew"))
      ;; enable drop on target
      (qt-widget-set-accept-drops! target-list #t)
      (qt-drop-filter-install! target-list
        (lambda (text)
          (qt-list-widget-add-item! target-list text)
          (qt-label-set-text! status (format #f "Dropped: ~a" text))))
      ;; build layouts
      (qt-layout-add-widget! source-layout source-label)
      (qt-layout-add-widget! source-layout source-list)
      (qt-layout-add-widget! target-layout target-label)
      (qt-layout-add-widget! target-layout target-list)
      (qt-layout-add-widget! layout source-frame)
      (qt-layout-add-widget! layout target-frame)
      ;; main window
      (qt-main-window-set-title! win "Drag and Drop")
      (qt-main-window-set-central-widget! win central)
      (qt-main-window-set-status-bar-text! win "Ready")
      (qt-widget-resize! win 500 400)
      (qt-widget-show! win)
      (qt-app-exec! app))))

(main)
