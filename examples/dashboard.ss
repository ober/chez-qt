;;; dashboard.ss — Dashboard demo showcasing tabs, lists, tables, sliders

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (tabs (qt-tab-widget-create))

         ;; ---- Tab 1: Todo List ----
         (todo-page (qt-widget-create))
         (todo-layout (qt-vbox-layout-create todo-page))

         ;; Input row
         (input-row (qt-widget-create))
         (input-layout (qt-hbox-layout-create input-row))
         (todo-input (qt-line-edit-create))
         (add-btn (qt-push-button-create "Add"))
         (remove-btn (qt-push-button-create "Remove"))

         ;; List
         (todo-list (qt-list-widget-create))

         ;; ---- Tab 2: Data Table ----
         (table-page (qt-widget-create))
         (table-layout (qt-vbox-layout-create table-page))
         (table (qt-table-widget-create 5 3))
         (table-status (qt-label-create "Click a cell"))

         ;; ---- Tab 3: Controls ----
         (controls-page (qt-widget-create))
         (controls-layout (qt-vbox-layout-create controls-page))

         (slider-label (qt-label-create "Slider value: 50"))
         (slider (qt-slider-create QT_HORIZONTAL))
         (progress-label (qt-label-create "Progress:"))
         (progress (qt-progress-bar-create))

         ;; Slider row with +/- buttons
         (btn-row (qt-widget-create))
         (btn-layout (qt-hbox-layout-create btn-row))
         (dec-btn (qt-push-button-create "-10"))
         (inc-btn (qt-push-button-create "+10"))
         (reset-btn (qt-push-button-create "Reset")))

    ;; ---- Build Tab 1: Todo ----
    (qt-line-edit-set-placeholder! todo-input "Enter a task...")
    (qt-layout-add-widget! input-layout todo-input)
    (qt-layout-add-widget! input-layout add-btn)
    (qt-layout-add-widget! input-layout remove-btn)
    (qt-layout-add-widget! todo-layout input-row)
    (qt-layout-add-widget! todo-layout todo-list)

    ;; Add some initial items
    (for-each (lambda (item) (qt-list-widget-add-item! todo-list item))
              '("Buy groceries" "Write Chez code" "Review PR"
                "Walk the dog" "Read a book"))

    ;; Add item handler
    (qt-on-clicked! add-btn
      (lambda ()
        (let ((text (qt-line-edit-text todo-input)))
          (when (not (string=? text ""))
            (qt-list-widget-add-item! todo-list text)
            (qt-line-edit-set-text! todo-input "")))))

    ;; Also add on Enter
    (qt-on-return-pressed! todo-input
      (lambda ()
        (let ((text (qt-line-edit-text todo-input)))
          (when (not (string=? text ""))
            (qt-list-widget-add-item! todo-list text)
            (qt-line-edit-set-text! todo-input "")))))

    ;; Remove selected item
    (qt-on-clicked! remove-btn
      (lambda ()
        (let ((row (qt-list-widget-current-row todo-list)))
          (when (>= row 0)
            (qt-list-widget-remove-item! todo-list row)))))

    ;; Double-click to remove
    (qt-on-item-double-clicked! todo-list
      (lambda (row)
        (qt-list-widget-remove-item! todo-list row)))

    ;; ---- Build Tab 2: Table ----
    ;; Set headers
    (qt-table-widget-set-horizontal-header! table 0 "Name")
    (qt-table-widget-set-horizontal-header! table 1 "Language")
    (qt-table-widget-set-horizontal-header! table 2 "Stars")

    ;; Populate sample data
    (let ((data '(("Chez" "Scheme" "7000")
                  ("Racket" "Scheme" "4500")
                  ("Guile" "Scheme" "900")
                  ("Gerbil" "Scheme" "1200")
                  ("Gambit" "Scheme" "1300"))))
      (let loop ((rows data) (r 0))
        (when (pair? rows)
          (let ((row (car rows)))
            (qt-table-widget-set-item! table r 0 (car row))
            (qt-table-widget-set-item! table r 1 (cadr row))
            (qt-table-widget-set-item! table r 2 (caddr row)))
          (loop (cdr rows) (+ r 1)))))

    (qt-layout-add-widget! table-layout table)
    (qt-layout-add-widget! table-layout table-status)

    ;; Cell click handler
    (qt-on-cell-clicked! table
      (lambda ()
        (let ((row (qt-table-widget-current-row table))
              (col (qt-table-widget-current-column table)))
          (qt-label-set-text! table-status
            (string-append "Cell (" (number->string row) ", "
                           (number->string col) ") = "
                           (qt-table-widget-item-text table row col))))))

    ;; ---- Build Tab 3: Controls ----
    (qt-slider-set-range! slider 0 100)
    (qt-slider-set-value! slider 50)
    (qt-slider-set-tick-interval! slider 10)
    (qt-slider-set-tick-position! slider QT_TICKS_BELOW)

    (qt-progress-bar-set-range! progress 0 100)
    (qt-progress-bar-set-value! progress 50)

    (qt-layout-add-widget! controls-layout slider-label)
    (qt-layout-add-widget! controls-layout slider)
    (qt-layout-add-widget! controls-layout progress-label)
    (qt-layout-add-widget! controls-layout progress)
    (qt-layout-add-widget! controls-layout btn-row)
    (qt-layout-add-stretch! controls-layout)

    (qt-layout-add-widget! btn-layout dec-btn)
    (qt-layout-add-widget! btn-layout inc-btn)
    (qt-layout-add-widget! btn-layout reset-btn)

    ;; Slider updates progress bar and label
    (qt-on-slider-value-changed! slider
      (lambda (val)
        (qt-progress-bar-set-value! progress val)
        (qt-label-set-text! slider-label
          (string-append "Slider value: " (number->string val)))))

    ;; Button handlers
    (qt-on-clicked! dec-btn
      (lambda ()
        (let ((v (max 0 (- (qt-slider-value slider) 10))))
          (qt-slider-set-value! slider v))))

    (qt-on-clicked! inc-btn
      (lambda ()
        (let ((v (min 100 (+ (qt-slider-value slider) 10))))
          (qt-slider-set-value! slider v))))

    (qt-on-clicked! reset-btn
      (lambda ()
        (qt-slider-set-value! slider 50)))

    ;; ---- Assemble tabs ----
    (qt-tab-widget-add-tab! tabs todo-page "Todo List")
    (qt-tab-widget-add-tab! tabs table-page "Data Table")
    (qt-tab-widget-add-tab! tabs controls-page "Controls")

    ;; Tab change handler
    (qt-on-tab-changed! tabs
      (lambda (index)
        (qt-main-window-set-status-bar-text! win
          (string-append "Tab: "
            (cond ((= index 0) "Todo List")
                  ((= index 1) "Data Table")
                  ((= index 2) "Controls")
                  (else "Unknown"))))))

    ;; ---- Window setup ----
    (qt-main-window-set-title! win "Chez-Qt Dashboard")
    (qt-main-window-set-central-widget! win tabs)
    (qt-widget-resize! win 600 450)
    (qt-main-window-set-status-bar-text! win "Ready")
    (qt-widget-show! win)

      (qt-app-exec! app))))

(main)
