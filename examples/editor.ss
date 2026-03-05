;;; editor.ss — Simple text editor with menus, toolbar, keyboard shortcuts

(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (editor (qt-plain-text-edit-create))
           (act-new   (qt-action-create "&New" win))
           (act-open  (qt-action-create "&Open..." win))
           (act-save  (qt-action-create "&Save..." win))
           (act-quit  (qt-action-create "&Quit" win))
           (act-cut   (qt-action-create "Cu&t" win))
           (act-copy  (qt-action-create "&Copy" win))
           (act-paste (qt-action-create "&Paste" win))
           (act-clear (qt-action-create "Clear &All" win))
           (act-word-wrap (qt-action-create "&Word Wrap" win))
           (menu-bar   (qt-main-window-menu-bar win))
           (file-menu  (qt-menu-bar-add-menu menu-bar "&File"))
           (edit-menu  (qt-menu-bar-add-menu menu-bar "&Edit"))
           (view-menu  (qt-menu-bar-add-menu menu-bar "&View"))
           (toolbar (qt-toolbar-create "Main"))
           (current-file #f))
      ;; shortcuts
      (qt-action-set-shortcut! act-new "Ctrl+N")
      (qt-action-set-shortcut! act-open "Ctrl+O")
      (qt-action-set-shortcut! act-save "Ctrl+S")
      (qt-action-set-shortcut! act-quit "Ctrl+Q")
      (qt-action-set-shortcut! act-cut "Ctrl+X")
      (qt-action-set-shortcut! act-copy "Ctrl+C")
      (qt-action-set-shortcut! act-paste "Ctrl+V")
      ;; status tips
      (qt-action-set-status-tip! act-new "Create a new document")
      (qt-action-set-status-tip! act-open "Open an existing file")
      (qt-action-set-status-tip! act-save "Save the current document")
      (qt-action-set-status-tip! act-quit "Quit the editor")
      ;; checkable
      (qt-action-set-checkable! act-word-wrap #t)
      (qt-action-set-checked! act-word-wrap #t)
      ;; File menu
      (qt-menu-add-action! file-menu act-new)
      (qt-menu-add-action! file-menu act-open)
      (qt-menu-add-action! file-menu act-save)
      (qt-menu-add-separator! file-menu)
      (qt-menu-add-action! file-menu act-quit)
      ;; Edit menu
      (qt-menu-add-action! edit-menu act-cut)
      (qt-menu-add-action! edit-menu act-copy)
      (qt-menu-add-action! edit-menu act-paste)
      (qt-menu-add-separator! edit-menu)
      (qt-menu-add-action! edit-menu act-clear)
      ;; View menu
      (qt-menu-add-action! view-menu act-word-wrap)
      ;; Toolbar
      (qt-main-window-add-toolbar! win toolbar)
      (qt-toolbar-add-action! toolbar act-new)
      (qt-toolbar-add-action! toolbar act-open)
      (qt-toolbar-add-action! toolbar act-save)
      (qt-toolbar-add-separator! toolbar)
      (qt-toolbar-add-action! toolbar act-cut)
      (qt-toolbar-add-action! toolbar act-copy)
      (qt-toolbar-add-action! toolbar act-paste)
      ;; Handlers
      (qt-on-triggered! act-new
        (lambda ()
          (qt-plain-text-edit-set-text! editor "")
          (set! current-file #f)
          (qt-main-window-set-title! win "Untitled — Chez-Qt Editor")
          (qt-main-window-set-status-bar-text! win "New document")))
      (qt-on-triggered! act-open
        (lambda ()
          (let ((path (qt-file-dialog-open-file win "Open File" "Text Files (*.txt);;All Files (*)")))
            (when (not (string=? path ""))
              (let ((content (call-with-input-file path get-string-all)))
                (qt-plain-text-edit-set-text! editor (or content ""))
                (set! current-file path)
                (qt-main-window-set-title! win (string-append path " — Chez-Qt Editor"))
                (qt-main-window-set-status-bar-text! win (string-append "Opened " path)))))))
      (qt-on-triggered! act-save
        (lambda ()
          (let ((path (or current-file
                          (qt-file-dialog-save-file win "Save File" "Text Files (*.txt);;All Files (*)"))))
            (when (not (string=? path ""))
              (call-with-output-file path
                (lambda (p) (display (qt-plain-text-edit-text editor) p)))
              (set! current-file path)
              (qt-main-window-set-title! win (string-append path " — Chez-Qt Editor"))
              (qt-main-window-set-status-bar-text! win (string-append "Saved " path))))))
      (qt-on-triggered! act-quit (lambda () (qt-widget-close! win)))
      (qt-on-triggered! act-clear
        (lambda ()
          (qt-plain-text-edit-clear! editor)
          (qt-main-window-set-status-bar-text! win "Cleared")))
      (qt-on-action-toggled! act-word-wrap
        (lambda (checked)
          (qt-plain-text-edit-set-line-wrap! editor
            (if checked QT_PLAIN_WIDGET_WRAP QT_PLAIN_NO_WRAP))
          (qt-main-window-set-status-bar-text! win
            (if checked "Word wrap ON" "Word wrap OFF"))))
      (qt-on-plain-text-changed! editor
        (lambda () (qt-main-window-set-status-bar-text! win "Modified")))
      ;; Window setup
      (qt-main-window-set-title! win "Untitled — Chez-Qt Editor")
      (qt-main-window-set-central-widget! win editor)
      (qt-widget-resize! win 700 500)
      (qt-main-window-set-status-bar-text! win "Ready")
      (qt-widget-show! win)
      (qt-app-exec! app))))
(main)
