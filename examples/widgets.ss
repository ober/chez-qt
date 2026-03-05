;;; widgets.ss — Niche widgets demo: QDial, QLCDNumber, QToolBox, QUndoStack

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-vbox-layout-create central))
           ;; QToolBox as organizer
           (toolbox (qt-tool-box-create))

           ;; Page 1: Dial + LCD
           (page1 (qt-widget-create))
           (page1-layout (qt-vbox-layout-create page1))
           (dial (qt-dial-create))
           (lcd (qt-lcd-create 4))

           ;; Page 2: Undo/Redo
           (page2 (qt-widget-create))
           (page2-layout (qt-vbox-layout-create page2))
           (undo-stack (qt-undo-stack-create))
           (counter-label (qt-label-create "Counter: 0"))
           (btn-row (qt-widget-create))
           (btn-layout (qt-hbox-layout-create btn-row))
           (inc-btn (qt-push-button-create "+1"))
           (dec-btn (qt-push-button-create "-1"))
           (undo-btn (qt-push-button-create "Undo"))
           (redo-btn (qt-push-button-create "Redo"))
           (status-label (qt-label-create ""))

           ;; Counter state
           (counter 0))

      ;; Configure Dial + LCD
      (qt-dial-set-range! dial 0 999)
      (qt-dial-set-notches-visible! dial #t)
      (qt-lcd-set-segment-style! lcd QT_LCD_FLAT)
      (qt-lcd-display-int! lcd 0)

      ;; Dial drives LCD
      (qt-on-dial-value-changed! dial
        (lambda (val)
          (qt-lcd-display-int! lcd val)))

      ;; Assemble page 1
      (qt-layout-add-widget! page1-layout dial)
      (qt-layout-add-widget! page1-layout lcd)

      ;; Configure Undo/Redo
      (qt-layout-add-widget! btn-layout inc-btn)
      (qt-layout-add-widget! btn-layout dec-btn)
      (qt-layout-add-widget! btn-layout undo-btn)
      (qt-layout-add-widget! btn-layout redo-btn)

      (let ((update-status!
             (lambda ()
               (qt-label-set-text! status-label
                 (string-append
                   (if (qt-undo-stack-can-undo? undo-stack)
                     (string-append "Undo: " (qt-undo-stack-undo-text undo-stack))
                     "")
                   (if (qt-undo-stack-can-redo? undo-stack)
                     (string-append "  Redo: " (qt-undo-stack-redo-text undo-stack))
                     ""))))))

        ;; +1 button
        (qt-on-clicked! inc-btn
          (lambda ()
            (let ((old counter))
              (qt-undo-stack-push! undo-stack "Increment"
                (lambda ()
                  (set! counter old)
                  (qt-label-set-text! counter-label (string-append "Counter: " (number->string counter)))
                  (update-status!))
                (lambda ()
                  (set! counter (+ old 1))
                  (qt-label-set-text! counter-label (string-append "Counter: " (number->string counter)))
                  (update-status!)))
              (update-status!))))

        ;; -1 button
        (qt-on-clicked! dec-btn
          (lambda ()
            (let ((old counter))
              (qt-undo-stack-push! undo-stack "Decrement"
                (lambda ()
                  (set! counter old)
                  (qt-label-set-text! counter-label (string-append "Counter: " (number->string counter)))
                  (update-status!))
                (lambda ()
                  (set! counter (- old 1))
                  (qt-label-set-text! counter-label (string-append "Counter: " (number->string counter)))
                  (update-status!)))
              (update-status!))))

        ;; Undo/Redo buttons
        (qt-on-clicked! undo-btn
          (lambda ()
            (when (qt-undo-stack-can-undo? undo-stack)
              (qt-undo-stack-undo! undo-stack)
              (update-status!))))

        (qt-on-clicked! redo-btn
          (lambda ()
            (when (qt-undo-stack-can-redo? undo-stack)
              (qt-undo-stack-redo! undo-stack)
              (update-status!)))))

      ;; Assemble page 2
      (qt-layout-add-widget! page2-layout counter-label)
      (qt-layout-add-widget! page2-layout btn-row)
      (qt-layout-add-widget! page2-layout status-label)

      ;; Add pages to toolbox
      (qt-tool-box-add-item! toolbox page1 "Dial + LCD")
      (qt-tool-box-add-item! toolbox page2 "Undo/Redo")

      ;; Assemble main window
      (qt-layout-add-widget! layout toolbox)
      (qt-main-window-set-central-widget! win central)
      (qt-main-window-set-title! win "Niche Widgets Demo")
      (qt-widget-resize! win 400 500)
      (qt-widget-show! win)
      (qt-app-exec! app)
      (qt-undo-stack-destroy! undo-stack))))

(main)
