;;; qt-test.ss — Test suite for chez-qt
;;;
;;; Run: QT_QPA_PLATFORM=offscreen scheme --libdirs . --script qt-test.ss

(import (chez-qt qt))

(define *pass* 0)
(define *fail* 0)
(define *test-name* "")

(define-syntax test-group
  (syntax-rules ()
    [(_ name body ...)
     (begin
       (display (string-append "\n=== " name " ===\n"))
       body ...)]))

(define-syntax test-case
  (syntax-rules ()
    [(_ name body ...)
     (begin
       (set! *test-name* name)
       (guard (e [#t (set! *fail* (+ *fail* 1))
                     (display (string-append "  FAIL: " name "\n"))
                     (display (string-append "    error: "
                                (if (message-condition? e)
                                    (condition-message e)
                                    (format "~s" e))
                                "\n"))])
         body ...
         (set! *pass* (+ *pass* 1))
         (display (string-append "  pass: " name "\n"))))]))

(define-syntax check
  (syntax-rules (=> ?)
    [(_ expr => expected)
     (let ([got expr] [exp expected])
       (unless (equal? got exp)
         (error 'check
                (format "~a: expected ~s, got ~s" *test-name* exp got))))]
    [(_ expr ? pred)
     (let ([got expr])
       (unless (pred got)
         (error 'check
                (format "~a: predicate failed for ~s" *test-name* got))))]))

;; Create the QApplication (required for all Qt tests)
(define test-app (qt-app-create))

;; ==================== Phase 1: Core ====================

