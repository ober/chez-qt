;;; Form example: exercises Phase 2 widgets
;;; QLineEdit, QCheckBox, QComboBox, QSpinBox, QPushButton + QMessageBox

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-vbox-layout-create central))
           ;; Name input
           (name-edit (qt-line-edit-create))
           ;; Color selector
           (color-combo (qt-combo-box-create))
           ;; Age spinner
           (age-spin (qt-spin-box-create))
           ;; Newsletter toggle
           (news-check (qt-check-box-create "Subscribe to newsletter"))
           ;; Submit button
           (submit-btn (qt-push-button-create "Submit")))

      ;; Configure name input
      (qt-line-edit-set-placeholder! name-edit "Enter your name...")

      ;; Configure color selector
      (qt-combo-box-add-item! color-combo "Red")
      (qt-combo-box-add-item! color-combo "Green")
      (qt-combo-box-add-item! color-combo "Blue")
      (qt-combo-box-add-item! color-combo "Yellow")

      ;; Configure age spinner
      (qt-spin-box-set-range! age-spin 1 120)
      (qt-spin-box-set-value! age-spin 25)
      (qt-spin-box-set-suffix! age-spin " years")

      ;; Add widgets with labels
      (let ((name-label (qt-label-create "Name:"))
            (color-label (qt-label-create "Favorite color:"))
            (age-label (qt-label-create "Age:")))
        (qt-layout-add-widget! layout name-label)
        (qt-layout-add-widget! layout name-edit)
        (qt-layout-add-widget! layout color-label)
        (qt-layout-add-widget! layout color-combo)
        (qt-layout-add-widget! layout age-label)
        (qt-layout-add-widget! layout age-spin)
        (qt-layout-add-widget! layout news-check)
        (qt-layout-add-widget! layout submit-btn))

      (qt-layout-set-spacing! layout 8)
      (qt-layout-set-margins! layout 16 16 16 16)

      ;; Submit button shows summary in a message box
      (qt-on-clicked! submit-btn
        (lambda ()
          (let ((name (qt-line-edit-text name-edit))
                (color (qt-combo-box-current-text color-combo))
                (age (qt-spin-box-value age-spin))
                (subscribed (qt-check-box-checked? news-check)))
            (qt-message-box-information win "Form Summary"
              (string-append
                "Name: " name "\n"
                "Color: " color "\n"
                "Age: " (number->string age) "\n"
                "Newsletter: " (if subscribed "Yes" "No"))))))

      (qt-main-window-set-title! win "Form Demo")
      (qt-main-window-set-central-widget! win central)
      (qt-widget-resize! win 350 350)
      (qt-widget-show! win)
      (qt-app-exec! app))))

(main)
