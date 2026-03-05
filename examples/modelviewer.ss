;;; modelviewer.ss — Model/View demo
;;; QStandardItemModel in QTableView with sorting/filtering,
;;; and a QTreeView with hierarchical data.

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (vbox (qt-vbox-layout-create central))

           ;; Filter bar
           (filter-row (qt-widget-create))
           (filter-hbox (qt-hbox-layout-create filter-row))
           (filter-label (qt-label-create "Filter:"))
           (filter-edit (qt-line-edit-create))

           ;; Table model + view
           (table-model (qt-standard-model-create 0 3))
           (proxy (qt-sort-filter-proxy-create))
           (table-view (qt-table-view-create))

           ;; Tree model + view
           (tree-label (qt-label-create "Project Structure:"))
           (tree-model (qt-standard-model-create))
           (tree-view (qt-tree-view-create))

           ;; Status
           (status-label (qt-label-create "Click a row to see details")))

      ;; Configure window
      (qt-main-window-set-title! win "Model/View Demo")
      (qt-widget-resize! win 700 600)
      (qt-main-window-set-central-widget! win central)

      ;; Setup table model with sample data
      (qt-standard-model-set-horizontal-header! table-model 0 "Name")
      (qt-standard-model-set-horizontal-header! table-model 1 "Language")
      (qt-standard-model-set-horizontal-header! table-model 2 "Stars")

      (let ((data '(("Linux"      "C"          "180000")
                     ("React"      "JavaScript" "225000")
                     ("Rust"       "Rust"       "95000")
                     ("Python"     "C/Python"   "62000")
                     ("TypeScript" "TypeScript"  "100000")
                     ("Go"         "Go"         "122000")
                     ("Kubernetes" "Go"         "110000")
                     ("Node.js"    "JavaScript" "105000")
                     ("Gerbil"     "Scheme"     "1200"))))
        (qt-standard-model-set-row-count! table-model (length data))
        (let loop ((rows data) (i 0))
          (unless (null? rows)
            (let ((row (car rows)))
              (qt-standard-model-set-item! table-model i 0
                (qt-standard-item-create (car row)))
              (qt-standard-model-set-item! table-model i 1
                (qt-standard-item-create (cadr row)))
              (qt-standard-model-set-item! table-model i 2
                (qt-standard-item-create (caddr row)))
              (loop (cdr rows) (+ i 1))))))

      ;; Setup proxy and table view
      (qt-sort-filter-proxy-set-source-model! proxy table-model)
      (qt-sort-filter-proxy-set-filter-case-sensitivity! proxy QT_CASE_INSENSITIVE)
      (qt-view-set-model! table-view proxy)
      (qt-view-set-selection-mode! table-view QT_SELECT_SINGLE)
      (qt-view-set-selection-behavior! table-view QT_SELECT_ROWS)
      (qt-view-set-sorting-enabled! table-view #t)
      (qt-view-set-alternating-row-colors! table-view #t)
      (qt-view-set-edit-triggers! table-view QT_NO_EDIT_TRIGGERS)
      (qt-view-header-set-stretch-last-section! table-view #t #t)
      (qt-table-view-set-column-width! table-view 0 200)
      (qt-table-view-set-column-width! table-view 1 150)

      ;; Live filter from line edit
      (qt-line-edit-set-placeholder! filter-edit "Type to filter...")
      (qt-on-text-changed! filter-edit
        (lambda (text)
          (qt-sort-filter-proxy-set-filter-regex! proxy text)))

      ;; Click handler shows details in status
      (qt-on-view-clicked! table-view
        (lambda ()
          (let ((row (qt-view-last-clicked-row))
                (col (qt-view-last-clicked-col)))
            (qt-label-set-text! status-label
              (string-append "Clicked row " (number->string row)
                             ", column " (number->string col))))))

      ;; Setup tree model
      (let* ((root-src (qt-standard-item-create "src"))
             (root-tests (qt-standard-item-create "tests"))
             (main-ss (qt-standard-item-create "main.ss"))
             (lib-ss  (qt-standard-item-create "lib.ss"))
             (utils-ss (qt-standard-item-create "utils.ss"))
             (test-ss (qt-standard-item-create "main-test.ss")))
        (qt-standard-item-append-row! root-src main-ss)
        (qt-standard-item-append-row! root-src lib-ss)
        (qt-standard-item-append-row! root-src utils-ss)
        (qt-standard-item-append-row! root-tests test-ss)
        (qt-standard-model-set-horizontal-header! tree-model 0 "Files")
        (qt-standard-model-set-item! tree-model 0 0 root-src)
        (qt-standard-model-set-item! tree-model 1 0 root-tests))

      (qt-view-set-model! tree-view tree-model)
      (qt-tree-view-expand-all! tree-view)
      (qt-tree-view-set-header-hidden! tree-view #f)
      (qt-tree-view-set-indentation! tree-view 24)

      ;; Layout assembly
      (qt-layout-add-widget! filter-hbox filter-label)
      (qt-layout-add-widget! filter-hbox filter-edit)
      (qt-layout-add-widget! vbox filter-row)
      (qt-layout-add-widget! vbox table-view)
      (qt-layout-add-widget! vbox tree-label)
      (qt-layout-add-widget! vbox tree-view)
      (qt-layout-add-widget! vbox status-label)

      ;; Style
      (qt-widget-set-style-sheet! win
        "QTableView { font-size: 13px; }
         QTreeView { font-size: 13px; }
         QLabel { padding: 4px; }")

      ;; Show
      (qt-widget-show! win)
      (qt-app-exec! app)

      ;; Cleanup
      (qt-sort-filter-proxy-destroy! proxy)
      (qt-standard-model-destroy! table-model)
      (qt-standard-model-destroy! tree-model))))

(main)
