#!/bin/sh
#|
CHEZ_QT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENDOR_LIB="$(objdump -p "$CHEZ_QT_DIR/qt_chez_shim.so" 2>/dev/null | sed -n 's/.*RUNPATH *//p')"
export LD_LIBRARY_PATH="${VENDOR_LIB:+$VENDOR_LIB:}$CHEZ_QT_DIR:$LD_LIBRARY_PATH"
export CHEZ_QT_LIB="$CHEZ_QT_DIR"
exec scheme --libdirs "$CHEZ_QT_DIR" --script "$0" "$@"
|#
;;; File Browser — demonstrates QTreeWidget, QGridLayout, QTimer, clipboard

(import (chez-qt qt))

(define (populate-tree! tree path)
  "Recursively populate a tree widget with directory contents."
  (qt-tree-widget-clear! tree)
  (qt-tree-widget-set-header-item-text! tree 0 "Name")
  (qt-tree-widget-set-header-item-text! tree 1 "Size")
  (qt-tree-widget-set-header-item-text! tree 2 "Type")
  (add-dir-entries! tree #f path))

(define (add-dir-entries! tree parent-item dir)
  "Add directory entries as children."
  (let ((entries (guard (e [#t '()])
                   (directory-list dir))))
    (for-each
      (lambda (name)
        (when (and (not (string=? name ".")) (not (string=? name "..")))
          (let* ((full-path (string-append dir "/" name))
                 (is-dir (guard (e [#t #f])
                           (file-directory? full-path)))
                 (size (if is-dir
                         ""
                         (guard (e [#t "?"])
                           (number->string (file-length full-path)))))
                 (type (if is-dir "Directory" "File"))
                 (item (qt-tree-item-create name)))
            (qt-tree-item-set-text! item 1 size)
            (qt-tree-item-set-text! item 2 type)
            (if parent-item
              (qt-tree-item-add-child! parent-item item)
              (qt-tree-widget-add-top-level-item! tree item))
            ;; Recurse 1 level deep
            (when (and is-dir (not parent-item))
              (add-dir-entries! tree item full-path)))))
      entries)))

(define (current-time-string)
  (let ((t (current-date)))
    (format #f "~a:~a:~a"
      (date-hour t)
      (let ((m (date-minute t)))
        (if (< m 10) (string-append "0" (number->string m))
            (number->string m)))
      (let ((s (date-second t)))
        (if (< s 10) (string-append "0" (number->string s))
            (number->string s))))))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (grid (qt-grid-layout-create central))

           ;; Path entry
           (path-label (qt-label-create "Path:"))
           (path-edit (qt-line-edit-create))
           (browse-btn (qt-push-button-create "Browse"))

           ;; Tree widget
           (tree (qt-tree-widget-create))

           ;; Status area
           (status-label (qt-label-create "Ready"))
           (clock-label (qt-label-create (current-time-string)))
           (copy-btn (qt-push-button-create "Copy Path")))

      ;; Grid layout
      (qt-grid-layout-add-widget! grid path-label 0 0)
      (qt-grid-layout-add-widget! grid path-edit 0 1)
      (qt-grid-layout-add-widget! grid browse-btn 0 2)
      (qt-grid-layout-add-widget! grid tree 1 0 1 3)
      (qt-grid-layout-add-widget! grid status-label 2 0)
      (qt-grid-layout-add-widget! grid clock-label 2 1)
      (qt-grid-layout-add-widget! grid copy-btn 2 2)

      ;; Give tree row stretch
      (qt-grid-layout-set-row-stretch! grid 1 1)
      (qt-layout-set-spacing! grid 6)
      (qt-layout-set-margins! grid 8 8 8 8)

      ;; Initial state
      (let ((start-dir (or (getenv "HOME") "/home")))
        (qt-line-edit-set-text! path-edit start-dir)
        (populate-tree! tree start-dir))

      ;; Browse button
      (qt-on-clicked! browse-btn
        (lambda ()
          (let ((dir (qt-line-edit-text path-edit)))
            (populate-tree! tree dir)
            (qt-label-set-text! status-label
              (string-append "Browsing: " dir)))))

      ;; Return pressed
      (qt-on-return-pressed! path-edit
        (lambda ()
          (let ((dir (qt-line-edit-text path-edit)))
            (populate-tree! tree dir)
            (qt-label-set-text! status-label
              (string-append "Browsing: " dir)))))

      ;; Copy path button
      (qt-on-clicked! copy-btn
        (lambda ()
          (qt-clipboard-set-text! app (qt-line-edit-text path-edit))
          (qt-label-set-text! status-label "Path copied to clipboard")))

      ;; Timer updates clock
      (let ((timer (qt-timer-create)))
        (qt-on-timeout! timer
          (lambda ()
            (qt-label-set-text! clock-label (current-time-string))))
        (qt-timer-start! timer 1000)

        (qt-main-window-set-central-widget! win central)
        (qt-main-window-set-title! win "File Browser")
        (qt-widget-resize! win 700 500)
        (qt-widget-show! win)

        (qt-app-exec! app)

        ;; Cleanup timer
        (qt-timer-stop! timer)
        (qt-timer-destroy! timer)))))

(main)
