;;; filemanager.ss — File system browser using QFileSystemModel + QTreeView

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (main-layout (qt-vbox-layout-create central))

           ;; Splitter: tree view | details
           (splitter (qt-splitter-create QT_HORIZONTAL))

           ;; Left: file tree
           (tree (qt-tree-view-create))
           (model (qt-file-system-model-create))

           ;; Right: details panel
           (detail-widget (qt-widget-create))
           (detail-layout (qt-vbox-layout-create detail-widget))
           (path-label (qt-label-create "Path: /"))
           (info-text (qt-plain-text-edit-create))

           ;; Filter bar
           (filter-bar (qt-widget-create))
           (filter-layout (qt-hbox-layout-create filter-bar))
           (filter-label (qt-label-create "Name filter:"))
           (filter-input (qt-line-edit-create))
           (apply-btn (qt-push-button-create "Apply"))
           (clear-btn (qt-push-button-create "Clear"))
           (show-hidden (qt-check-box-create "Show hidden"))

           ;; Path bar
           (path-bar (qt-widget-create))
           (path-layout (qt-hbox-layout-create path-bar))
           (root-input (qt-line-edit-create))
           (go-btn (qt-push-button-create "Go"))

           (home-dir (or (getenv "HOME") "/home")))

      ;; Setup file system model
      (qt-file-system-model-set-root-path! model "/")
      (qt-file-system-model-set-filter! model
        (bitwise-ior QT_DIR_DIRS QT_DIR_FILES QT_DIR_NO_DOT_AND_DOT_DOT))

      ;; Setup tree view
      (qt-view-set-model! tree model)
      (qt-tree-view-set-file-system-root! tree model home-dir)
      (qt-tree-view-set-indentation! tree 20)
      (qt-view-set-sorting-enabled! tree #t)
      (qt-view-set-alternating-row-colors! tree #t)

      ;; Tree view click shows file path
      (qt-on-view-clicked! tree
        (lambda ()
          (let* ((row (qt-view-last-clicked-row))
                 (col (qt-view-last-clicked-col))
                 (path (qt-file-system-model-file-path model row col)))
            (qt-label-set-text! path-label (format #f "Selected: ~a" path))
            (qt-plain-text-edit-set-text! info-text
              (format #f "File: ~a\nRow: ~a Column: ~a" path row col)))))

      ;; Details panel
      (qt-plain-text-edit-set-read-only! info-text #t)
      (qt-layout-add-widget! detail-layout path-label)
      (qt-layout-add-widget! detail-layout info-text)

      ;; Splitter
      (qt-splitter-add-widget! splitter tree)
      (qt-splitter-add-widget! splitter detail-widget)
      (qt-splitter-set-sizes! splitter 500 300)
      (qt-splitter-set-stretch-factor! splitter 0 1)
      (qt-splitter-set-stretch-factor! splitter 1 0)

      ;; Filter bar
      (qt-line-edit-set-placeholder! filter-input "e.g. *.ss *.scm")
      (qt-layout-add-widget! filter-layout filter-label)
      (qt-layout-add-widget! filter-layout filter-input)
      (qt-layout-add-widget! filter-layout apply-btn)
      (qt-layout-add-widget! filter-layout clear-btn)
      (qt-layout-add-spacing! filter-layout 20)
      (qt-layout-add-widget! filter-layout show-hidden)

      (qt-on-clicked! apply-btn
        (lambda ()
          (let ((pattern (qt-line-edit-text filter-input)))
            (when (> (string-length pattern) 0)
              (qt-file-system-model-set-name-filters! model pattern)
              (qt-main-window-set-status-bar-text! win
                (format #f "Filter: ~a" pattern))))))

      (qt-on-clicked! clear-btn
        (lambda ()
          (qt-file-system-model-set-name-filters! model "")
          (qt-line-edit-set-text! filter-input "")
          (qt-main-window-set-status-bar-text! win "Filter cleared")))

      (qt-on-toggled! show-hidden
        (lambda (checked)
          (if checked
            (qt-file-system-model-set-filter! model
              (bitwise-ior QT_DIR_DIRS QT_DIR_FILES QT_DIR_HIDDEN QT_DIR_NO_DOT_AND_DOT_DOT))
            (qt-file-system-model-set-filter! model
              (bitwise-ior QT_DIR_DIRS QT_DIR_FILES QT_DIR_NO_DOT_AND_DOT_DOT)))
          (qt-main-window-set-status-bar-text! win
            (format #f "Hidden files: ~a" (if checked "shown" "hidden")))))

      ;; Path bar
      (qt-line-edit-set-text! root-input home-dir)
      (qt-layout-add-widget! path-layout (qt-label-create "Root:"))
      (qt-layout-add-widget! path-layout root-input)
      (qt-layout-add-widget! path-layout go-btn)

      (qt-on-clicked! go-btn
        (lambda ()
          (let ((path (qt-line-edit-text root-input)))
            (qt-file-system-model-set-root-path! model path)
            (qt-tree-view-set-file-system-root! tree model path)
            (qt-main-window-set-status-bar-text! win
              (format #f "Root: ~a" path)))))

      (qt-on-return-pressed! root-input
        (lambda ()
          (let ((text (qt-line-edit-text root-input)))
            (qt-file-system-model-set-root-path! model text)
            (qt-tree-view-set-file-system-root! tree model text)
            (qt-main-window-set-status-bar-text! win
              (format #f "Root: ~a" text)))))

      ;; Assemble
      (qt-layout-add-widget! main-layout path-bar)
      (qt-layout-add-widget! main-layout splitter)
      (qt-layout-add-widget! main-layout filter-bar)

      ;; Show
      (qt-main-window-set-central-widget! win central)
      (qt-main-window-set-title! win "File Manager")
      (qt-widget-resize! win 900 600)
      (qt-widget-show! win)
      (qt-main-window-set-status-bar-text! win
        (format #f "Browsing: ~a" home-dir))
      (qt-app-exec! app)

      ;; Cleanup
      (qt-file-system-model-destroy! model))))

(main)
