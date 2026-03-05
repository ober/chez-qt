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
