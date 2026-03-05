;;; terminal.ss — Simple terminal demonstrating QProcess with QPlainTextEdit

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-vbox-layout-create central))
           ;; Output display
           (output (qt-plain-text-edit-create))
           ;; Input area
           (input-box (qt-widget-create))
           (input-layout (qt-hbox-layout-create input-box))
           (prompt-label (qt-label-create "$ "))
           (input (qt-line-edit-create))
           (run-btn (qt-push-button-create "Run"))
           ;; Active process
           (proc #f))

      ;; Append text to output
      (define (append-output text)
        (qt-plain-text-edit-append! output text))

      ;; Run a command
      (define (run-command)
        (let ((cmd (qt-line-edit-text input)))
          (when (> (string-length cmd) 0)
            ;; Clean up previous process
            (when proc
              (qt-process-destroy! proc)
              (set! proc #f))

            (append-output (format #f "$ ~a" cmd))
            (qt-line-edit-set-text! input "")

            ;; Create and start process
            (set! proc (qt-process-create))

            ;; Ready-read callback
            (qt-on-process-ready-read! proc
              (lambda ()
                (let ((out (qt-process-read-stdout proc)))
                  (when (> (string-length out) 0)
                    (append-output out)))))

            ;; Finished callback
            (qt-on-process-finished! proc
              (lambda (code)
                (let ((err (qt-process-read-stderr proc)))
                  (when (> (string-length err) 0)
                    (append-output err)))
                (append-output (format #f "[exit ~a]" code))))

            ;; Start via sh -c
            (qt-process-start! proc "/bin/sh" (list "-c" cmd)))))

      ;; Configure output area
      (qt-plain-text-edit-set-read-only! output #t)
      (qt-plain-text-edit-set-max-block-count! output 10000)

      ;; Configure input
      (qt-line-edit-set-placeholder! input "Enter command...")

      ;; Set monospace font
      (let ((mono (qt-font-create "Monospace" 10)))
        (qt-widget-set-font! output mono)
        (qt-widget-set-font! input mono)
        (qt-widget-set-font! prompt-label mono)
        (qt-font-destroy! mono))

      ;; Build input row
      (qt-layout-add-widget! input-layout prompt-label)
      (qt-layout-add-widget! input-layout input)
      (qt-layout-add-widget! input-layout run-btn)

      ;; Build main layout
      (qt-layout-add-widget! layout output)
      (qt-layout-add-widget! layout input-box)

      ;; Connect signals
      (qt-on-clicked! run-btn (lambda () (run-command)))
      (qt-on-return-pressed! input (lambda () (run-command)))

      ;; Window setup
      (qt-main-window-set-central-widget! win central)
      (qt-main-window-set-title! win "Chez Terminal")
      (qt-widget-resize! win 700 500)
      (qt-widget-show! win)

      ;; Welcome message
      (append-output "Chez Terminal — Type a command and press Enter or Run")
      (append-output "")

      (qt-app-exec! app)

      ;; Cleanup
      (when proc
        (qt-process-destroy! proc)))))

(main)