(test-group "core"
  (test-case "application create"
    (check (not (eqv? test-app 0)) ? values))

  (test-case "main window create"
    (let ((win (qt-main-window-create)))
      (check (not (eqv? win 0)) ? values)
      (qt-main-window-set-title! win "Test Window")
      (qt-widget-destroy! win)))

  (test-case "widget create"
    (let ((w (qt-widget-create)))
      (check (not (eqv? w 0)) ? values)
      (qt-widget-destroy! w)))

  (test-case "widget enabled round-trip"
    (let ((w (qt-widget-create)))
      (check (qt-widget-enabled? w) => #t)
      (qt-widget-set-enabled! w #f)
      (check (qt-widget-enabled? w) => #f)
      (qt-widget-set-enabled! w #t)
      (check (qt-widget-enabled? w) => #t)
      (qt-widget-destroy! w)))

  (test-case "widget visible round-trip"
    (let ((w (qt-widget-create)))
      (check (qt-widget-visible? w) => #f)
      (qt-widget-set-visible! w #t)
      (check (qt-widget-visible? w) => #t)
      (qt-widget-set-visible! w #f)
      (check (qt-widget-visible? w) => #f)
      (qt-widget-destroy! w)))

  (test-case "layout create"
    (let* ((w (qt-widget-create))
           (vbox (qt-vbox-layout-create w))
           (w2 (qt-widget-create))
           (hbox (qt-hbox-layout-create w2)))
      (check (not (eqv? vbox 0)) ? values)
      (check (not (eqv? hbox 0)) ? values)
      (qt-widget-destroy! w)
      (qt-widget-destroy! w2)))

  (test-case "label text round-trip"
    (let ((l (qt-label-create "hello")))
      (check (qt-label-text l) => "hello")
      (qt-label-set-text! l "world")
      (check (qt-label-text l) => "world")
      (qt-widget-destroy! l)))

  (test-case "label word wrap"
    (let ((l (qt-label-create "long text")))
      (qt-label-set-word-wrap! l #t)
      (qt-label-set-word-wrap! l #f)
      (qt-widget-destroy! l)))

  (test-case "widget minimum/maximum width and height"
    (let ((w (qt-widget-create)))
      (qt-widget-set-minimum-width! w 100)
      (qt-widget-set-minimum-height! w 50)
      (qt-widget-set-maximum-width! w 800)
      (qt-widget-set-maximum-height! w 600)
      (qt-widget-destroy! w)))

  (test-case "widget set cursor"
    (let ((w (qt-widget-create)))
      (qt-widget-set-cursor! w QT_CURSOR_POINTING_HAND)
      (qt-widget-set-cursor! w QT_CURSOR_WAIT)
      (qt-widget-unset-cursor! w)
      (qt-widget-destroy! w)))

  (test-case "push button text round-trip"
    (let ((b (qt-push-button-create "Click")))
      (check (qt-push-button-text b) => "Click")
      (qt-push-button-set-text! b "Press")
      (check (qt-push-button-text b) => "Press")
      (qt-widget-destroy! b)))

  (test-case "button clicked signal registration"
    (let ((b (qt-push-button-create "Test")))
      (qt-on-clicked! b (lambda () #t))
      (qt-widget-destroy! b))))

;; ==================== Phase 2: Core Widgets ====================

(test-group "core widgets"
  (test-case "line edit text round-trip"
    (let ((e (qt-line-edit-create)))
      (qt-line-edit-set-text! e "test input")
      (check (qt-line-edit-text e) => "test input")
      (qt-line-edit-set-text! e "")
      (check (qt-line-edit-text e) => "")
      (qt-widget-destroy! e)))

  (test-case "line edit placeholder and read-only"
    (let ((e (qt-line-edit-create)))
      (qt-line-edit-set-placeholder! e "Enter text...")
      (qt-line-edit-set-read-only! e #t)
      (qt-widget-destroy! e)))

  (test-case "line edit echo mode"
    (let ((e (qt-line-edit-create)))
      (qt-line-edit-set-echo-mode! e QT_ECHO_PASSWORD)
      (qt-line-edit-set-echo-mode! e QT_ECHO_NORMAL)
      (qt-widget-destroy! e)))

  (test-case "line edit signal registration"
    (let ((e (qt-line-edit-create)))
      (qt-on-text-changed! e (lambda (text) #t))
      (qt-on-return-pressed! e (lambda () #t))
      (qt-widget-destroy! e)))

  (test-case "check box checked round-trip"
    (let ((c (qt-check-box-create "Option")))
      (check (qt-check-box-checked? c) => #f)
      (qt-check-box-set-checked! c #t)
      (check (qt-check-box-checked? c) => #t)
      (qt-check-box-set-checked! c #f)
      (check (qt-check-box-checked? c) => #f)
      (qt-widget-destroy! c)))

  (test-case "check box set text"
    (let ((c (qt-check-box-create "Before")))
      (qt-check-box-set-text! c "After")
      (qt-widget-destroy! c)))

  (test-case "check box signal registration"
    (let ((c (qt-check-box-create "Test")))
      (qt-on-toggled! c (lambda (checked) #t))
      (qt-widget-destroy! c)))

  (test-case "combo box add items and round-trip"
    (let ((c (qt-combo-box-create)))
      (check (qt-combo-box-count c) => 0)
      (qt-combo-box-add-item! c "Apple")
      (qt-combo-box-add-item! c "Banana")
      (qt-combo-box-add-item! c "Cherry")
      (check (qt-combo-box-count c) => 3)
      (check (qt-combo-box-current-index c) => 0)
      (check (qt-combo-box-current-text c) => "Apple")
      (qt-combo-box-set-current-index! c 2)
      (check (qt-combo-box-current-index c) => 2)
      (check (qt-combo-box-current-text c) => "Cherry")
      (qt-widget-destroy! c)))

  (test-case "combo box clear"
    (let ((c (qt-combo-box-create)))
      (qt-combo-box-add-item! c "X")
      (qt-combo-box-add-item! c "Y")
      (check (qt-combo-box-count c) => 2)
      (qt-combo-box-clear! c)
      (check (qt-combo-box-count c) => 0)
      (qt-widget-destroy! c)))

  (test-case "combo box signal registration"
    (let ((c (qt-combo-box-create)))
      (qt-on-index-changed! c (lambda (idx) #t))
      (qt-widget-destroy! c)))

  (test-case "text edit text round-trip"
    (let ((e (qt-text-edit-create)))
      (qt-text-edit-set-text! e "Hello World")
      (check (qt-text-edit-text e) => "Hello World")
      (qt-widget-destroy! e)))

  (test-case "text edit append and clear"
    (let ((e (qt-text-edit-create)))
      (qt-text-edit-set-text! e "Line 1")
      (qt-text-edit-append! e "Line 2")
      (qt-text-edit-clear! e)
      (check (qt-text-edit-text e) => "")
      (qt-widget-destroy! e)))

  (test-case "text edit html"
    (let ((e (qt-text-edit-create)))
      (qt-text-edit-set-text! e "Hello World")
      (let ((html (qt-text-edit-html e)))
        (check (string? html) ? values))
      (qt-widget-destroy! e)))

  (test-case "text edit signal registration"
    (let ((e (qt-text-edit-create)))
      (qt-on-text-edit-changed! e (lambda () #t))
      (qt-widget-destroy! e)))

  (test-case "spin box value round-trip"
    (let ((s (qt-spin-box-create)))
      (qt-spin-box-set-range! s 0 100)
      (qt-spin-box-set-value! s 42)
      (check (qt-spin-box-value s) => 42)
      (qt-spin-box-set-value! s 0)
      (check (qt-spin-box-value s) => 0)
      (qt-widget-destroy! s)))

  (test-case "spin box range clamping"
    (let ((s (qt-spin-box-create)))
      (qt-spin-box-set-range! s 10 50)
      (qt-spin-box-set-value! s 100)
      (check (qt-spin-box-value s) => 50)
      (qt-spin-box-set-value! s -5)
      (check (qt-spin-box-value s) => 10)
      (qt-widget-destroy! s)))

  (test-case "spin box prefix and suffix"
    (let ((s (qt-spin-box-create)))
      (qt-spin-box-set-prefix! s "$")
      (qt-spin-box-set-suffix! s " USD")
      (qt-widget-destroy! s)))

  (test-case "spin box signal registration"
    (let ((s (qt-spin-box-create)))
      (qt-on-value-changed! s (lambda (val) #t))
      (qt-widget-destroy! s)))

  (test-case "dialog create"
    (let ((d (qt-dialog-create)))
      (qt-dialog-set-title! d "Test Dialog")
      (qt-widget-destroy! d))))

;; ==================== Constants ====================

(test-group "constants"
  (test-case "echo mode constants"
    (check QT_ECHO_NORMAL => 0)
    (check QT_ECHO_NO_ECHO => 1)
    (check QT_ECHO_PASSWORD => 2)
    (check QT_ECHO_PASSWORD_ON_EDIT => 3))

  (test-case "alignment constants"
    (check QT_ALIGN_LEFT => #x0001)
    (check QT_ALIGN_RIGHT => #x0002)
    (check QT_ALIGN_CENTER => #x0084)
    (check QT_ALIGN_TOP => #x0020)
    (check QT_ALIGN_BOTTOM => #x0040))

  (test-case "orientation constants"
    (check QT_HORIZONTAL => #x1)
    (check QT_VERTICAL => #x2)))

;; ==================== Phase 3: Menus, Actions, Toolbars ====================

(test-group "menus and actions"
  (test-case "menu bar from main window"
    (let* ((win (qt-main-window-create))
           (bar (qt-main-window-menu-bar win)))
      (check (not (eqv? bar 0)) ? values)
      (qt-widget-destroy! win)))

  (test-case "menu and submenu creation"
    (let* ((win (qt-main-window-create))
           (bar (qt-main-window-menu-bar win))
           (file-menu (qt-menu-bar-add-menu bar "File"))
           (sub-menu (qt-menu-add-menu file-menu "Recent")))
      (check (not (eqv? file-menu 0)) ? values)
      (check (not (eqv? sub-menu 0)) ? values)
      (qt-widget-destroy! win)))

  (test-case "action create and text round-trip"
    (let ((a (qt-action-create "Open")))
      (check (qt-action-text a) => "Open")
      (qt-action-set-text! a "Close")
      (check (qt-action-text a) => "Close")))

  (test-case "action enabled round-trip"
    (let ((a (qt-action-create "Test")))
      (check (qt-action-enabled? a) => #t)
      (qt-action-set-enabled! a #f)
      (check (qt-action-enabled? a) => #f)
      (qt-action-set-enabled! a #t)
      (check (qt-action-enabled? a) => #t)))

  (test-case "action checkable round-trip"
    (let ((a (qt-action-create "Toggle")))
      (check (qt-action-checkable? a) => #f)
      (qt-action-set-checkable! a #t)
      (check (qt-action-checkable? a) => #t)
      (qt-action-set-checked! a #t)
      (check (qt-action-checked? a) => #t)
      (qt-action-set-checked! a #f)
      (check (qt-action-checked? a) => #f)))

  (test-case "action shortcut and tips"
    (let ((a (qt-action-create "Save")))
      (qt-action-set-shortcut! a "Ctrl+S")
      (qt-action-set-tooltip! a "Save file")
      (qt-action-set-status-tip! a "Save current file")))

  (test-case "action signal registration"
    (let ((a (qt-action-create "Act")))
      (qt-on-triggered! a (lambda () #t))
      (qt-action-set-checkable! a #t)
      (qt-on-action-toggled! a (lambda (checked) #t))))

  (test-case "menu add action and separator"
    (let* ((win (qt-main-window-create))
           (bar (qt-main-window-menu-bar win))
           (menu (qt-menu-bar-add-menu bar "Edit"))
           (act (qt-action-create "Cut")))
      (qt-menu-add-action! menu act)
      (qt-menu-add-separator! menu)
      (qt-widget-destroy! win)))

  (test-case "toolbar create and add action"
    (let* ((win (qt-main-window-create))
           (tb (qt-toolbar-create "Main")))
      (qt-main-window-add-toolbar! win tb)
      (let ((act (qt-action-create "Toolbar Action")))
        (qt-toolbar-add-action! tb act)
        (qt-toolbar-add-separator! tb))
      (qt-toolbar-set-movable! tb #f)
      (qt-toolbar-set-icon-size! tb 24 24)
      (qt-widget-destroy! win)))

  (test-case "toolbar add widget"
    (let* ((win (qt-main-window-create))
           (tb (qt-toolbar-create "Tools"))
           (btn (qt-push-button-create "TB Button")))
      (qt-main-window-add-toolbar! win tb)
      (qt-toolbar-add-widget! tb btn)
      (qt-widget-destroy! win)))

  (test-case "status bar text"
    (let ((win (qt-main-window-create)))
      (qt-main-window-set-status-bar-text! win "Ready")
      (qt-widget-destroy! win))))

;; ==================== Phase 4: Advanced Widgets ====================

(test-group "list widget"
  (test-case "list widget add and count"
    (let ((l (qt-list-widget-create)))
      (check (qt-list-widget-count l) => 0)
      (qt-list-widget-add-item! l "Item 1")
      (qt-list-widget-add-item! l "Item 2")
      (qt-list-widget-add-item! l "Item 3")
      (check (qt-list-widget-count l) => 3)
      (qt-widget-destroy! l)))

  (test-case "list widget item text"
    (let ((l (qt-list-widget-create)))
      (qt-list-widget-add-item! l "Alpha")
      (qt-list-widget-add-item! l "Beta")
      (qt-list-widget-add-item! l "Gamma")
      (check (qt-list-widget-item-text l 0) => "Alpha")
      (check (qt-list-widget-item-text l 1) => "Beta")
      (check (qt-list-widget-item-text l 2) => "Gamma")
      (qt-widget-destroy! l)))

  (test-case "list widget insert item"
    (let ((l (qt-list-widget-create)))
      (qt-list-widget-add-item! l "First")
      (qt-list-widget-add-item! l "Third")
      (qt-list-widget-insert-item! l 1 "Second")
      (check (qt-list-widget-count l) => 3)
      (check (qt-list-widget-item-text l 0) => "First")
      (check (qt-list-widget-item-text l 1) => "Second")
      (check (qt-list-widget-item-text l 2) => "Third")
      (qt-widget-destroy! l)))

  (test-case "list widget remove item"
    (let ((l (qt-list-widget-create)))
      (qt-list-widget-add-item! l "A")
      (qt-list-widget-add-item! l "B")
      (qt-list-widget-add-item! l "C")
      (qt-list-widget-remove-item! l 1)
      (check (qt-list-widget-count l) => 2)
      (check (qt-list-widget-item-text l 0) => "A")
      (check (qt-list-widget-item-text l 1) => "C")
      (qt-widget-destroy! l)))

  (test-case "list widget current row"
    (let ((l (qt-list-widget-create)))
      (qt-list-widget-add-item! l "X")
      (qt-list-widget-add-item! l "Y")
      (qt-list-widget-set-current-row! l 1)
      (check (qt-list-widget-current-row l) => 1)
      (qt-list-widget-set-current-row! l 0)
      (check (qt-list-widget-current-row l) => 0)
      (qt-widget-destroy! l)))

  (test-case "list widget clear"
    (let ((l (qt-list-widget-create)))
      (qt-list-widget-add-item! l "A")
      (qt-list-widget-add-item! l "B")
      (check (qt-list-widget-count l) => 2)
      (qt-list-widget-clear! l)
      (check (qt-list-widget-count l) => 0)
      (qt-widget-destroy! l)))

  (test-case "list widget signal registration"
    (let ((l (qt-list-widget-create)))
      (qt-on-current-row-changed! l (lambda (row) #t))
      (qt-on-item-double-clicked! l (lambda (row) #t))
      (qt-widget-destroy! l)))

  (test-case "list widget item data round-trip"
    (let ((l (qt-list-widget-create)))
      (qt-list-widget-add-item! l "Visible Text")
      (qt-list-widget-set-item-data! l 0 "hidden-id-123")
      (check (qt-list-widget-item-data l 0) => "hidden-id-123")
      (check (qt-list-widget-item-text l 0) => "Visible Text")
      (qt-widget-destroy! l))))

(test-group "table widget"
  (test-case "table widget create with dimensions"
    (let ((t (qt-table-widget-create 3 4)))
      (check (qt-table-widget-row-count t) => 3)
      (check (qt-table-widget-column-count t) => 4)
      (qt-widget-destroy! t)))

  (test-case "table widget set/get item text"
    (let ((t (qt-table-widget-create 2 2)))
      (qt-table-widget-set-item! t 0 0 "A1")
      (qt-table-widget-set-item! t 0 1 "B1")
      (qt-table-widget-set-item! t 1 0 "A2")
      (qt-table-widget-set-item! t 1 1 "B2")
      (check (qt-table-widget-item-text t 0 0) => "A1")
      (check (qt-table-widget-item-text t 0 1) => "B1")
      (check (qt-table-widget-item-text t 1 0) => "A2")
      (check (qt-table-widget-item-text t 1 1) => "B2")
      (qt-widget-destroy! t)))

  (test-case "table widget empty cell returns empty string"
    (let ((t (qt-table-widget-create 2 2)))
      (check (qt-table-widget-item-text t 0 0) => "")
      (qt-widget-destroy! t)))

  (test-case "table widget resize row/column counts"
    (let ((t (qt-table-widget-create 2 2)))
      (qt-table-widget-set-row-count! t 5)
      (qt-table-widget-set-column-count! t 3)
      (check (qt-table-widget-row-count t) => 5)
      (check (qt-table-widget-column-count t) => 3)
      (qt-widget-destroy! t)))

  (test-case "table widget header items"
    (let ((t (qt-table-widget-create 2 3)))
      (qt-table-widget-set-horizontal-header! t 0 "Name")
      (qt-table-widget-set-horizontal-header! t 1 "Age")
      (qt-table-widget-set-horizontal-header! t 2 "City")
      (qt-table-widget-set-vertical-header! t 0 "Row 1")
      (qt-table-widget-set-vertical-header! t 1 "Row 2")
      (qt-widget-destroy! t)))

  (test-case "table widget clear"
    (let ((t (qt-table-widget-create 2 2)))
      (qt-table-widget-set-item! t 0 0 "data")
      (qt-table-widget-clear! t)
      (check (qt-table-widget-item-text t 0 0) => "")
      (qt-widget-destroy! t)))

  (test-case "table widget signal registration"
    (let ((t (qt-table-widget-create 2 2)))
      (qt-on-cell-clicked! t (lambda () #t))
      (qt-widget-destroy! t))))

(test-group "tab widget"
  (test-case "tab widget add tabs"
    (let* ((tw (qt-tab-widget-create))
           (page1 (qt-widget-create))
           (page2 (qt-widget-create)))
      (check (qt-tab-widget-count tw) => 0)
      (qt-tab-widget-add-tab! tw page1 "Tab 1")
      (qt-tab-widget-add-tab! tw page2 "Tab 2")
      (check (qt-tab-widget-count tw) => 2)
      (qt-widget-destroy! tw)))

  (test-case "tab widget current index"
    (let* ((tw (qt-tab-widget-create))
           (page1 (qt-widget-create))
           (page2 (qt-widget-create)))
      (qt-tab-widget-add-tab! tw page1 "Tab 1")
      (qt-tab-widget-add-tab! tw page2 "Tab 2")
      (check (qt-tab-widget-current-index tw) => 0)
      (qt-tab-widget-set-current-index! tw 1)
      (check (qt-tab-widget-current-index tw) => 1)
      (qt-widget-destroy! tw)))

  (test-case "tab widget signal registration"
    (let ((tw (qt-tab-widget-create)))
      (qt-on-tab-changed! tw (lambda (idx) #t))
      (qt-widget-destroy! tw))))

(test-group "tree widget"
  (test-case "tree widget create"
    (let ((t (qt-tree-widget-create)))
      (qt-tree-widget-set-column-count! t 2)
      (check (qt-tree-widget-column-count t) => 2)
      (qt-tree-widget-set-header-label! t "Name")
      (qt-widget-destroy! t)))

  (test-case "tree widget items"
    (let ((t (qt-tree-widget-create)))
      (qt-tree-widget-set-column-count! t 1)
      (let ((item (qt-tree-item-create "Root")))
        (qt-tree-widget-add-top-level-item! t item)
        (check (qt-tree-widget-top-level-item-count t) => 1)
        (check (qt-tree-item-text item 0) => "Root")
        (let ((child (qt-tree-item-create "Child")))
          (qt-tree-item-add-child! item child)
          (check (qt-tree-item-child-count item) => 1)))
      (qt-widget-destroy! t)))

  (test-case "tree widget signals"
    (let ((t (qt-tree-widget-create)))
      (qt-on-current-item-changed! t (lambda () #t))
      (qt-on-tree-item-double-clicked! t (lambda () #t))
      (qt-on-item-expanded! t (lambda () #t))
      (qt-on-item-collapsed! t (lambda () #t))
      (qt-widget-destroy! t))))

;; ==================== Phase 5: Timer, Clipboard ====================

(test-group "timer"
  (test-case "timer create and configure"
    (let ((tm (qt-timer-create)))
      (qt-timer-set-interval! tm 1000)
      (check (qt-timer-interval tm) => 1000)
      (qt-timer-set-single-shot! tm #t)
      (qt-on-timeout! tm (lambda () #t))
      (qt-timer-destroy! tm)))

  (test-case "timer start/stop"
    (let ((tm (qt-timer-create)))
      (qt-timer-set-interval! tm 500)
      (check (qt-timer-active? tm) => #f)
      (qt-timer-start! tm 500)
      (check (qt-timer-active? tm) => #t)
      (qt-timer-stop! tm)
      (check (qt-timer-active? tm) => #f)
      (qt-timer-destroy! tm))))

(test-group "clipboard"
  (test-case "clipboard text round-trip"
    (qt-clipboard-set-text! test-app "chez-qt test")
    (check (qt-clipboard-text test-app) => "chez-qt test")))

;; ==================== Phase 6: Keyboard, Window State ====================

(test-group "keyboard and window state"
  (test-case "key handler registration"
    (let ((w (qt-widget-create)))
      (qt-on-key-press! w (lambda () #t))
      (qt-widget-destroy! w)))

  (test-case "window state functions"
    (let ((win (qt-main-window-create)))
      (qt-widget-show-minimized! win)
      (qt-widget-show-normal! win)
      (qt-widget-move! win 100 100)
      (qt-widget-destroy! win)))

  (test-case "widget geometry"
    (let ((w (qt-widget-create)))
      (qt-widget-resize! w 200 150)
      (qt-widget-destroy! w))))

;; ==================== Phase 7: Pixmap, Icon, Radio, Groups ====================

(test-group "radio buttons and groups"
  (test-case "radio button create"
    (let ((r (qt-radio-button-create "Option A")))
      (check (qt-radio-button-text r) => "Option A")
      (qt-radio-button-set-text! r "Option B")
      (check (qt-radio-button-text r) => "Option B")
      (qt-widget-destroy! r)))

  (test-case "radio button checked round-trip"
    (let ((r (qt-radio-button-create "Test")))
      (check (qt-radio-button-checked? r) => #f)
      (qt-radio-button-set-checked! r #t)
      (check (qt-radio-button-checked? r) => #t)
      (qt-widget-destroy! r)))

  (test-case "radio button signal registration"
    (let ((r (qt-radio-button-create "Test")))
      (qt-on-radio-toggled! r (lambda (checked) #t))
      (qt-widget-destroy! r)))

  (test-case "button group"
    (let ((bg (qt-button-group-create))
          (r1 (qt-radio-button-create "A"))
          (r2 (qt-radio-button-create "B")))
      (qt-button-group-add-button! bg r1 0)
      (qt-button-group-add-button! bg r2 1)
      (qt-button-group-set-exclusive! bg #t)
      (check (qt-button-group-exclusive? bg) => #t)
      (qt-on-button-group-clicked! bg (lambda (id) #t))
      (qt-button-group-destroy! bg)
      (qt-widget-destroy! r1)
      (qt-widget-destroy! r2)))

  (test-case "group box"
    (let ((gb (qt-group-box-create "Settings")))
      (check (qt-group-box-title gb) => "Settings")
      (qt-group-box-set-title! gb "Options")
      (check (qt-group-box-title gb) => "Options")
      (qt-group-box-set-checkable! gb #t)
      (check (qt-group-box-checkable? gb) => #t)
      (qt-group-box-set-checked! gb #f)
      (check (qt-group-box-checked? gb) => #f)
      (qt-on-group-box-toggled! gb (lambda (checked) #t))
      (qt-widget-destroy! gb))))

;; ==================== Phase 8: Font, Color ====================

(test-group "font and color"
  (test-case "font create and query"
    (let ((f (qt-font-create "Monospace" 12)))
      (check (string? (qt-font-family f)) ? values)
      (check (qt-font-point-size f) => 12)
      (qt-font-set-bold! f #t)
      (check (qt-font-bold? f) => #t)
      (qt-font-set-italic! f #t)
      (check (qt-font-italic? f) => #t)
      (qt-font-destroy! f)))

  (test-case "font set on widget"
    (let ((w (qt-widget-create))
          (f (qt-font-create "Sans" 14)))
      (qt-widget-set-font! w f)
      (qt-font-destroy! f)
      (qt-widget-destroy! w)))

  (test-case "color create and query"
    (let ((c (qt-color-create 255 128 0 255)))
      (check (qt-color-red c) => 255)
      (check (qt-color-green c) => 128)
      (check (qt-color-blue c) => 0)
      (check (qt-color-alpha c) => 255)
      (check (qt-color-valid? c) => #t)
      (qt-color-destroy! c)))

  (test-case "color create from name"
    (let ((c (qt-color-create-name "red")))
      (check (qt-color-valid? c) => #t)
      (check (qt-color-red c) => 255)
      (qt-color-destroy! c))))

;; ==================== Phase 8b: Scroll Area, Splitter, Progress, Slider ====================

(test-group "scroll area and splitter"
  (test-case "scroll area create"
    (let ((sa (qt-scroll-area-create))
          (content (qt-widget-create)))
      (qt-scroll-area-set-widget! sa content)
      (qt-scroll-area-set-widget-resizable! sa #t)
      (qt-scroll-area-set-horizontal-scrollbar-policy! sa QT_SCROLLBAR_ALWAYS_OFF)
      (qt-scroll-area-set-vertical-scrollbar-policy! sa QT_SCROLLBAR_AS_NEEDED)
      (qt-widget-destroy! sa)))

  (test-case "splitter create"
    (let ((sp (qt-splitter-create QT_HORIZONTAL))
          (w1 (qt-widget-create))
          (w2 (qt-widget-create)))
      (qt-splitter-add-widget! sp w1)
      (qt-splitter-add-widget! sp w2)
      (check (qt-splitter-count sp) => 2)
      (qt-splitter-set-handle-width! sp 5)
      (qt-widget-destroy! sp))))

(test-group "progress bar"
  (test-case "progress bar value round-trip"
    (let ((p (qt-progress-bar-create)))
      (qt-progress-bar-set-range! p 0 100)
      (qt-progress-bar-set-value! p 50)
      (check (qt-progress-bar-value p) => 50)
      (qt-progress-bar-set-format! p "%p%")
      (qt-widget-destroy! p))))

(test-group "slider"
  (test-case "slider value round-trip"
    (let ((s (qt-slider-create QT_HORIZONTAL)))
      (qt-slider-set-range! s 0 100)
      (qt-slider-set-value! s 75)
      (check (qt-slider-value s) => 75)
      (qt-slider-set-single-step! s 5)
      (qt-slider-set-tick-interval! s 10)
      (qt-slider-set-tick-position! s QT_TICKS_BELOW)
      (qt-widget-destroy! s)))

  (test-case "slider signal registration"
    (let ((s (qt-slider-create QT_HORIZONTAL)))
      (qt-on-slider-value-changed! s (lambda (val) #t))
      (qt-widget-destroy! s))))

;; ==================== Grid Layout ====================

(test-group "grid layout"
  (test-case "grid layout create and add widgets"
    (let* ((w (qt-widget-create))
           (grid (qt-grid-layout-create w))
           (l1 (qt-label-create "Name:"))
           (e1 (qt-line-edit-create)))
      (qt-grid-layout-add-widget! grid l1 0 0)
      (qt-grid-layout-add-widget! grid e1 0 1)
      (qt-grid-layout-set-row-stretch! grid 0 1)
      (qt-grid-layout-set-column-stretch! grid 1 2)
      (qt-widget-destroy! w))))

;; -----------------------------------------------------------------
;; Summary

(newline)
(let ([total (+ *pass* *fail*)])
  (printf "~a tests passed\n" *pass*)
  (when (> *fail* 0)
    (printf "~a tests FAILED\n" *fail*))
  (exit (if (zero? *fail*) 0 1)))
