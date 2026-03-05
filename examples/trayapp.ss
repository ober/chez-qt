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
    (when (not (qt-system-tray-icon-available?))
      (display "System tray not available")
      (newline)
      (exit 1))
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-vbox-layout-create central))
           (title-label (qt-label-create "Chez-Qt System Tray Demo"))
           (info-btn (qt-push-button-create "Show Info Message"))
           (warn-btn (qt-push-button-create "Show Warning Message"))
           (crit-btn (qt-push-button-create "Show Critical Message"))
           (quit-btn (qt-push-button-create "Quit"))
           (status (qt-label-create "Tray icon active"))
           (tray (qt-system-tray-icon-create))
           ;; Create context menu via menu bar (only way to create menus)
           (tray-menu (qt-menu-bar-add-menu (qt-main-window-menu-bar win) "Tray")))
      ;; tray menu
      (let ((show-action (qt-action-create "Show Window"))
            (hide-action (qt-action-create "Hide Window"))
            (quit-action (qt-action-create "Quit")))
        (qt-on-triggered! show-action (lambda () (qt-widget-show! win)))
        (qt-on-triggered! hide-action (lambda () (qt-widget-hide! win)))
        (qt-on-triggered! quit-action (lambda () (qt-app-quit! app)))
        (qt-menu-add-action! tray-menu show-action)
        (qt-menu-add-action! tray-menu hide-action)
        (qt-menu-add-separator! tray-menu)
        (qt-menu-add-action! tray-menu quit-action))
      (qt-system-tray-icon-set-context-menu! tray tray-menu)
      (qt-system-tray-icon-set-tooltip! tray "Chez-Qt Tray App")
      (qt-system-tray-icon-show! tray)
      ;; tray activation (use numeric values: Trigger=3, DoubleClick=2, Context=1, MiddleClick=4)
      (qt-on-tray-activated! tray
        (lambda (reason)
          (cond
            ((= reason 3) ;; Trigger (single click)
             (if (qt-widget-visible? win)
               (qt-widget-hide! win)
               (qt-widget-show! win)))
            ((= reason 2) ;; DoubleClick
             (qt-widget-show! win)
             (qt-label-set-text! status "Tray double-clicked")))))
      ;; buttons
      (qt-on-clicked! info-btn
        (lambda ()
          (qt-system-tray-icon-show-message! tray "Info" "This is an information message" QT_TRAY_INFORMATION 5000)
          (qt-label-set-text! status "Sent info message")))
      (qt-on-clicked! warn-btn
        (lambda ()
          (qt-system-tray-icon-show-message! tray "Warning" "This is a warning message" QT_TRAY_WARNING 5000)
          (qt-label-set-text! status "Sent warning message")))
      (qt-on-clicked! crit-btn
        (lambda ()
          (qt-system-tray-icon-show-message! tray "Critical" "This is a critical message" QT_TRAY_CRITICAL 5000)
          (qt-label-set-text! status "Sent critical message")))
      (qt-on-clicked! quit-btn (lambda () (qt-app-quit! app)))
      ;; layout
      (qt-label-set-alignment! title-label QT_ALIGN_CENTER)
      (qt-widget-set-font-size! title-label 16)
      (qt-layout-add-stretch! layout)
      (qt-layout-add-widget! layout title-label)
      (qt-layout-add-spacing! layout 20)
      (qt-layout-add-widget! layout info-btn)
      (qt-layout-add-widget! layout warn-btn)
      (qt-layout-add-widget! layout crit-btn)
      (qt-layout-add-spacing! layout 20)
      (qt-layout-add-widget! layout quit-btn)
      (qt-layout-add-stretch! layout)
      (qt-layout-add-widget! layout status)
      ;; window
      (qt-main-window-set-title! win "Tray App")
      (qt-main-window-set-central-widget! win central)
      (qt-widget-resize! win 400 350)
      (qt-widget-show! win)
      (qt-app-exec! app))))

(main)
