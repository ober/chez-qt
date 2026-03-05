(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-vbox-layout-create central))
           (launch-btn (qt-push-button-create "Launch Wizard"))
           (status (qt-label-create "Click to start the wizard"))
           (result-label (qt-label-create "")))
      ;; wizard launcher
      (qt-on-clicked! launch-btn
        (lambda ()
          (let* ((wiz (qt-wizard-create win))
                 ;; page 1: welcome
                 (page1 (qt-wizard-page-create))
                 (p1-layout (qt-vbox-layout-create page1))
                 (p1-label (qt-label-create "Welcome to the Chez-Qt Wizard.\nThis demonstrates wizard pages with various controls."))
                 ;; page 2: radio buttons
                 (page2 (qt-wizard-page-create))
                 (p2-layout (qt-vbox-layout-create page2))
                 (p2-label (qt-label-create "Choose your preference:"))
                 (radio1 (qt-radio-button-create "Option A"))
                 (radio2 (qt-radio-button-create "Option B"))
                 (radio3 (qt-radio-button-create "Option C"))
                 (btn-group (qt-button-group-create))
                 ;; page 3: checkboxes in group box
                 (page3 (qt-wizard-page-create))
                 (p3-layout (qt-vbox-layout-create page3))
                 (group-box (qt-group-box-create "Features"))
                 (gb-layout (qt-vbox-layout-create group-box))
                 (cb1 (qt-check-box-create "Feature 1"))
                 (cb2 (qt-check-box-create "Feature 2"))
                 (cb3 (qt-check-box-create "Feature 3"))
                 ;; page 4: summary
                 (page4 (qt-wizard-page-create))
                 (p4-layout (qt-vbox-layout-create page4))
                 (summary (qt-label-create "Click Finish to complete.")))
            ;; page 1
            (qt-wizard-page-set-title! page1 "Welcome")
            (qt-label-set-word-wrap! p1-label #t)
            (qt-layout-add-widget! p1-layout p1-label)
            ;; page 2
            (qt-wizard-page-set-title! page2 "Preferences")
            (qt-layout-add-widget! p2-layout p2-label)
            (qt-layout-add-widget! p2-layout radio1)
            (qt-layout-add-widget! p2-layout radio2)
            (qt-layout-add-widget! p2-layout radio3)
            (qt-button-group-add-button! btn-group radio1 0)
            (qt-button-group-add-button! btn-group radio2 1)
            (qt-button-group-add-button! btn-group radio3 2)
            (qt-radio-button-set-checked! radio1 #t)
            (qt-on-button-group-clicked! btn-group
              (lambda (id)
                (qt-label-set-text! status (format #f "Selected option ~a" id))))
            ;; page 3
            (qt-wizard-page-set-title! page3 "Features")
            (qt-group-box-set-checkable! group-box #t)
            (qt-group-box-set-checked! group-box #t)
            (qt-layout-add-widget! gb-layout cb1)
            (qt-layout-add-widget! gb-layout cb2)
            (qt-layout-add-widget! gb-layout cb3)
            (qt-check-box-set-checked! cb1 #t)
            (qt-layout-add-widget! p3-layout group-box)
            (qt-on-group-box-toggled! group-box
              (lambda (checked)
                (qt-label-set-text! status
                  (if checked "Features enabled" "Features disabled"))))
            ;; page 4
            (qt-wizard-page-set-title! page4 "Summary")
            (qt-layout-add-widget! p4-layout summary)
            ;; add pages
            (qt-wizard-add-page! wiz page1)
            (qt-wizard-add-page! wiz page2)
            (qt-wizard-add-page! wiz page3)
            (qt-wizard-add-page! wiz page4)
            ;; wizard signals
            (qt-on-wizard-current-changed! wiz
              (lambda (id)
                (qt-label-set-text! status (format #f "Wizard page: ~a" id))))
            (qt-wizard-set-title! wiz "Chez-Qt Wizard")
            (qt-widget-resize! wiz 500 400)
            ;; run
            (let ((result (qt-wizard-exec! wiz)))
              (qt-label-set-text! result-label
                (if (= result 1) "Wizard completed!" "Wizard cancelled."))))))
      ;; main layout
      (qt-label-set-alignment! status QT_ALIGN_CENTER)
      (qt-label-set-alignment! result-label QT_ALIGN_CENTER)
      (qt-layout-add-stretch! layout)
      (qt-layout-add-widget! layout launch-btn)
      (qt-layout-add-spacing! layout 10)
      (qt-layout-add-widget! layout status)
      (qt-layout-add-widget! layout result-label)
      (qt-layout-add-stretch! layout)
      ;; window
      (qt-main-window-set-title! win "Wizard Demo")
      (qt-main-window-set-central-widget! win central)
      (qt-widget-resize! win 400 300)
      (qt-widget-show! win)
      (qt-app-exec! app))))

(main)
