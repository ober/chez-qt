;;; painter.ss — QPainter demo: draw shapes, text, and composited images

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-vbox-layout-create central))

           ;; Create a canvas pixmap and paint on it
           (canvas (qt-pixmap-create-blank 400 300))
           (p (qt-painter-create canvas))

           ;; Display label
           (label (qt-label-create ""))

           ;; Status
           (status-label (qt-label-create "QPainter Demo")))

      ;; Fill background
      (qt-pixmap-fill! canvas 30 30 30)

      ;; Enable antialiasing
      (qt-painter-set-antialiasing! p #t)

      ;; Draw a grid of lines
      (qt-painter-set-pen-color! p 60 60 60)
      (qt-painter-set-pen-width! p 1)
      (let loop ((x 0))
        (when (< x 400)
          (qt-painter-draw-line! p x 0 x 300)
          (loop (+ x 20))))
      (let loop ((y 0))
        (when (< y 300)
          (qt-painter-draw-line! p 0 y 400 y)
          (loop (+ y 20))))

      ;; Draw filled rectangles
      (qt-painter-fill-rect! p 20 20 80 60 200 50 50)   ;; Red
      (qt-painter-fill-rect! p 120 20 80 60 50 200 50)  ;; Green
      (qt-painter-fill-rect! p 220 20 80 60 50 50 200)  ;; Blue

      ;; Draw outlined rectangle with thick pen
      (qt-painter-set-pen-color! p 255 255 0)
      (qt-painter-set-pen-width! p 3)
      (qt-painter-set-brush-color! p 255 255 0 40)
      (qt-painter-draw-rect! p 320 20 60 60)

      ;; Draw ellipses
      (qt-painter-set-pen-color! p 0 255 255)
      (qt-painter-set-pen-width! p 2)
      (qt-painter-set-brush-color! p 0 255 255 60)
      (qt-painter-draw-ellipse! p 40 110 120 80)

      ;; Draw a circle
      (qt-painter-set-pen-color! p 255 0 255)
      (qt-painter-set-brush-color! p 255 0 255 60)
      (qt-painter-draw-ellipse! p 200 110 80 80)

      ;; Draw an arc (quarter circle)
      (qt-painter-set-pen-color! p 255 200 0)
      (qt-painter-set-pen-width! p 3)
      (qt-painter-draw-arc! p 300 110 80 80 0 (* 90 16))

      ;; Draw text with different fonts
      (let ((title-font (qt-font-create "Sans" 24)))
        (qt-font-set-bold! title-font #t)
        (qt-painter-set-font! p title-font)
        (qt-painter-set-pen-color! p 255 255 255)
        (qt-painter-draw-text! p 20 240 "Chez-Qt Painter")
        (qt-font-destroy! title-font))

      (let ((small-font (qt-font-create "Monospace" 10)))
        (qt-painter-set-font! p small-font)
        (qt-painter-set-pen-color! p 180 180 180)
        (qt-painter-draw-text! p 20 270 "Lines | Rects | Ellipses | Arcs | Text")
        (qt-font-destroy! small-font))

      ;; Draw some points
      (qt-painter-set-pen-color! p 255 255 255)
      (qt-painter-set-pen-width! p 4)
      (let loop ((i 0))
        (when (< i 20)
          (qt-painter-draw-point! p (+ 320 (* i 4)) 250)
          (loop (+ i 1))))

      ;; Use save/restore for a rotated shape
      (qt-painter-save! p)
      (qt-painter-translate! p 350 250)
      (qt-painter-rotate! p 30.0)
      (qt-painter-set-pen-color! p 100 255 100)
      (qt-painter-set-pen-width! p 2)
      (qt-painter-draw-rect! p -20 -15 40 30)
      (qt-painter-restore! p)

      ;; Finish painting
      (qt-painter-end! p)
      (qt-painter-destroy! p)

      ;; Display on label
      (qt-label-set-pixmap! label canvas)

      (qt-layout-add-widget! layout label)
      (qt-layout-add-widget! layout status-label)

      (qt-main-window-set-central-widget! win central)
      (qt-main-window-set-title! win "QPainter Demo")
      (qt-widget-resize! win 440 360)
      (qt-widget-show! win)

      (qt-app-exec! app)

      ;; Cleanup
      (qt-pixmap-destroy! canvas))))

(main)
