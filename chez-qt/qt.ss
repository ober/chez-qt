;;; qt.ss — High-level idiomatic Chez Scheme API for Qt
;;;
;;; Provides API parity with gerbil-qt's qt.ss:
;;;   - Lifecycle: qt-app-create, qt-app-exec!, with-qt-app
;;;   - Widgets: labels, buttons, line edits, combos, etc.
;;;   - Signals: qt-on-clicked!, qt-on-text-changed!, etc.
;;;   - Layouts: vbox, hbox, grid
;;;   - Menus, actions, toolbars
;;;   - Dialogs, message boxes, file dialogs
;;;   - Tree, list, table, tab widgets
;;;   - Timer, clipboard, keyboard events
;;;   - Pixmap, icon, font, color
;;;   - Radio buttons, button groups, group boxes
;;;   - Scroll areas, splitters, progress bars, sliders

(library (chez-qt qt)
  (export
    ;; Lifecycle
    qt-app-create qt-app-exec! qt-app-quit!
    qt-app-process-events! qt-app-destroy!
    with-qt-app

    ;; Widget
    qt-widget-create qt-widget-show! qt-widget-hide! qt-widget-close!
    qt-widget-set-enabled! qt-widget-enabled?
    qt-widget-set-visible! qt-widget-visible?
    qt-widget-set-fixed-size! qt-widget-set-minimum-size!
    qt-widget-set-maximum-size!
    qt-widget-set-minimum-width! qt-widget-set-minimum-height!
    qt-widget-set-maximum-width! qt-widget-set-maximum-height!
    qt-widget-set-cursor! qt-widget-unset-cursor!
    qt-widget-resize! qt-widget-set-style-sheet!
    qt-widget-set-tooltip! qt-widget-set-font-size!
    qt-widget-destroy!

    ;; Main Window
    qt-main-window-create qt-main-window-set-title!
    qt-main-window-set-central-widget!

    ;; Layouts
    qt-vbox-layout-create qt-hbox-layout-create
    qt-layout-add-widget! qt-layout-add-stretch!
    qt-layout-set-spacing! qt-layout-set-margins!

    ;; Labels
    qt-label-create qt-label-set-text! qt-label-text
    qt-label-set-alignment! qt-label-set-word-wrap!

    ;; Push Button
    qt-push-button-create qt-push-button-set-text! qt-push-button-text
    qt-on-clicked!

    ;; Line Edit
    qt-line-edit-create qt-line-edit-text qt-line-edit-set-text!
    qt-line-edit-set-placeholder! qt-line-edit-set-read-only!
    qt-line-edit-set-echo-mode!
    qt-on-text-changed! qt-on-return-pressed!

    ;; Check Box
    qt-check-box-create qt-check-box-checked? qt-check-box-set-checked!
    qt-check-box-set-text! qt-on-toggled!

    ;; Combo Box
    qt-combo-box-create qt-combo-box-add-item! qt-combo-box-set-current-index!
    qt-combo-box-current-index qt-combo-box-current-text
    qt-combo-box-count qt-combo-box-clear!
    qt-on-index-changed!

    ;; Text Edit
    qt-text-edit-create qt-text-edit-text qt-text-edit-set-text!
    qt-text-edit-set-placeholder! qt-text-edit-set-read-only!
    qt-text-edit-append! qt-text-edit-clear!
    qt-text-edit-scroll-to-bottom! qt-text-edit-html
    qt-on-text-edit-changed!

    ;; Spin Box
    qt-spin-box-create qt-spin-box-value qt-spin-box-set-value!
    qt-spin-box-set-range! qt-spin-box-set-single-step!
    qt-spin-box-set-prefix! qt-spin-box-set-suffix!
    qt-on-value-changed!

    ;; Dialog
    qt-dialog-create qt-dialog-exec! qt-dialog-accept! qt-dialog-reject!
    qt-dialog-set-title!

    ;; Message Box
    qt-message-box-information qt-message-box-warning
    qt-message-box-question qt-message-box-critical

    ;; File Dialog
    qt-file-dialog-open-file qt-file-dialog-save-file
    qt-file-dialog-open-directory

    ;; Menu Bar
    qt-main-window-menu-bar

    ;; Menu
    qt-menu-bar-add-menu qt-menu-add-menu
    qt-menu-add-action! qt-menu-add-separator!

    ;; Action
    qt-action-create qt-action-text qt-action-set-text!
    qt-action-set-shortcut! qt-action-set-enabled! qt-action-enabled?
    qt-action-set-checkable! qt-action-checkable?
    qt-action-set-checked! qt-action-checked?
    qt-action-set-tooltip! qt-action-set-status-tip!
    qt-on-triggered! qt-on-action-toggled!

    ;; Toolbar
    qt-toolbar-create qt-main-window-add-toolbar!
    qt-toolbar-add-action! qt-toolbar-add-separator!
    qt-toolbar-add-widget! qt-toolbar-set-movable!
    qt-toolbar-set-icon-size!

    ;; Status Bar
    qt-main-window-set-status-bar-text!

    ;; Grid Layout
    qt-grid-layout-create qt-grid-layout-add-widget!
    qt-grid-layout-set-row-stretch! qt-grid-layout-set-column-stretch!
    qt-grid-layout-set-row-minimum-height!
    qt-grid-layout-set-column-minimum-width!

    ;; Timer
    qt-timer-create qt-timer-start! qt-timer-stop!
    qt-timer-set-single-shot! qt-timer-active?
    qt-timer-interval qt-timer-set-interval!
    qt-on-timeout! qt-timer-single-shot!
    qt-timer-destroy!

    ;; Clipboard
    qt-clipboard-text qt-clipboard-set-text! qt-on-clipboard-changed!

    ;; Tree Widget
    qt-tree-widget-create qt-tree-widget-set-column-count!
    qt-tree-widget-column-count qt-tree-widget-set-header-label!
    qt-tree-widget-set-header-item-text!
    qt-tree-widget-add-top-level-item! qt-tree-widget-top-level-item-count
    qt-tree-widget-top-level-item qt-tree-widget-current-item
    qt-tree-widget-set-current-item!
    qt-tree-widget-expand-item! qt-tree-widget-collapse-item!
    qt-tree-widget-expand-all! qt-tree-widget-collapse-all!
    qt-tree-widget-clear!
    qt-on-current-item-changed! qt-on-tree-item-double-clicked!
    qt-on-item-expanded! qt-on-item-collapsed!

    ;; Tree Widget Item
    qt-tree-item-create qt-tree-item-set-text! qt-tree-item-text
    qt-tree-item-add-child! qt-tree-item-child-count
    qt-tree-item-child qt-tree-item-parent
    qt-tree-item-set-expanded! qt-tree-item-expanded?

    ;; List Widget
    qt-list-widget-create qt-list-widget-add-item!
    qt-list-widget-insert-item! qt-list-widget-remove-item!
    qt-list-widget-current-row qt-list-widget-set-current-row!
    qt-list-widget-item-text qt-list-widget-count qt-list-widget-clear!
    qt-list-widget-set-item-data! qt-list-widget-item-data
    qt-on-current-row-changed! qt-on-item-double-clicked!

    ;; Table Widget
    qt-table-widget-create qt-table-widget-set-item!
    qt-table-widget-item-text
    qt-table-widget-set-horizontal-header! qt-table-widget-set-vertical-header!
    qt-table-widget-set-row-count! qt-table-widget-set-column-count!
    qt-table-widget-row-count qt-table-widget-column-count
    qt-table-widget-current-row qt-table-widget-current-column
    qt-table-widget-clear! qt-on-cell-clicked!

    ;; Tab Widget
    qt-tab-widget-create qt-tab-widget-add-tab!
    qt-tab-widget-set-current-index! qt-tab-widget-current-index
    qt-tab-widget-count qt-tab-widget-set-tab-text!
    qt-on-tab-changed!

    ;; Progress Bar
    qt-progress-bar-create qt-progress-bar-set-value!
    qt-progress-bar-value qt-progress-bar-set-range!
    qt-progress-bar-set-format!

    ;; Slider
    qt-slider-create qt-slider-set-value! qt-slider-value
    qt-slider-set-range! qt-slider-set-single-step!
    qt-slider-set-tick-interval! qt-slider-set-tick-position!
    qt-on-slider-value-changed!

    ;; Window State
    qt-widget-show-minimized! qt-widget-show-maximized!
    qt-widget-show-fullscreen! qt-widget-show-normal!
    qt-widget-window-state qt-widget-move!
    qt-widget-x qt-widget-y qt-widget-width qt-widget-height
    qt-widget-set-focus!

    ;; App-wide Style Sheet
    qt-app-set-style-sheet!

    ;; Scroll Area
    qt-scroll-area-create qt-scroll-area-set-widget!
    qt-scroll-area-set-widget-resizable!
    qt-scroll-area-set-horizontal-scrollbar-policy!
    qt-scroll-area-set-vertical-scrollbar-policy!

    ;; Splitter
    qt-splitter-create qt-splitter-add-widget! qt-splitter-insert-widget!
    qt-splitter-index-of qt-splitter-widget qt-splitter-count
    qt-splitter-set-sizes! qt-splitter-size-at
    qt-splitter-set-stretch-factor! qt-splitter-set-handle-width!
    qt-splitter-set-collapsible! qt-splitter-collapsible?
    qt-splitter-set-orientation!

    ;; Keyboard Events
    qt-on-key-press! qt-on-key-press-consuming!
    qt-last-key-code qt-last-key-modifiers qt-last-key-text

    ;; Pixmap
    qt-pixmap-load qt-pixmap-width qt-pixmap-height
    qt-pixmap-null? qt-pixmap-scaled qt-pixmap-destroy!
    qt-label-set-pixmap!

    ;; Icon
    qt-icon-create qt-icon-create-from-pixmap
    qt-icon-null? qt-icon-destroy!
    qt-push-button-set-icon! qt-action-set-icon!
    qt-widget-set-window-icon!

    ;; Radio Button
    qt-radio-button-create qt-radio-button-text qt-radio-button-set-text!
    qt-radio-button-checked? qt-radio-button-set-checked!
    qt-on-radio-toggled!

    ;; Button Group
    qt-button-group-create qt-button-group-add-button!
    qt-button-group-remove-button! qt-button-group-checked-id
    qt-button-group-set-exclusive! qt-button-group-exclusive?
    qt-on-button-group-clicked! qt-button-group-destroy!

    ;; Group Box
    qt-group-box-create qt-group-box-title qt-group-box-set-title!
    qt-group-box-set-checkable! qt-group-box-checkable?
    qt-group-box-set-checked! qt-group-box-checked?
    qt-on-group-box-toggled!

    ;; Font
    qt-font-create qt-font-family qt-font-point-size
    qt-font-bold? qt-font-set-bold! qt-font-italic? qt-font-set-italic!
    qt-font-destroy! qt-widget-set-font! qt-widget-font

    ;; Color
    qt-color-create qt-color-create-name
    qt-color-red qt-color-green qt-color-blue qt-color-alpha
    qt-color-name qt-color-valid? qt-color-destroy!

    ;; Callback management
    unregister-qt-handler! qt-disconnect-all!

    ;; Constants
    QT_ALIGN_LEFT QT_ALIGN_RIGHT QT_ALIGN_CENTER
    QT_ALIGN_TOP QT_ALIGN_BOTTOM
    QT_ECHO_NORMAL QT_ECHO_NO_ECHO QT_ECHO_PASSWORD QT_ECHO_PASSWORD_ON_EDIT
    QT_HORIZONTAL QT_VERTICAL
    QT_TICKS_NONE QT_TICKS_ABOVE QT_TICKS_BELOW QT_TICKS_BOTH_SIDES
    QT_WINDOW_NO_STATE QT_WINDOW_MINIMIZED QT_WINDOW_MAXIMIZED QT_WINDOW_FULL_SCREEN
    QT_SCROLLBAR_AS_NEEDED QT_SCROLLBAR_ALWAYS_OFF QT_SCROLLBAR_ALWAYS_ON
    QT_CURSOR_ARROW QT_CURSOR_CROSS QT_CURSOR_WAIT QT_CURSOR_IBEAM
    QT_CURSOR_POINTING_HAND QT_CURSOR_FORBIDDEN QT_CURSOR_BUSY)

  (import (chezscheme)
          (chez-qt ffi))

  ;; -----------------------------------------------------------------------
  ;; Constants (fetched from FFI at load time)
  ;; -----------------------------------------------------------------------

  (define QT_ALIGN_LEFT    ffi-qt-const-align-left)
  (define QT_ALIGN_RIGHT   ffi-qt-const-align-right)
  (define QT_ALIGN_CENTER  ffi-qt-const-align-center)
  (define QT_ALIGN_TOP     ffi-qt-const-align-top)
  (define QT_ALIGN_BOTTOM  ffi-qt-const-align-bottom)

  (define QT_ECHO_NORMAL          ffi-qt-const-echo-normal)
  (define QT_ECHO_NO_ECHO         ffi-qt-const-echo-no-echo)
  (define QT_ECHO_PASSWORD         ffi-qt-const-echo-password)
  (define QT_ECHO_PASSWORD_ON_EDIT ffi-qt-const-echo-password-on-edit)

  (define QT_HORIZONTAL ffi-qt-const-horizontal)
  (define QT_VERTICAL   ffi-qt-const-vertical)

  (define QT_TICKS_NONE       ffi-qt-const-ticks-none)
  (define QT_TICKS_ABOVE      ffi-qt-const-ticks-above)
  (define QT_TICKS_BELOW      ffi-qt-const-ticks-below)
  (define QT_TICKS_BOTH_SIDES ffi-qt-const-ticks-both-sides)

  (define QT_WINDOW_NO_STATE    ffi-qt-const-window-no-state)
  (define QT_WINDOW_MINIMIZED   ffi-qt-const-window-minimized)
  (define QT_WINDOW_MAXIMIZED   ffi-qt-const-window-maximized)
  (define QT_WINDOW_FULL_SCREEN ffi-qt-const-window-full-screen)

  (define QT_SCROLLBAR_AS_NEEDED  ffi-qt-const-scrollbar-as-needed)
  (define QT_SCROLLBAR_ALWAYS_OFF ffi-qt-const-scrollbar-always-off)
  (define QT_SCROLLBAR_ALWAYS_ON  ffi-qt-const-scrollbar-always-on)

  (define QT_CURSOR_ARROW         ffi-qt-const-cursor-arrow)
  (define QT_CURSOR_CROSS         ffi-qt-const-cursor-cross)
  (define QT_CURSOR_WAIT          ffi-qt-const-cursor-wait)
  (define QT_CURSOR_IBEAM         ffi-qt-const-cursor-ibeam)
  (define QT_CURSOR_POINTING_HAND ffi-qt-const-cursor-pointing-hand)
  (define QT_CURSOR_FORBIDDEN     ffi-qt-const-cursor-forbidden)
  (define QT_CURSOR_BUSY          ffi-qt-const-cursor-busy)

  ;; -----------------------------------------------------------------------
  ;; Callback dispatch tables
  ;; -----------------------------------------------------------------------

  (define *void-handlers*   (make-hashtable equal-hash equal?))
  (define *string-handlers* (make-hashtable equal-hash equal?))
  (define *int-handlers*    (make-hashtable equal-hash equal?))
  (define *bool-handlers*   (make-hashtable equal-hash equal?))
  (define *next-callback-id* 0)

  ;; Widget → list of callback IDs for cleanup
  (define *widget-handlers* (make-hashtable equal-hash equal?))

  (define (next-id!)
    (let ([id *next-callback-id*])
      (set! *next-callback-id* (+ id 1))
      id))

  (define (register-void-handler! handler)
    (let ([id (next-id!)])
      (hashtable-set! *void-handlers* id handler)
      id))

  (define (register-string-handler! handler)
    (let ([id (next-id!)])
      (hashtable-set! *string-handlers* id handler)
      id))

  (define (register-int-handler! handler)
    (let ([id (next-id!)])
      (hashtable-set! *int-handlers* id handler)
      id))

  (define (register-bool-handler! handler)
    (let ([id (next-id!)])
      (hashtable-set! *bool-handlers* id handler)
      id))

  (define (unregister-qt-handler! id)
    (hashtable-delete! *void-handlers* id)
    (hashtable-delete! *string-handlers* id)
    (hashtable-delete! *int-handlers* id)
    (hashtable-delete! *bool-handlers* id))

  (define (track-handler! obj id)
    (let ([ids (hashtable-ref *widget-handlers* obj '())])
      (hashtable-set! *widget-handlers* obj (cons id ids)))
    id)

  (define (qt-disconnect-all! obj)
    (let ([ids (hashtable-ref *widget-handlers* obj '())])
      (for-each unregister-qt-handler! ids)
      (hashtable-delete! *widget-handlers* obj)))

  ;; -----------------------------------------------------------------------
  ;; foreign-callable trampolines (Scheme functions callable from C)
  ;; Each is guarded with guard to prevent Scheme exceptions from
  ;; propagating through C++ frames.
  ;; -----------------------------------------------------------------------

  (define void-trampoline
    (foreign-callable
      (lambda (callback-id)
        (guard (e [#t (display-condition e (current-error-port))
                      (newline (current-error-port))])
          (let ([handler (hashtable-ref *void-handlers* callback-id #f)])
            (when handler (handler)))))
      (long)
      void))

  (define string-trampoline
    (foreign-callable
      (lambda (callback-id value)
        (guard (e [#t (display-condition e (current-error-port))
                      (newline (current-error-port))])
          (let ([handler (hashtable-ref *string-handlers* callback-id #f)])
            (when handler (handler value)))))
      (long string)
      void))

  (define int-trampoline
    (foreign-callable
      (lambda (callback-id value)
        (guard (e [#t (display-condition e (current-error-port))
                      (newline (current-error-port))])
          (let ([handler (hashtable-ref *int-handlers* callback-id #f)])
            (when handler (handler value)))))
      (long int)
      void))

  (define bool-trampoline
    (foreign-callable
      (lambda (callback-id value)
        (guard (e [#t (display-condition e (current-error-port))
                      (newline (current-error-port))])
          (let ([handler (hashtable-ref *bool-handlers* callback-id #f)])
            (when handler (handler (not (zero? value)))))))
      (long int)
      void))

  ;; Lock trampolines and register with C shim
  (define init-trampolines!
    (let ()
      (lock-object void-trampoline)
      (lock-object string-trampoline)
      (lock-object int-trampoline)
      (lock-object bool-trampoline)
      (ffi-set-void-callback (foreign-callable-entry-point void-trampoline))
      (ffi-set-string-callback (foreign-callable-entry-point string-trampoline))
      (ffi-set-int-callback (foreign-callable-entry-point int-trampoline))
      (ffi-set-bool-callback (foreign-callable-entry-point bool-trampoline))
      (void)))

  ;; -----------------------------------------------------------------------
  ;; Lifecycle
  ;; -----------------------------------------------------------------------

  (define (qt-app-create) (ffi-qt-app-create))
  (define (qt-app-exec! app) (ffi-qt-app-exec app))
  (define (qt-app-quit! app) (ffi-qt-app-quit app))
  (define (qt-app-process-events! app) (ffi-qt-app-process-events app))

  (define (qt-app-destroy! app)
    (qt-disconnect-all! app)
    (ffi-qt-app-destroy app))

  (define-syntax with-qt-app
    (syntax-rules ()
      [(_ app body ...)
       (let ([app (qt-app-create)])
         (dynamic-wind
           (lambda () #f)
           (lambda () body ...)
           (lambda () (qt-app-destroy! app))))]))

  ;; -----------------------------------------------------------------------
  ;; Widget
  ;; -----------------------------------------------------------------------

  (define qt-widget-create
    (case-lambda
      [() (ffi-qt-widget-create 0)]
      [(parent) (ffi-qt-widget-create (or parent 0))]))

  (define (qt-widget-show! w) (ffi-qt-widget-show w))
  (define (qt-widget-hide! w) (ffi-qt-widget-hide w))
  (define (qt-widget-close! w) (ffi-qt-widget-close w))

  (define (qt-widget-set-enabled! w enabled)
    (ffi-qt-widget-set-enabled w (if enabled 1 0)))
  (define (qt-widget-enabled? w)
    (not (zero? (ffi-qt-widget-is-enabled w))))

  (define (qt-widget-set-visible! w visible)
    (ffi-qt-widget-set-visible w (if visible 1 0)))
  (define (qt-widget-visible? w)
    (not (zero? (ffi-qt-widget-is-visible w))))

  (define (qt-widget-set-fixed-size! w width height)
    (ffi-qt-widget-set-fixed-size w width height))
  (define (qt-widget-set-minimum-size! w width height)
    (ffi-qt-widget-set-minimum-size w width height))
  (define (qt-widget-set-maximum-size! w width height)
    (ffi-qt-widget-set-maximum-size w width height))
  (define (qt-widget-set-minimum-width! w width)
    (ffi-qt-widget-set-minimum-width w width))
  (define (qt-widget-set-minimum-height! w height)
    (ffi-qt-widget-set-minimum-height w height))
  (define (qt-widget-set-maximum-width! w width)
    (ffi-qt-widget-set-maximum-width w width))
  (define (qt-widget-set-maximum-height! w height)
    (ffi-qt-widget-set-maximum-height w height))

  (define (qt-widget-set-cursor! w shape) (ffi-qt-widget-set-cursor w shape))
  (define (qt-widget-unset-cursor! w) (ffi-qt-widget-unset-cursor w))
  (define (qt-widget-resize! w width height) (ffi-qt-widget-resize w width height))
  (define (qt-widget-set-style-sheet! w css) (ffi-qt-widget-set-style-sheet w css))
  (define (qt-widget-set-tooltip! w text) (ffi-qt-widget-set-tooltip w text))
  (define (qt-widget-set-font-size! w size) (ffi-qt-widget-set-font-size w size))

  (define (qt-widget-destroy! w)
    (qt-disconnect-all! w)
    (ffi-qt-widget-destroy w))

  ;; Window state
  (define (qt-widget-show-minimized! w) (ffi-qt-widget-show-minimized w))
  (define (qt-widget-show-maximized! w) (ffi-qt-widget-show-maximized w))
  (define (qt-widget-show-fullscreen! w) (ffi-qt-widget-show-fullscreen w))
  (define (qt-widget-show-normal! w) (ffi-qt-widget-show-normal w))
  (define (qt-widget-window-state w) (ffi-qt-widget-window-state w))
  (define (qt-widget-move! w x y) (ffi-qt-widget-move w x y))
  (define (qt-widget-x w) (ffi-qt-widget-x w))
  (define (qt-widget-y w) (ffi-qt-widget-y w))
  (define (qt-widget-width w) (ffi-qt-widget-width w))
  (define (qt-widget-height w) (ffi-qt-widget-height w))
  (define (qt-widget-set-focus! w) (ffi-qt-widget-set-focus w))

  ;; -----------------------------------------------------------------------
  ;; Main Window
  ;; -----------------------------------------------------------------------

  (define qt-main-window-create
    (case-lambda
      [() (ffi-qt-main-window-create 0)]
      [(parent) (ffi-qt-main-window-create (or parent 0))]))

  (define (qt-main-window-set-title! w title) (ffi-qt-main-window-set-title w title))
  (define (qt-main-window-set-central-widget! w child)
    (ffi-qt-main-window-set-central-widget w child))
  (define (qt-main-window-menu-bar w) (ffi-qt-main-window-menu-bar w))
  (define (qt-main-window-add-toolbar! w tb) (ffi-qt-main-window-add-toolbar w tb))
  (define (qt-main-window-set-status-bar-text! w text)
    (ffi-qt-main-window-set-status-bar-text w text))

  ;; -----------------------------------------------------------------------
  ;; Layouts
  ;; -----------------------------------------------------------------------

  (define (qt-vbox-layout-create parent) (ffi-qt-vbox-layout-create parent))
  (define (qt-hbox-layout-create parent) (ffi-qt-hbox-layout-create parent))
  (define (qt-layout-add-widget! layout widget) (ffi-qt-layout-add-widget layout widget))

  (define qt-layout-add-stretch!
    (case-lambda
      [(layout) (ffi-qt-layout-add-stretch layout 1)]
      [(layout stretch) (ffi-qt-layout-add-stretch layout stretch)]))

  (define (qt-layout-set-spacing! layout spacing) (ffi-qt-layout-set-spacing layout spacing))
  (define (qt-layout-set-margins! layout left top right bottom)
    (ffi-qt-layout-set-margins layout left top right bottom))

  ;; Grid Layout
  (define (qt-grid-layout-create parent) (ffi-qt-grid-layout-create parent))
  (define qt-grid-layout-add-widget!
    (case-lambda
      [(layout widget row col)
       (ffi-qt-grid-layout-add-widget layout widget row col 1 1)]
      [(layout widget row col row-span col-span)
       (ffi-qt-grid-layout-add-widget layout widget row col row-span col-span)]))
  (define (qt-grid-layout-set-row-stretch! layout row stretch)
    (ffi-qt-grid-layout-set-row-stretch layout row stretch))
  (define (qt-grid-layout-set-column-stretch! layout col stretch)
    (ffi-qt-grid-layout-set-column-stretch layout col stretch))
  (define (qt-grid-layout-set-row-minimum-height! layout row height)
    (ffi-qt-grid-layout-set-row-minimum-height layout row height))
  (define (qt-grid-layout-set-column-minimum-width! layout col width)
    (ffi-qt-grid-layout-set-column-minimum-width layout col width))

  ;; -----------------------------------------------------------------------
  ;; Labels
  ;; -----------------------------------------------------------------------

  (define qt-label-create
    (case-lambda
      [(text) (ffi-qt-label-create text 0)]
      [(text parent) (ffi-qt-label-create text (or parent 0))]))

  (define (qt-label-set-text! l text) (ffi-qt-label-set-text l text))
  (define (qt-label-text l) (ffi-qt-label-text l))
  (define (qt-label-set-alignment! l alignment) (ffi-qt-label-set-alignment l alignment))
  (define (qt-label-set-word-wrap! l wrap)
    (ffi-qt-label-set-word-wrap l (if wrap 1 0)))
  (define (qt-label-set-pixmap! l pixmap) (ffi-qt-label-set-pixmap l pixmap))

  ;; -----------------------------------------------------------------------
  ;; Push Button
  ;; -----------------------------------------------------------------------

  (define qt-push-button-create
    (case-lambda
      [(text) (ffi-qt-push-button-create text 0)]
      [(text parent) (ffi-qt-push-button-create text (or parent 0))]))

  (define (qt-push-button-set-text! b text) (ffi-qt-push-button-set-text b text))
  (define (qt-push-button-text b) (ffi-qt-push-button-text b))
  (define (qt-push-button-set-icon! b icon) (ffi-qt-push-button-set-icon b icon))

  (define (qt-on-clicked! button handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-push-button-on-clicked button id)
      (track-handler! button id)))

  ;; -----------------------------------------------------------------------
  ;; Line Edit
  ;; -----------------------------------------------------------------------

  (define qt-line-edit-create
    (case-lambda
      [() (ffi-qt-line-edit-create 0)]
      [(parent) (ffi-qt-line-edit-create (or parent 0))]))

  (define (qt-line-edit-text e) (ffi-qt-line-edit-text e))
  (define (qt-line-edit-set-text! e text) (ffi-qt-line-edit-set-text e text))
  (define (qt-line-edit-set-placeholder! e text) (ffi-qt-line-edit-set-placeholder e text))
  (define (qt-line-edit-set-read-only! e ro)
    (ffi-qt-line-edit-set-read-only e (if ro 1 0)))
  (define (qt-line-edit-set-echo-mode! e mode) (ffi-qt-line-edit-set-echo-mode e mode))

  (define (qt-on-text-changed! e handler)
    (let ([id (register-string-handler! handler)])
      (ffi-qt-line-edit-on-text-changed e id)
      (track-handler! e id)))

  (define (qt-on-return-pressed! e handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-line-edit-on-return-pressed e id)
      (track-handler! e id)))

  ;; -----------------------------------------------------------------------
  ;; Check Box
  ;; -----------------------------------------------------------------------

  (define qt-check-box-create
    (case-lambda
      [(text) (ffi-qt-check-box-create text 0)]
      [(text parent) (ffi-qt-check-box-create text (or parent 0))]))

  (define (qt-check-box-set-text! c text) (ffi-qt-check-box-set-text c text))
  (define (qt-check-box-set-checked! c checked)
    (ffi-qt-check-box-set-checked c (if checked 1 0)))
  (define (qt-check-box-checked? c)
    (not (zero? (ffi-qt-check-box-is-checked c))))

  (define (qt-on-toggled! c handler)
    (let ([id (register-bool-handler! handler)])
      (ffi-qt-check-box-on-toggled c id)
      (track-handler! c id)))

  ;; -----------------------------------------------------------------------
  ;; Combo Box
  ;; -----------------------------------------------------------------------

  (define qt-combo-box-create
    (case-lambda
      [() (ffi-qt-combo-box-create 0)]
      [(parent) (ffi-qt-combo-box-create (or parent 0))]))

  (define (qt-combo-box-add-item! c text) (ffi-qt-combo-box-add-item c text))
  (define (qt-combo-box-set-current-index! c idx) (ffi-qt-combo-box-set-current-index c idx))
  (define (qt-combo-box-current-index c) (ffi-qt-combo-box-current-index c))
  (define (qt-combo-box-current-text c) (ffi-qt-combo-box-current-text c))
  (define (qt-combo-box-count c) (ffi-qt-combo-box-count c))
  (define (qt-combo-box-clear! c) (ffi-qt-combo-box-clear c))

  (define (qt-on-index-changed! c handler)
    (let ([id (register-int-handler! handler)])
      (ffi-qt-combo-box-on-current-index-changed c id)
      (track-handler! c id)))

  ;; -----------------------------------------------------------------------
  ;; Text Edit
  ;; -----------------------------------------------------------------------

  (define qt-text-edit-create
    (case-lambda
      [() (ffi-qt-text-edit-create 0)]
      [(parent) (ffi-qt-text-edit-create (or parent 0))]))

  (define (qt-text-edit-text e) (ffi-qt-text-edit-text e))
  (define (qt-text-edit-set-text! e text) (ffi-qt-text-edit-set-text e text))
  (define (qt-text-edit-set-placeholder! e text) (ffi-qt-text-edit-set-placeholder e text))
  (define (qt-text-edit-set-read-only! e ro)
    (ffi-qt-text-edit-set-read-only e (if ro 1 0)))
  (define (qt-text-edit-append! e text) (ffi-qt-text-edit-append e text))
  (define (qt-text-edit-clear! e) (ffi-qt-text-edit-clear e))
  (define (qt-text-edit-scroll-to-bottom! e) (ffi-qt-text-edit-scroll-to-bottom e))
  (define (qt-text-edit-html e) (ffi-qt-text-edit-html e))

  (define (qt-on-text-edit-changed! e handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-text-edit-on-text-changed e id)
      (track-handler! e id)))

  ;; -----------------------------------------------------------------------
  ;; Spin Box
  ;; -----------------------------------------------------------------------

  (define qt-spin-box-create
    (case-lambda
      [() (ffi-qt-spin-box-create 0)]
      [(parent) (ffi-qt-spin-box-create (or parent 0))]))

  (define (qt-spin-box-value s) (ffi-qt-spin-box-value s))
  (define (qt-spin-box-set-value! s val) (ffi-qt-spin-box-set-value s val))
  (define (qt-spin-box-set-range! s min max) (ffi-qt-spin-box-set-range s min max))
  (define (qt-spin-box-set-single-step! s step) (ffi-qt-spin-box-set-single-step s step))
  (define (qt-spin-box-set-prefix! s prefix) (ffi-qt-spin-box-set-prefix s prefix))
  (define (qt-spin-box-set-suffix! s suffix) (ffi-qt-spin-box-set-suffix s suffix))

  (define (qt-on-value-changed! s handler)
    (let ([id (register-int-handler! handler)])
      (ffi-qt-spin-box-on-value-changed s id)
      (track-handler! s id)))

  ;; -----------------------------------------------------------------------
  ;; Dialog
  ;; -----------------------------------------------------------------------

  (define qt-dialog-create
    (case-lambda
      [() (ffi-qt-dialog-create 0)]
      [(parent) (ffi-qt-dialog-create (or parent 0))]))

  (define (qt-dialog-exec! d) (ffi-qt-dialog-exec d))
  (define (qt-dialog-accept! d) (ffi-qt-dialog-accept d))
  (define (qt-dialog-reject! d) (ffi-qt-dialog-reject d))
  (define (qt-dialog-set-title! d title) (ffi-qt-dialog-set-title d title))

  ;; -----------------------------------------------------------------------
  ;; Message Box
  ;; -----------------------------------------------------------------------

  (define qt-message-box-information
    (case-lambda
      [(title text) (ffi-qt-message-box-information 0 title text)]
      [(parent title text) (ffi-qt-message-box-information (or parent 0) title text)]))

  (define qt-message-box-warning
    (case-lambda
      [(title text) (ffi-qt-message-box-warning 0 title text)]
      [(parent title text) (ffi-qt-message-box-warning (or parent 0) title text)]))

  (define qt-message-box-question
    (case-lambda
      [(title text) (ffi-qt-message-box-question 0 title text)]
      [(parent title text) (ffi-qt-message-box-question (or parent 0) title text)]))

  (define qt-message-box-critical
    (case-lambda
      [(title text) (ffi-qt-message-box-critical 0 title text)]
      [(parent title text) (ffi-qt-message-box-critical (or parent 0) title text)]))

  ;; -----------------------------------------------------------------------
  ;; File Dialog
  ;; -----------------------------------------------------------------------

  (define qt-file-dialog-open-file
    (case-lambda
      [(caption dir filter)
       (ffi-qt-file-dialog-open-file 0 caption dir filter)]
      [(parent caption dir filter)
       (ffi-qt-file-dialog-open-file (or parent 0) caption dir filter)]))

  (define qt-file-dialog-save-file
    (case-lambda
      [(caption dir filter)
       (ffi-qt-file-dialog-save-file 0 caption dir filter)]
      [(parent caption dir filter)
       (ffi-qt-file-dialog-save-file (or parent 0) caption dir filter)]))

  (define qt-file-dialog-open-directory
    (case-lambda
      [(caption dir) (ffi-qt-file-dialog-open-directory 0 caption dir)]
      [(parent caption dir)
       (ffi-qt-file-dialog-open-directory (or parent 0) caption dir)]))

  ;; -----------------------------------------------------------------------
  ;; Menu
  ;; -----------------------------------------------------------------------

  (define (qt-menu-bar-add-menu bar title) (ffi-qt-menu-bar-add-menu bar title))
  (define (qt-menu-add-menu menu title) (ffi-qt-menu-add-menu menu title))
  (define (qt-menu-add-action! menu action) (ffi-qt-menu-add-action menu action))
  (define (qt-menu-add-separator! menu) (ffi-qt-menu-add-separator menu))

  ;; -----------------------------------------------------------------------
  ;; Action
  ;; -----------------------------------------------------------------------

  (define qt-action-create
    (case-lambda
      [(text) (ffi-qt-action-create text 0)]
      [(text parent) (ffi-qt-action-create text (or parent 0))]))

  (define (qt-action-text a) (ffi-qt-action-text a))
  (define (qt-action-set-text! a text) (ffi-qt-action-set-text a text))
  (define (qt-action-set-shortcut! a shortcut) (ffi-qt-action-set-shortcut a shortcut))
  (define (qt-action-set-enabled! a enabled)
    (ffi-qt-action-set-enabled a (if enabled 1 0)))
  (define (qt-action-enabled? a) (not (zero? (ffi-qt-action-is-enabled a))))
  (define (qt-action-set-checkable! a checkable)
    (ffi-qt-action-set-checkable a (if checkable 1 0)))
  (define (qt-action-checkable? a) (not (zero? (ffi-qt-action-is-checkable a))))
  (define (qt-action-set-checked! a checked)
    (ffi-qt-action-set-checked a (if checked 1 0)))
  (define (qt-action-checked? a) (not (zero? (ffi-qt-action-is-checked a))))
  (define (qt-action-set-tooltip! a text) (ffi-qt-action-set-tooltip a text))
  (define (qt-action-set-status-tip! a text) (ffi-qt-action-set-status-tip a text))
  (define (qt-action-set-icon! a icon) (ffi-qt-action-set-icon a icon))

  (define (qt-on-triggered! a handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-action-on-triggered a id)
      (track-handler! a id)))

  (define (qt-on-action-toggled! a handler)
    (let ([id (register-bool-handler! handler)])
      (ffi-qt-action-on-toggled a id)
      (track-handler! a id)))

  ;; -----------------------------------------------------------------------
  ;; Toolbar
  ;; -----------------------------------------------------------------------

  (define qt-toolbar-create
    (case-lambda
      [(title) (ffi-qt-toolbar-create title 0)]
      [(title parent) (ffi-qt-toolbar-create title (or parent 0))]))

  (define (qt-toolbar-add-action! tb action) (ffi-qt-toolbar-add-action tb action))
  (define (qt-toolbar-add-separator! tb) (ffi-qt-toolbar-add-separator tb))
  (define (qt-toolbar-add-widget! tb w) (ffi-qt-toolbar-add-widget tb w))
  (define (qt-toolbar-set-movable! tb movable)
    (ffi-qt-toolbar-set-movable tb (if movable 1 0)))
  (define (qt-toolbar-set-icon-size! tb w h) (ffi-qt-toolbar-set-icon-size tb w h))

  ;; -----------------------------------------------------------------------
  ;; Timer
  ;; -----------------------------------------------------------------------

  (define (qt-timer-create) (ffi-qt-timer-create))
  (define (qt-timer-start! t msec) (ffi-qt-timer-start t msec))
  (define (qt-timer-stop! t) (ffi-qt-timer-stop t))
  (define (qt-timer-set-single-shot! t ss)
    (ffi-qt-timer-set-single-shot t (if ss 1 0)))
  (define (qt-timer-active? t) (not (zero? (ffi-qt-timer-is-active t))))
  (define (qt-timer-interval t) (ffi-qt-timer-interval t))
  (define (qt-timer-set-interval! t msec) (ffi-qt-timer-set-interval t msec))
  (define (qt-timer-destroy! t) (ffi-qt-timer-destroy t))

  (define (qt-on-timeout! t handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-timer-on-timeout t id)
      (track-handler! t id)))

  (define (qt-timer-single-shot! msec handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-timer-single-shot msec id)
      id))

  ;; -----------------------------------------------------------------------
  ;; Clipboard
  ;; -----------------------------------------------------------------------

  (define (qt-clipboard-text app) (ffi-qt-clipboard-text app))
  (define (qt-clipboard-set-text! app text) (ffi-qt-clipboard-set-text app text))
  (define (qt-on-clipboard-changed! app handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-clipboard-on-changed app id)
      (track-handler! app id)))

  ;; -----------------------------------------------------------------------
  ;; Tree Widget
  ;; -----------------------------------------------------------------------

  (define qt-tree-widget-create
    (case-lambda
      [() (ffi-qt-tree-widget-create 0)]
      [(parent) (ffi-qt-tree-widget-create (or parent 0))]))

  (define (qt-tree-widget-set-column-count! t n) (ffi-qt-tree-widget-set-column-count t n))
  (define (qt-tree-widget-column-count t) (ffi-qt-tree-widget-column-count t))
  (define (qt-tree-widget-set-header-label! t label)
    (ffi-qt-tree-widget-set-header-label t label))
  (define (qt-tree-widget-set-header-item-text! t col text)
    (ffi-qt-tree-widget-set-header-item-text t col text))
  (define (qt-tree-widget-add-top-level-item! t item)
    (ffi-qt-tree-widget-add-top-level-item t item))
  (define (qt-tree-widget-top-level-item-count t)
    (ffi-qt-tree-widget-top-level-item-count t))
  (define (qt-tree-widget-top-level-item t idx)
    (ffi-qt-tree-widget-top-level-item t idx))
  (define (qt-tree-widget-current-item t) (ffi-qt-tree-widget-current-item t))
  (define (qt-tree-widget-set-current-item! t item)
    (ffi-qt-tree-widget-set-current-item t item))
  (define (qt-tree-widget-expand-item! t item) (ffi-qt-tree-widget-expand-item t item))
  (define (qt-tree-widget-collapse-item! t item) (ffi-qt-tree-widget-collapse-item t item))
  (define (qt-tree-widget-expand-all! t) (ffi-qt-tree-widget-expand-all t))
  (define (qt-tree-widget-collapse-all! t) (ffi-qt-tree-widget-collapse-all t))
  (define (qt-tree-widget-clear! t) (ffi-qt-tree-widget-clear t))

  (define (qt-on-current-item-changed! t handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-tree-widget-on-current-item-changed t id)
      (track-handler! t id)))
  (define (qt-on-tree-item-double-clicked! t handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-tree-widget-on-item-double-clicked t id)
      (track-handler! t id)))
  (define (qt-on-item-expanded! t handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-tree-widget-on-item-expanded t id)
      (track-handler! t id)))
  (define (qt-on-item-collapsed! t handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-tree-widget-on-item-collapsed t id)
      (track-handler! t id)))

  ;; Tree Widget Item
  (define (qt-tree-item-create text) (ffi-qt-tree-item-create text))
  (define (qt-tree-item-set-text! item col text) (ffi-qt-tree-item-set-text item col text))
  (define (qt-tree-item-text item col) (ffi-qt-tree-item-text item col))
  (define (qt-tree-item-add-child! item child) (ffi-qt-tree-item-add-child item child))
  (define (qt-tree-item-child-count item) (ffi-qt-tree-item-child-count item))
  (define (qt-tree-item-child item idx) (ffi-qt-tree-item-child item idx))
  (define (qt-tree-item-parent item) (ffi-qt-tree-item-parent item))
  (define (qt-tree-item-set-expanded! item expanded)
    (ffi-qt-tree-item-set-expanded item (if expanded 1 0)))
  (define (qt-tree-item-expanded? item)
    (not (zero? (ffi-qt-tree-item-is-expanded item))))

  ;; -----------------------------------------------------------------------
  ;; List Widget
  ;; -----------------------------------------------------------------------

  (define qt-list-widget-create
    (case-lambda
      [() (ffi-qt-list-widget-create 0)]
      [(parent) (ffi-qt-list-widget-create (or parent 0))]))

  (define (qt-list-widget-add-item! l text) (ffi-qt-list-widget-add-item l text))
  (define (qt-list-widget-insert-item! l row text) (ffi-qt-list-widget-insert-item l row text))
  (define (qt-list-widget-remove-item! l row) (ffi-qt-list-widget-remove-item l row))
  (define (qt-list-widget-current-row l) (ffi-qt-list-widget-current-row l))
  (define (qt-list-widget-set-current-row! l row) (ffi-qt-list-widget-set-current-row l row))
  (define (qt-list-widget-item-text l row) (ffi-qt-list-widget-item-text l row))
  (define (qt-list-widget-count l) (ffi-qt-list-widget-count l))
  (define (qt-list-widget-clear! l) (ffi-qt-list-widget-clear l))
  (define (qt-list-widget-set-item-data! l row data)
    (ffi-qt-list-widget-set-item-data l row data))
  (define (qt-list-widget-item-data l row) (ffi-qt-list-widget-item-data l row))

  (define (qt-on-current-row-changed! l handler)
    (let ([id (register-int-handler! handler)])
      (ffi-qt-list-widget-on-current-row-changed l id)
      (track-handler! l id)))
  (define (qt-on-item-double-clicked! l handler)
    (let ([id (register-int-handler! handler)])
      (ffi-qt-list-widget-on-item-double-clicked l id)
      (track-handler! l id)))

  ;; -----------------------------------------------------------------------
  ;; Table Widget
  ;; -----------------------------------------------------------------------

  (define qt-table-widget-create
    (case-lambda
      [(rows cols) (ffi-qt-table-widget-create rows cols 0)]
      [(rows cols parent) (ffi-qt-table-widget-create rows cols (or parent 0))]))

  (define (qt-table-widget-set-item! t row col text)
    (ffi-qt-table-widget-set-item t row col text))
  (define (qt-table-widget-item-text t row col)
    (ffi-qt-table-widget-item-text t row col))
  (define (qt-table-widget-set-horizontal-header! t col text)
    (ffi-qt-table-widget-set-horizontal-header-item t col text))
  (define (qt-table-widget-set-vertical-header! t row text)
    (ffi-qt-table-widget-set-vertical-header-item t row text))
  (define (qt-table-widget-set-row-count! t n) (ffi-qt-table-widget-set-row-count t n))
  (define (qt-table-widget-set-column-count! t n) (ffi-qt-table-widget-set-column-count t n))
  (define (qt-table-widget-row-count t) (ffi-qt-table-widget-row-count t))
  (define (qt-table-widget-column-count t) (ffi-qt-table-widget-column-count t))
  (define (qt-table-widget-current-row t) (ffi-qt-table-widget-current-row t))
  (define (qt-table-widget-current-column t) (ffi-qt-table-widget-current-column t))
  (define (qt-table-widget-clear! t) (ffi-qt-table-widget-clear t))

  (define (qt-on-cell-clicked! t handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-table-widget-on-cell-clicked t id)
      (track-handler! t id)))

  ;; -----------------------------------------------------------------------
  ;; Tab Widget
  ;; -----------------------------------------------------------------------

  (define qt-tab-widget-create
    (case-lambda
      [() (ffi-qt-tab-widget-create 0)]
      [(parent) (ffi-qt-tab-widget-create (or parent 0))]))

  (define (qt-tab-widget-add-tab! tw widget label) (ffi-qt-tab-widget-add-tab tw widget label))
  (define (qt-tab-widget-set-current-index! tw idx) (ffi-qt-tab-widget-set-current-index tw idx))
  (define (qt-tab-widget-current-index tw) (ffi-qt-tab-widget-current-index tw))
  (define (qt-tab-widget-count tw) (ffi-qt-tab-widget-count tw))
  (define (qt-tab-widget-set-tab-text! tw idx text) (ffi-qt-tab-widget-set-tab-text tw idx text))

  (define (qt-on-tab-changed! tw handler)
    (let ([id (register-int-handler! handler)])
      (ffi-qt-tab-widget-on-current-changed tw id)
      (track-handler! tw id)))

  ;; -----------------------------------------------------------------------
  ;; Progress Bar
  ;; -----------------------------------------------------------------------

  (define qt-progress-bar-create
    (case-lambda
      [() (ffi-qt-progress-bar-create 0)]
      [(parent) (ffi-qt-progress-bar-create (or parent 0))]))

  (define (qt-progress-bar-set-value! p val) (ffi-qt-progress-bar-set-value p val))
  (define (qt-progress-bar-value p) (ffi-qt-progress-bar-value p))
  (define (qt-progress-bar-set-range! p min max) (ffi-qt-progress-bar-set-range p min max))
  (define (qt-progress-bar-set-format! p fmt) (ffi-qt-progress-bar-set-format p fmt))

  ;; -----------------------------------------------------------------------
  ;; Slider
  ;; -----------------------------------------------------------------------

  (define qt-slider-create
    (case-lambda
      [(orientation) (ffi-qt-slider-create orientation 0)]
      [(orientation parent) (ffi-qt-slider-create orientation (or parent 0))]))

  (define (qt-slider-set-value! s val) (ffi-qt-slider-set-value s val))
  (define (qt-slider-value s) (ffi-qt-slider-value s))
  (define (qt-slider-set-range! s min max) (ffi-qt-slider-set-range s min max))
  (define (qt-slider-set-single-step! s step) (ffi-qt-slider-set-single-step s step))
  (define (qt-slider-set-tick-interval! s interval) (ffi-qt-slider-set-tick-interval s interval))
  (define (qt-slider-set-tick-position! s pos) (ffi-qt-slider-set-tick-position s pos))

  (define (qt-on-slider-value-changed! s handler)
    (let ([id (register-int-handler! handler)])
      (ffi-qt-slider-on-value-changed s id)
      (track-handler! s id)))

  ;; -----------------------------------------------------------------------
  ;; App-wide Style Sheet
  ;; -----------------------------------------------------------------------

  (define (qt-app-set-style-sheet! app css) (ffi-qt-app-set-style-sheet app css))

  ;; -----------------------------------------------------------------------
  ;; Scroll Area
  ;; -----------------------------------------------------------------------

  (define qt-scroll-area-create
    (case-lambda
      [() (ffi-qt-scroll-area-create 0)]
      [(parent) (ffi-qt-scroll-area-create (or parent 0))]))

  (define (qt-scroll-area-set-widget! sa w) (ffi-qt-scroll-area-set-widget sa w))
  (define (qt-scroll-area-set-widget-resizable! sa resizable)
    (ffi-qt-scroll-area-set-widget-resizable sa (if resizable 1 0)))
  (define (qt-scroll-area-set-horizontal-scrollbar-policy! sa policy)
    (ffi-qt-scroll-area-set-horizontal-scrollbar-policy sa policy))
  (define (qt-scroll-area-set-vertical-scrollbar-policy! sa policy)
    (ffi-qt-scroll-area-set-vertical-scrollbar-policy sa policy))

  ;; -----------------------------------------------------------------------
  ;; Splitter
  ;; -----------------------------------------------------------------------

  (define qt-splitter-create
    (case-lambda
      [(orientation) (ffi-qt-splitter-create orientation 0)]
      [(orientation parent) (ffi-qt-splitter-create orientation (or parent 0))]))

  (define (qt-splitter-add-widget! s w) (ffi-qt-splitter-add-widget s w))
  (define (qt-splitter-insert-widget! s idx w) (ffi-qt-splitter-insert-widget s idx w))
  (define (qt-splitter-index-of s w) (ffi-qt-splitter-index-of s w))
  (define (qt-splitter-widget s idx) (ffi-qt-splitter-widget s idx))
  (define (qt-splitter-count s) (ffi-qt-splitter-count s))
  (define qt-splitter-set-sizes!
    (case-lambda
      [(s a b)     (ffi-qt-splitter-set-sizes-2 s a b)]
      [(s a b c)   (ffi-qt-splitter-set-sizes-3 s a b c)]))
  (define (qt-splitter-size-at s idx) (ffi-qt-splitter-size-at s idx))
  (define (qt-splitter-set-stretch-factor! s idx factor)
    (ffi-qt-splitter-set-stretch-factor s idx factor))
  (define (qt-splitter-set-handle-width! s w) (ffi-qt-splitter-set-handle-width s w))
  (define (qt-splitter-set-collapsible! s idx collapsible)
    (ffi-qt-splitter-set-collapsible s idx (if collapsible 1 0)))
  (define (qt-splitter-collapsible? s idx)
    (not (zero? (ffi-qt-splitter-is-collapsible s idx))))
  (define (qt-splitter-set-orientation! s orientation)
    (ffi-qt-splitter-set-orientation s orientation))

  ;; -----------------------------------------------------------------------
  ;; Keyboard Events
  ;; -----------------------------------------------------------------------

  (define (qt-on-key-press! w handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-install-key-handler w id)
      (track-handler! w id)))

  (define (qt-on-key-press-consuming! w handler)
    (let ([id (register-void-handler! handler)])
      (ffi-qt-install-key-handler-consuming w id)
      (track-handler! w id)))

  (define (qt-last-key-code) (ffi-qt-last-key-code))
  (define (qt-last-key-modifiers) (ffi-qt-last-key-modifiers))
  (define (qt-last-key-text) (ffi-qt-last-key-text))

  ;; -----------------------------------------------------------------------
  ;; Pixmap
  ;; -----------------------------------------------------------------------

  (define (qt-pixmap-load path) (ffi-qt-pixmap-load path))
  (define (qt-pixmap-width p) (ffi-qt-pixmap-width p))
  (define (qt-pixmap-height p) (ffi-qt-pixmap-height p))
  (define (qt-pixmap-null? p) (not (zero? (ffi-qt-pixmap-is-null p))))
  (define (qt-pixmap-scaled p w h mode) (ffi-qt-pixmap-scaled p w h mode))
  (define (qt-pixmap-destroy! p) (ffi-qt-pixmap-destroy p))

  ;; -----------------------------------------------------------------------
  ;; Icon
  ;; -----------------------------------------------------------------------

  (define (qt-icon-create path) (ffi-qt-icon-create path))
  (define (qt-icon-create-from-pixmap p) (ffi-qt-icon-create-from-pixmap p))
  (define (qt-icon-null? i) (not (zero? (ffi-qt-icon-is-null i))))
  (define (qt-icon-destroy! i) (ffi-qt-icon-destroy i))
  (define (qt-widget-set-window-icon! w i) (ffi-qt-widget-set-window-icon w i))

  ;; -----------------------------------------------------------------------
  ;; Radio Button
  ;; -----------------------------------------------------------------------

  (define qt-radio-button-create
    (case-lambda
      [(text) (ffi-qt-radio-button-create text 0)]
      [(text parent) (ffi-qt-radio-button-create text (or parent 0))]))

  (define (qt-radio-button-text r) (ffi-qt-radio-button-text r))
  (define (qt-radio-button-set-text! r text) (ffi-qt-radio-button-set-text r text))
  (define (qt-radio-button-checked? r) (not (zero? (ffi-qt-radio-button-is-checked r))))
  (define (qt-radio-button-set-checked! r checked)
    (ffi-qt-radio-button-set-checked r (if checked 1 0)))

  (define (qt-on-radio-toggled! r handler)
    (let ([id (register-bool-handler! handler)])
      (ffi-qt-radio-button-on-toggled r id)
      (track-handler! r id)))

  ;; -----------------------------------------------------------------------
  ;; Button Group
  ;; -----------------------------------------------------------------------

  (define qt-button-group-create
    (case-lambda
      [() (ffi-qt-button-group-create 0)]
      [(parent) (ffi-qt-button-group-create (or parent 0))]))

  (define (qt-button-group-add-button! g button id)
    (ffi-qt-button-group-add-button g button id))
  (define (qt-button-group-remove-button! g button)
    (ffi-qt-button-group-remove-button g button))
  (define (qt-button-group-checked-id g) (ffi-qt-button-group-checked-id g))
  (define (qt-button-group-set-exclusive! g exclusive)
    (ffi-qt-button-group-set-exclusive g (if exclusive 1 0)))
  (define (qt-button-group-exclusive? g)
    (not (zero? (ffi-qt-button-group-is-exclusive g))))
  (define (qt-button-group-destroy! g) (ffi-qt-button-group-destroy g))

  (define (qt-on-button-group-clicked! g handler)
    (let ([id (register-int-handler! handler)])
      (ffi-qt-button-group-on-clicked g id)
      (track-handler! g id)))

  ;; -----------------------------------------------------------------------
  ;; Group Box
  ;; -----------------------------------------------------------------------

  (define qt-group-box-create
    (case-lambda
      [(title) (ffi-qt-group-box-create title 0)]
      [(title parent) (ffi-qt-group-box-create title (or parent 0))]))

  (define (qt-group-box-title g) (ffi-qt-group-box-title g))
  (define (qt-group-box-set-title! g title) (ffi-qt-group-box-set-title g title))
  (define (qt-group-box-set-checkable! g checkable)
    (ffi-qt-group-box-set-checkable g (if checkable 1 0)))
  (define (qt-group-box-checkable? g) (not (zero? (ffi-qt-group-box-is-checkable g))))
  (define (qt-group-box-set-checked! g checked)
    (ffi-qt-group-box-set-checked g (if checked 1 0)))
  (define (qt-group-box-checked? g) (not (zero? (ffi-qt-group-box-is-checked g))))

  (define (qt-on-group-box-toggled! g handler)
    (let ([id (register-bool-handler! handler)])
      (ffi-qt-group-box-on-toggled g id)
      (track-handler! g id)))

  ;; -----------------------------------------------------------------------
  ;; Font
  ;; -----------------------------------------------------------------------

  (define (qt-font-create family size) (ffi-qt-font-create family size))
  (define (qt-font-family f) (ffi-qt-font-family f))
  (define (qt-font-point-size f) (ffi-qt-font-point-size f))
  (define (qt-font-bold? f) (not (zero? (ffi-qt-font-is-bold f))))
  (define (qt-font-set-bold! f bold) (ffi-qt-font-set-bold f (if bold 1 0)))
  (define (qt-font-italic? f) (not (zero? (ffi-qt-font-is-italic f))))
  (define (qt-font-set-italic! f italic) (ffi-qt-font-set-italic f (if italic 1 0)))
  (define (qt-font-destroy! f) (ffi-qt-font-destroy f))
  (define (qt-widget-set-font! w f) (ffi-qt-widget-set-font w f))
  (define (qt-widget-font w) (ffi-qt-widget-font w))

  ;; -----------------------------------------------------------------------
  ;; Color
  ;; -----------------------------------------------------------------------

  (define qt-color-create
    (case-lambda
      [(r g b) (ffi-qt-color-create r g b 255)]
      [(r g b a) (ffi-qt-color-create r g b a)]))

  (define (qt-color-create-name name) (ffi-qt-color-create-name name))
  (define (qt-color-red c) (ffi-qt-color-red c))
  (define (qt-color-green c) (ffi-qt-color-green c))
  (define (qt-color-blue c) (ffi-qt-color-blue c))
  (define (qt-color-alpha c) (ffi-qt-color-alpha c))
  (define (qt-color-name c) (ffi-qt-color-name c))
  (define (qt-color-valid? c) (not (zero? (ffi-qt-color-is-valid c))))
  (define (qt-color-destroy! c) (ffi-qt-color-destroy c))

) ;; end library
