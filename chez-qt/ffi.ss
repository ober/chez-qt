;;; ffi.ss — Low-level FFI bindings to Qt via qt_shim + qt_chez_shim
;;;
;;; Loads shared libraries and defines foreign-procedure bindings.
;;; The high-level API lives in qt.ss.

(library (chez-qt ffi)
  (export
    ;; Callback registration (called once at init)
    ffi-set-void-callback ffi-set-string-callback
    ffi-set-int-callback ffi-set-bool-callback

    ;; Application lifecycle
    ffi-qt-app-create ffi-qt-app-exec ffi-qt-app-quit
    ffi-qt-app-process-events ffi-qt-app-destroy

    ;; Widget base
    ffi-qt-widget-create ffi-qt-widget-show ffi-qt-widget-hide
    ffi-qt-widget-close ffi-qt-widget-set-enabled ffi-qt-widget-is-enabled
    ffi-qt-widget-set-visible ffi-qt-widget-is-visible
    ffi-qt-widget-set-fixed-size ffi-qt-widget-set-minimum-size
    ffi-qt-widget-set-maximum-size
    ffi-qt-widget-set-minimum-width ffi-qt-widget-set-minimum-height
    ffi-qt-widget-set-maximum-width ffi-qt-widget-set-maximum-height
    ffi-qt-widget-set-cursor ffi-qt-widget-unset-cursor
    ffi-qt-widget-resize ffi-qt-widget-set-style-sheet
    ffi-qt-widget-set-tooltip ffi-qt-widget-set-font-size
    ffi-qt-widget-destroy

    ;; Main Window
    ffi-qt-main-window-create ffi-qt-main-window-set-title
    ffi-qt-main-window-set-central-widget

    ;; Layouts
    ffi-qt-vbox-layout-create ffi-qt-hbox-layout-create
    ffi-qt-layout-add-widget ffi-qt-layout-add-stretch
    ffi-qt-layout-set-spacing ffi-qt-layout-set-margins

    ;; Labels
    ffi-qt-label-create ffi-qt-label-set-text ffi-qt-label-text
    ffi-qt-label-set-alignment ffi-qt-label-set-word-wrap

    ;; Push Button
    ffi-qt-push-button-create ffi-qt-push-button-set-text
    ffi-qt-push-button-text ffi-qt-push-button-on-clicked

    ;; Line Edit
    ffi-qt-line-edit-create ffi-qt-line-edit-set-text ffi-qt-line-edit-text
    ffi-qt-line-edit-set-placeholder ffi-qt-line-edit-set-read-only
    ffi-qt-line-edit-set-echo-mode
    ffi-qt-line-edit-on-text-changed ffi-qt-line-edit-on-return-pressed

    ;; Check Box
    ffi-qt-check-box-create ffi-qt-check-box-set-text
    ffi-qt-check-box-set-checked ffi-qt-check-box-is-checked
    ffi-qt-check-box-on-toggled

    ;; Combo Box
    ffi-qt-combo-box-create ffi-qt-combo-box-add-item
    ffi-qt-combo-box-set-current-index ffi-qt-combo-box-current-index
    ffi-qt-combo-box-current-text ffi-qt-combo-box-count
    ffi-qt-combo-box-clear ffi-qt-combo-box-on-current-index-changed

    ;; Text Edit
    ffi-qt-text-edit-create ffi-qt-text-edit-set-text ffi-qt-text-edit-text
    ffi-qt-text-edit-set-placeholder ffi-qt-text-edit-set-read-only
    ffi-qt-text-edit-append ffi-qt-text-edit-clear
    ffi-qt-text-edit-scroll-to-bottom ffi-qt-text-edit-html
    ffi-qt-text-edit-on-text-changed

    ;; Spin Box
    ffi-qt-spin-box-create ffi-qt-spin-box-set-value ffi-qt-spin-box-value
    ffi-qt-spin-box-set-range ffi-qt-spin-box-set-single-step
    ffi-qt-spin-box-set-prefix ffi-qt-spin-box-set-suffix
    ffi-qt-spin-box-on-value-changed

    ;; Dialog
    ffi-qt-dialog-create ffi-qt-dialog-exec ffi-qt-dialog-accept
    ffi-qt-dialog-reject ffi-qt-dialog-set-title

    ;; Message Box
    ffi-qt-message-box-information ffi-qt-message-box-warning
    ffi-qt-message-box-question ffi-qt-message-box-critical

    ;; File Dialog
    ffi-qt-file-dialog-open-file ffi-qt-file-dialog-save-file
    ffi-qt-file-dialog-open-directory

    ;; Menu Bar
    ffi-qt-main-window-menu-bar

    ;; Menu
    ffi-qt-menu-bar-add-menu ffi-qt-menu-add-menu
    ffi-qt-menu-add-action ffi-qt-menu-add-separator

    ;; Action
    ffi-qt-action-create ffi-qt-action-set-text ffi-qt-action-text
    ffi-qt-action-set-shortcut ffi-qt-action-set-enabled ffi-qt-action-is-enabled
    ffi-qt-action-set-checkable ffi-qt-action-is-checkable
    ffi-qt-action-set-checked ffi-qt-action-is-checked
    ffi-qt-action-set-tooltip ffi-qt-action-set-status-tip
    ffi-qt-action-on-triggered ffi-qt-action-on-toggled

    ;; Toolbar
    ffi-qt-toolbar-create ffi-qt-main-window-add-toolbar
    ffi-qt-toolbar-add-action ffi-qt-toolbar-add-separator
    ffi-qt-toolbar-add-widget ffi-qt-toolbar-set-movable
    ffi-qt-toolbar-set-icon-size

    ;; Status Bar
    ffi-qt-main-window-set-status-bar-text

    ;; Grid Layout
    ffi-qt-grid-layout-create ffi-qt-grid-layout-add-widget
    ffi-qt-grid-layout-set-row-stretch ffi-qt-grid-layout-set-column-stretch
    ffi-qt-grid-layout-set-row-minimum-height
    ffi-qt-grid-layout-set-column-minimum-width

    ;; Timer
    ffi-qt-timer-create ffi-qt-timer-start ffi-qt-timer-stop
    ffi-qt-timer-set-single-shot ffi-qt-timer-is-active
    ffi-qt-timer-interval ffi-qt-timer-set-interval
    ffi-qt-timer-on-timeout ffi-qt-timer-single-shot
    ffi-qt-timer-destroy

    ;; Clipboard
    ffi-qt-clipboard-text ffi-qt-clipboard-set-text
    ffi-qt-clipboard-on-changed

    ;; Tree Widget
    ffi-qt-tree-widget-create ffi-qt-tree-widget-set-column-count
    ffi-qt-tree-widget-column-count ffi-qt-tree-widget-set-header-label
    ffi-qt-tree-widget-set-header-item-text
    ffi-qt-tree-widget-add-top-level-item ffi-qt-tree-widget-top-level-item-count
    ffi-qt-tree-widget-top-level-item ffi-qt-tree-widget-current-item
    ffi-qt-tree-widget-set-current-item
    ffi-qt-tree-widget-expand-item ffi-qt-tree-widget-collapse-item
    ffi-qt-tree-widget-expand-all ffi-qt-tree-widget-collapse-all
    ffi-qt-tree-widget-clear
    ffi-qt-tree-widget-on-current-item-changed
    ffi-qt-tree-widget-on-item-double-clicked
    ffi-qt-tree-widget-on-item-expanded ffi-qt-tree-widget-on-item-collapsed

    ;; Tree Widget Item
    ffi-qt-tree-item-create ffi-qt-tree-item-set-text ffi-qt-tree-item-text
    ffi-qt-tree-item-add-child ffi-qt-tree-item-child-count
    ffi-qt-tree-item-child ffi-qt-tree-item-parent
    ffi-qt-tree-item-set-expanded ffi-qt-tree-item-is-expanded

    ;; List Widget
    ffi-qt-list-widget-create ffi-qt-list-widget-add-item
    ffi-qt-list-widget-insert-item ffi-qt-list-widget-remove-item
    ffi-qt-list-widget-current-row ffi-qt-list-widget-set-current-row
    ffi-qt-list-widget-item-text ffi-qt-list-widget-count
    ffi-qt-list-widget-clear
    ffi-qt-list-widget-set-item-data ffi-qt-list-widget-item-data
    ffi-qt-list-widget-on-current-row-changed
    ffi-qt-list-widget-on-item-double-clicked

    ;; Table Widget
    ffi-qt-table-widget-create ffi-qt-table-widget-set-item
    ffi-qt-table-widget-item-text
    ffi-qt-table-widget-set-horizontal-header-item
    ffi-qt-table-widget-set-vertical-header-item
    ffi-qt-table-widget-set-row-count ffi-qt-table-widget-set-column-count
    ffi-qt-table-widget-row-count ffi-qt-table-widget-column-count
    ffi-qt-table-widget-current-row ffi-qt-table-widget-current-column
    ffi-qt-table-widget-clear ffi-qt-table-widget-on-cell-clicked

    ;; Tab Widget
    ffi-qt-tab-widget-create ffi-qt-tab-widget-add-tab
    ffi-qt-tab-widget-set-current-index ffi-qt-tab-widget-current-index
    ffi-qt-tab-widget-count ffi-qt-tab-widget-set-tab-text
    ffi-qt-tab-widget-on-current-changed

    ;; Progress Bar
    ffi-qt-progress-bar-create ffi-qt-progress-bar-set-value
    ffi-qt-progress-bar-value ffi-qt-progress-bar-set-range
    ffi-qt-progress-bar-set-format

    ;; Slider
    ffi-qt-slider-create ffi-qt-slider-set-value ffi-qt-slider-value
    ffi-qt-slider-set-range ffi-qt-slider-set-single-step
    ffi-qt-slider-set-tick-interval ffi-qt-slider-set-tick-position
    ffi-qt-slider-on-value-changed

    ;; Window State
    ffi-qt-widget-show-minimized ffi-qt-widget-show-maximized
    ffi-qt-widget-show-fullscreen ffi-qt-widget-show-normal
    ffi-qt-widget-window-state ffi-qt-widget-move
    ffi-qt-widget-x ffi-qt-widget-y ffi-qt-widget-width ffi-qt-widget-height
    ffi-qt-widget-set-focus

    ;; App Style Sheet
    ffi-qt-app-set-style-sheet

    ;; Scroll Area
    ffi-qt-scroll-area-create ffi-qt-scroll-area-set-widget
    ffi-qt-scroll-area-set-widget-resizable
    ffi-qt-scroll-area-set-horizontal-scrollbar-policy
    ffi-qt-scroll-area-set-vertical-scrollbar-policy

    ;; Splitter
    ffi-qt-splitter-create ffi-qt-splitter-add-widget
    ffi-qt-splitter-insert-widget ffi-qt-splitter-index-of
    ffi-qt-splitter-widget ffi-qt-splitter-count
    ffi-qt-splitter-set-sizes-2 ffi-qt-splitter-set-sizes-3 ffi-qt-splitter-size-at
    ffi-qt-splitter-set-stretch-factor ffi-qt-splitter-set-handle-width
    ffi-qt-splitter-set-collapsible ffi-qt-splitter-is-collapsible
    ffi-qt-splitter-set-orientation

    ;; Keyboard Events
    ffi-qt-install-key-handler ffi-qt-install-key-handler-consuming
    ffi-qt-last-key-code ffi-qt-last-key-modifiers ffi-qt-last-key-text

    ;; Pixmap
    ffi-qt-pixmap-load ffi-qt-pixmap-width ffi-qt-pixmap-height
    ffi-qt-pixmap-is-null ffi-qt-pixmap-scaled ffi-qt-pixmap-destroy
    ffi-qt-label-set-pixmap

    ;; Icon
    ffi-qt-icon-create ffi-qt-icon-create-from-pixmap
    ffi-qt-icon-is-null ffi-qt-icon-destroy
    ffi-qt-push-button-set-icon ffi-qt-action-set-icon
    ffi-qt-widget-set-window-icon

    ;; Radio Button
    ffi-qt-radio-button-create ffi-qt-radio-button-text
    ffi-qt-radio-button-set-text
    ffi-qt-radio-button-is-checked ffi-qt-radio-button-set-checked
    ffi-qt-radio-button-on-toggled

    ;; Button Group
    ffi-qt-button-group-create ffi-qt-button-group-add-button
    ffi-qt-button-group-remove-button ffi-qt-button-group-checked-id
    ffi-qt-button-group-set-exclusive ffi-qt-button-group-is-exclusive
    ffi-qt-button-group-on-clicked ffi-qt-button-group-destroy

    ;; Group Box
    ffi-qt-group-box-create ffi-qt-group-box-title
    ffi-qt-group-box-set-title
    ffi-qt-group-box-set-checkable ffi-qt-group-box-is-checkable
    ffi-qt-group-box-set-checked ffi-qt-group-box-is-checked
    ffi-qt-group-box-on-toggled

    ;; Font
    ffi-qt-font-create ffi-qt-font-family ffi-qt-font-point-size
    ffi-qt-font-is-bold ffi-qt-font-set-bold
    ffi-qt-font-is-italic ffi-qt-font-set-italic
    ffi-qt-font-destroy ffi-qt-widget-set-font ffi-qt-widget-font

    ;; Color
    ffi-qt-color-create ffi-qt-color-create-name
    ffi-qt-color-red ffi-qt-color-green ffi-qt-color-blue ffi-qt-color-alpha
    ffi-qt-color-name ffi-qt-color-is-valid ffi-qt-color-destroy

    ;; Constants
    ffi-qt-const-align-left ffi-qt-const-align-right ffi-qt-const-align-center
    ffi-qt-const-align-top ffi-qt-const-align-bottom
    ffi-qt-const-echo-normal ffi-qt-const-echo-no-echo
    ffi-qt-const-echo-password ffi-qt-const-echo-password-on-edit
    ffi-qt-const-horizontal ffi-qt-const-vertical
    ffi-qt-const-ticks-none ffi-qt-const-ticks-above
    ffi-qt-const-ticks-below ffi-qt-const-ticks-both-sides
    ffi-qt-const-window-no-state ffi-qt-const-window-minimized
    ffi-qt-const-window-maximized ffi-qt-const-window-full-screen
    ffi-qt-const-scrollbar-as-needed ffi-qt-const-scrollbar-always-off
    ffi-qt-const-scrollbar-always-on
    ffi-qt-const-cursor-arrow ffi-qt-const-cursor-cross
    ffi-qt-const-cursor-wait ffi-qt-const-cursor-ibeam
    ffi-qt-const-cursor-pointing-hand ffi-qt-const-cursor-forbidden
    ffi-qt-const-cursor-busy)

  (import (chezscheme))

  ;; -----------------------------------------------------------------------
  ;; Load shared libraries
  ;; -----------------------------------------------------------------------

  (define shim-dir
    (or (getenv "CHEZ_QT_LIB")
        (let ([script-dir (getenv "CHEZ_QT_SCRIPT_DIR")])
          (and script-dir script-dir))
        "."))

  ;; libqt_shim.so comes from gerbil-qt's vendor/ dir — use LD_LIBRARY_PATH or explicit env var
  (define qt-shim-loaded
    (load-shared-object
      (let ([qt-shim-dir (getenv "CHEZ_QT_SHIM_DIR")])
        (if qt-shim-dir
            (format "~a/libqt_shim.so" qt-shim-dir)
            "libqt_shim.so"))))

  (define chez-shim-loaded
    (load-shared-object
      (format "~a/qt_chez_shim.so" shim-dir)))

  ;; -----------------------------------------------------------------------
  ;; Callback registration (Chez → C shim)
  ;; -----------------------------------------------------------------------

  (define ffi-set-void-callback
    (foreign-procedure "chez_qt_set_void_callback" (void*) void))

  (define ffi-set-string-callback
    (foreign-procedure "chez_qt_set_string_callback" (void*) void))

  (define ffi-set-int-callback
    (foreign-procedure "chez_qt_set_int_callback" (void*) void))

  (define ffi-set-bool-callback
    (foreign-procedure "chez_qt_set_bool_callback" (void*) void))

  ;; -----------------------------------------------------------------------
  ;; Constants — hardcoded from Qt header values
  ;; -----------------------------------------------------------------------

  ;; Alignment (Qt::AlignmentFlag)
  (define ffi-qt-const-align-left    #x0001)
  (define ffi-qt-const-align-right   #x0002)
  (define ffi-qt-const-align-center  #x0084)
  (define ffi-qt-const-align-top     #x0020)
  (define ffi-qt-const-align-bottom  #x0040)

  ;; Echo mode (QLineEdit::EchoMode)
  (define ffi-qt-const-echo-normal          0)
  (define ffi-qt-const-echo-no-echo         1)
  (define ffi-qt-const-echo-password        2)
  (define ffi-qt-const-echo-password-on-edit 3)

  ;; Orientation (Qt::Orientation)
  (define ffi-qt-const-horizontal  #x1)
  (define ffi-qt-const-vertical    #x2)

  ;; Slider tick position (QSlider::TickPosition)
  (define ffi-qt-const-ticks-none        0)
  (define ffi-qt-const-ticks-above       1)
  (define ffi-qt-const-ticks-below       2)
  (define ffi-qt-const-ticks-both-sides  3)

  ;; Window state (Qt::WindowState)
  (define ffi-qt-const-window-no-state    #x00)
  (define ffi-qt-const-window-minimized   #x01)
  (define ffi-qt-const-window-maximized   #x02)
  (define ffi-qt-const-window-full-screen #x04)

  ;; Scrollbar policy (Qt::ScrollBarPolicy)
  (define ffi-qt-const-scrollbar-as-needed  0)
  (define ffi-qt-const-scrollbar-always-off 1)
  (define ffi-qt-const-scrollbar-always-on  2)

  ;; Cursor shape (Qt::CursorShape)
  (define ffi-qt-const-cursor-arrow          0)
  (define ffi-qt-const-cursor-cross          2)
  (define ffi-qt-const-cursor-wait           3)
  (define ffi-qt-const-cursor-ibeam          4)
  (define ffi-qt-const-cursor-pointing-hand 13)
  (define ffi-qt-const-cursor-forbidden     14)
  (define ffi-qt-const-cursor-busy          16)

  ;; -----------------------------------------------------------------------
  ;; Application lifecycle
  ;; -----------------------------------------------------------------------

  (define ffi-qt-app-create
    (foreign-procedure "chez_qt_application_create" () void*))

  (define ffi-qt-app-exec
    (foreign-procedure "qt_application_exec" (void*) int))

  (define ffi-qt-app-quit
    (foreign-procedure "qt_application_quit" (void*) void))

  (define ffi-qt-app-process-events
    (foreign-procedure "qt_application_process_events" (void*) void))

  (define ffi-qt-app-destroy
    (foreign-procedure "qt_application_destroy" (void*) void))

  (define ffi-qt-app-set-style-sheet
    (foreign-procedure "qt_application_set_style_sheet" (void* string) void))

  ;; -----------------------------------------------------------------------
  ;; Widget base
  ;; -----------------------------------------------------------------------

  (define ffi-qt-widget-create
    (foreign-procedure "qt_widget_create" (void*) void*))

  (define ffi-qt-widget-show
    (foreign-procedure "qt_widget_show" (void*) void))

  (define ffi-qt-widget-hide
    (foreign-procedure "qt_widget_hide" (void*) void))

  (define ffi-qt-widget-close
    (foreign-procedure "qt_widget_close" (void*) void))

  (define ffi-qt-widget-set-enabled
    (foreign-procedure "qt_widget_set_enabled" (void* int) void))

  (define ffi-qt-widget-is-enabled
    (foreign-procedure "qt_widget_is_enabled" (void*) int))

  (define ffi-qt-widget-set-visible
    (foreign-procedure "qt_widget_set_visible" (void* int) void))

  (define ffi-qt-widget-is-visible
    (foreign-procedure "qt_widget_is_visible" (void*) int))

  (define ffi-qt-widget-set-fixed-size
    (foreign-procedure "qt_widget_set_fixed_size" (void* int int) void))

  (define ffi-qt-widget-set-minimum-size
    (foreign-procedure "qt_widget_set_minimum_size" (void* int int) void))

  (define ffi-qt-widget-set-maximum-size
    (foreign-procedure "qt_widget_set_maximum_size" (void* int int) void))

  (define ffi-qt-widget-set-minimum-width
    (foreign-procedure "qt_widget_set_minimum_width" (void* int) void))

  (define ffi-qt-widget-set-minimum-height
    (foreign-procedure "qt_widget_set_minimum_height" (void* int) void))

  (define ffi-qt-widget-set-maximum-width
    (foreign-procedure "qt_widget_set_maximum_width" (void* int) void))

  (define ffi-qt-widget-set-maximum-height
    (foreign-procedure "qt_widget_set_maximum_height" (void* int) void))

  (define ffi-qt-widget-set-cursor
    (foreign-procedure "qt_widget_set_cursor" (void* int) void))

  (define ffi-qt-widget-unset-cursor
    (foreign-procedure "qt_widget_unset_cursor" (void*) void))

  (define ffi-qt-widget-resize
    (foreign-procedure "qt_widget_resize" (void* int int) void))

  (define ffi-qt-widget-set-style-sheet
    (foreign-procedure "qt_widget_set_style_sheet" (void* string) void))

  (define ffi-qt-widget-set-tooltip
    (foreign-procedure "qt_widget_set_tooltip" (void* string) void))

  (define ffi-qt-widget-set-font-size
    (foreign-procedure "qt_widget_set_font_size" (void* int) void))

  (define ffi-qt-widget-destroy
    (foreign-procedure "qt_widget_destroy" (void*) void))

  ;; Window state
  (define ffi-qt-widget-show-minimized
    (foreign-procedure "qt_widget_show_minimized" (void*) void))
  (define ffi-qt-widget-show-maximized
    (foreign-procedure "qt_widget_show_maximized" (void*) void))
  (define ffi-qt-widget-show-fullscreen
    (foreign-procedure "qt_widget_show_fullscreen" (void*) void))
  (define ffi-qt-widget-show-normal
    (foreign-procedure "qt_widget_show_normal" (void*) void))
  (define ffi-qt-widget-window-state
    (foreign-procedure "qt_widget_window_state" (void*) int))
  (define ffi-qt-widget-move
    (foreign-procedure "qt_widget_move" (void* int int) void))
  (define ffi-qt-widget-x
    (foreign-procedure "qt_widget_x" (void*) int))
  (define ffi-qt-widget-y
    (foreign-procedure "qt_widget_y" (void*) int))
  (define ffi-qt-widget-width
    (foreign-procedure "qt_widget_width" (void*) int))
  (define ffi-qt-widget-height
    (foreign-procedure "qt_widget_height" (void*) int))
  (define ffi-qt-widget-set-focus
    (foreign-procedure "qt_widget_set_focus" (void*) void))

  ;; -----------------------------------------------------------------------
  ;; Main Window
  ;; -----------------------------------------------------------------------

  (define ffi-qt-main-window-create
    (foreign-procedure "qt_main_window_create" (void*) void*))

  (define ffi-qt-main-window-set-title
    (foreign-procedure "qt_main_window_set_title" (void* string) void))

  (define ffi-qt-main-window-set-central-widget
    (foreign-procedure "qt_main_window_set_central_widget" (void* void*) void))

  (define ffi-qt-main-window-menu-bar
    (foreign-procedure "qt_main_window_menu_bar" (void*) void*))

  (define ffi-qt-main-window-add-toolbar
    (foreign-procedure "qt_main_window_add_toolbar" (void* void*) void))

  (define ffi-qt-main-window-set-status-bar-text
    (foreign-procedure "qt_main_window_set_status_bar_text" (void* string) void))

  ;; -----------------------------------------------------------------------
  ;; Layouts
  ;; -----------------------------------------------------------------------

  (define ffi-qt-vbox-layout-create
    (foreign-procedure "qt_vbox_layout_create" (void*) void*))

  (define ffi-qt-hbox-layout-create
    (foreign-procedure "qt_hbox_layout_create" (void*) void*))

  (define ffi-qt-layout-add-widget
    (foreign-procedure "qt_layout_add_widget" (void* void*) void))

  (define ffi-qt-layout-add-stretch
    (foreign-procedure "qt_layout_add_stretch" (void* int) void))

  (define ffi-qt-layout-set-spacing
    (foreign-procedure "qt_layout_set_spacing" (void* int) void))

  (define ffi-qt-layout-set-margins
    (foreign-procedure "qt_layout_set_margins" (void* int int int int) void))

  ;; Grid Layout
  (define ffi-qt-grid-layout-create
    (foreign-procedure "qt_grid_layout_create" (void*) void*))
  (define ffi-qt-grid-layout-add-widget
    (foreign-procedure "qt_grid_layout_add_widget" (void* void* int int int int) void))
  (define ffi-qt-grid-layout-set-row-stretch
    (foreign-procedure "qt_grid_layout_set_row_stretch" (void* int int) void))
  (define ffi-qt-grid-layout-set-column-stretch
    (foreign-procedure "qt_grid_layout_set_column_stretch" (void* int int) void))
  (define ffi-qt-grid-layout-set-row-minimum-height
    (foreign-procedure "qt_grid_layout_set_row_minimum_height" (void* int int) void))
  (define ffi-qt-grid-layout-set-column-minimum-width
    (foreign-procedure "qt_grid_layout_set_column_minimum_width" (void* int int) void))

  ;; -----------------------------------------------------------------------
  ;; Labels
  ;; -----------------------------------------------------------------------

  (define ffi-qt-label-create
    (foreign-procedure "qt_label_create" (string void*) void*))

  (define ffi-qt-label-set-text
    (foreign-procedure "qt_label_set_text" (void* string) void))

  (define ffi-qt-label-text
    (foreign-procedure "qt_label_text" (void*) string))

  (define ffi-qt-label-set-alignment
    (foreign-procedure "qt_label_set_alignment" (void* int) void))

  (define ffi-qt-label-set-word-wrap
    (foreign-procedure "qt_label_set_word_wrap" (void* int) void))

  (define ffi-qt-label-set-pixmap
    (foreign-procedure "qt_label_set_pixmap" (void* void*) void))

  ;; -----------------------------------------------------------------------
  ;; Push Button
  ;; -----------------------------------------------------------------------

  (define ffi-qt-push-button-create
    (foreign-procedure "qt_push_button_create" (string void*) void*))

  (define ffi-qt-push-button-set-text
    (foreign-procedure "qt_push_button_set_text" (void* string) void))

  (define ffi-qt-push-button-text
    (foreign-procedure "qt_push_button_text" (void*) string))

  (define ffi-qt-push-button-on-clicked
    (foreign-procedure "chez_qt_push_button_on_clicked" (void* long) void))

  (define ffi-qt-push-button-set-icon
    (foreign-procedure "qt_push_button_set_icon" (void* void*) void))

  ;; -----------------------------------------------------------------------
  ;; Line Edit
  ;; -----------------------------------------------------------------------

  (define ffi-qt-line-edit-create
    (foreign-procedure "qt_line_edit_create" (void*) void*))

  (define ffi-qt-line-edit-set-text
    (foreign-procedure "qt_line_edit_set_text" (void* string) void))

  (define ffi-qt-line-edit-text
    (foreign-procedure "qt_line_edit_text" (void*) string))

  (define ffi-qt-line-edit-set-placeholder
    (foreign-procedure "qt_line_edit_set_placeholder" (void* string) void))

  (define ffi-qt-line-edit-set-read-only
    (foreign-procedure "qt_line_edit_set_read_only" (void* int) void))

  (define ffi-qt-line-edit-set-echo-mode
    (foreign-procedure "qt_line_edit_set_echo_mode" (void* int) void))

  (define ffi-qt-line-edit-on-text-changed
    (foreign-procedure "chez_qt_line_edit_on_text_changed" (void* long) void))

  (define ffi-qt-line-edit-on-return-pressed
    (foreign-procedure "chez_qt_line_edit_on_return_pressed" (void* long) void))

  ;; -----------------------------------------------------------------------
  ;; Check Box
  ;; -----------------------------------------------------------------------

  (define ffi-qt-check-box-create
    (foreign-procedure "qt_check_box_create" (string void*) void*))

  (define ffi-qt-check-box-set-text
    (foreign-procedure "qt_check_box_set_text" (void* string) void))

  (define ffi-qt-check-box-set-checked
    (foreign-procedure "qt_check_box_set_checked" (void* int) void))

  (define ffi-qt-check-box-is-checked
    (foreign-procedure "qt_check_box_is_checked" (void*) int))

  (define ffi-qt-check-box-on-toggled
    (foreign-procedure "chez_qt_check_box_on_toggled" (void* long) void))

  ;; -----------------------------------------------------------------------
  ;; Combo Box
  ;; -----------------------------------------------------------------------

  (define ffi-qt-combo-box-create
    (foreign-procedure "qt_combo_box_create" (void*) void*))

  (define ffi-qt-combo-box-add-item
    (foreign-procedure "qt_combo_box_add_item" (void* string) void))

  (define ffi-qt-combo-box-set-current-index
    (foreign-procedure "qt_combo_box_set_current_index" (void* int) void))

  (define ffi-qt-combo-box-current-index
    (foreign-procedure "qt_combo_box_current_index" (void*) int))

  (define ffi-qt-combo-box-current-text
    (foreign-procedure "qt_combo_box_current_text" (void*) string))

  (define ffi-qt-combo-box-count
    (foreign-procedure "qt_combo_box_count" (void*) int))

  (define ffi-qt-combo-box-clear
    (foreign-procedure "qt_combo_box_clear" (void*) void))

  (define ffi-qt-combo-box-on-current-index-changed
    (foreign-procedure "chez_qt_combo_box_on_current_index_changed" (void* long) void))

  ;; -----------------------------------------------------------------------
  ;; Text Edit
  ;; -----------------------------------------------------------------------

  (define ffi-qt-text-edit-create
    (foreign-procedure "qt_text_edit_create" (void*) void*))

  (define ffi-qt-text-edit-set-text
    (foreign-procedure "qt_text_edit_set_text" (void* string) void))

  (define ffi-qt-text-edit-text
    (foreign-procedure "qt_text_edit_text" (void*) string))

  (define ffi-qt-text-edit-set-placeholder
    (foreign-procedure "qt_text_edit_set_placeholder" (void* string) void))

  (define ffi-qt-text-edit-set-read-only
    (foreign-procedure "qt_text_edit_set_read_only" (void* int) void))

  (define ffi-qt-text-edit-append
    (foreign-procedure "qt_text_edit_append" (void* string) void))

  (define ffi-qt-text-edit-clear
    (foreign-procedure "qt_text_edit_clear" (void*) void))

  (define ffi-qt-text-edit-scroll-to-bottom
    (foreign-procedure "qt_text_edit_scroll_to_bottom" (void*) void))

  (define ffi-qt-text-edit-html
    (foreign-procedure "qt_text_edit_html" (void*) string))

  (define ffi-qt-text-edit-on-text-changed
    (foreign-procedure "chez_qt_text_edit_on_text_changed" (void* long) void))

  ;; -----------------------------------------------------------------------
  ;; Spin Box
  ;; -----------------------------------------------------------------------

  (define ffi-qt-spin-box-create
    (foreign-procedure "qt_spin_box_create" (void*) void*))

  (define ffi-qt-spin-box-set-value
    (foreign-procedure "qt_spin_box_set_value" (void* int) void))

  (define ffi-qt-spin-box-value
    (foreign-procedure "qt_spin_box_value" (void*) int))

  (define ffi-qt-spin-box-set-range
    (foreign-procedure "qt_spin_box_set_range" (void* int int) void))

  (define ffi-qt-spin-box-set-single-step
    (foreign-procedure "qt_spin_box_set_single_step" (void* int) void))

  (define ffi-qt-spin-box-set-prefix
    (foreign-procedure "qt_spin_box_set_prefix" (void* string) void))

  (define ffi-qt-spin-box-set-suffix
    (foreign-procedure "qt_spin_box_set_suffix" (void* string) void))

  (define ffi-qt-spin-box-on-value-changed
    (foreign-procedure "chez_qt_spin_box_on_value_changed" (void* long) void))

  ;; -----------------------------------------------------------------------
  ;; Dialog
  ;; -----------------------------------------------------------------------

  (define ffi-qt-dialog-create
    (foreign-procedure "qt_dialog_create" (void*) void*))

  (define ffi-qt-dialog-exec
    (foreign-procedure "qt_dialog_exec" (void*) int))

  (define ffi-qt-dialog-accept
    (foreign-procedure "qt_dialog_accept" (void*) void))

  (define ffi-qt-dialog-reject
    (foreign-procedure "qt_dialog_reject" (void*) void))

  (define ffi-qt-dialog-set-title
    (foreign-procedure "qt_dialog_set_title" (void* string) void))

  ;; -----------------------------------------------------------------------
  ;; Message Box
  ;; -----------------------------------------------------------------------

  (define ffi-qt-message-box-information
    (foreign-procedure "qt_message_box_information" (void* string string) int))

  (define ffi-qt-message-box-warning
    (foreign-procedure "qt_message_box_warning" (void* string string) int))

  (define ffi-qt-message-box-question
    (foreign-procedure "qt_message_box_question" (void* string string) int))

  (define ffi-qt-message-box-critical
    (foreign-procedure "qt_message_box_critical" (void* string string) int))

  ;; -----------------------------------------------------------------------
  ;; File Dialog
  ;; -----------------------------------------------------------------------

  (define ffi-qt-file-dialog-open-file
    (foreign-procedure "qt_file_dialog_open_file" (void* string string string) string))

  (define ffi-qt-file-dialog-save-file
    (foreign-procedure "qt_file_dialog_save_file" (void* string string string) string))

  (define ffi-qt-file-dialog-open-directory
    (foreign-procedure "qt_file_dialog_open_directory" (void* string string) string))

  ;; -----------------------------------------------------------------------
  ;; Menu
  ;; -----------------------------------------------------------------------

  (define ffi-qt-menu-bar-add-menu
    (foreign-procedure "qt_menu_bar_add_menu" (void* string) void*))

  (define ffi-qt-menu-add-menu
    (foreign-procedure "qt_menu_add_menu" (void* string) void*))

  (define ffi-qt-menu-add-action
    (foreign-procedure "qt_menu_add_action" (void* void*) void))

  (define ffi-qt-menu-add-separator
    (foreign-procedure "qt_menu_add_separator" (void*) void))

  ;; -----------------------------------------------------------------------
  ;; Action
  ;; -----------------------------------------------------------------------

  (define ffi-qt-action-create
    (foreign-procedure "qt_action_create" (string void*) void*))

  (define ffi-qt-action-set-text
    (foreign-procedure "qt_action_set_text" (void* string) void))

  (define ffi-qt-action-text
    (foreign-procedure "qt_action_text" (void*) string))

  (define ffi-qt-action-set-shortcut
    (foreign-procedure "qt_action_set_shortcut" (void* string) void))

  (define ffi-qt-action-set-enabled
    (foreign-procedure "qt_action_set_enabled" (void* int) void))

  (define ffi-qt-action-is-enabled
    (foreign-procedure "qt_action_is_enabled" (void*) int))

  (define ffi-qt-action-set-checkable
    (foreign-procedure "qt_action_set_checkable" (void* int) void))

  (define ffi-qt-action-is-checkable
    (foreign-procedure "qt_action_is_checkable" (void*) int))

  (define ffi-qt-action-set-checked
    (foreign-procedure "qt_action_set_checked" (void* int) void))

  (define ffi-qt-action-is-checked
    (foreign-procedure "qt_action_is_checked" (void*) int))

  (define ffi-qt-action-set-tooltip
    (foreign-procedure "qt_action_set_tooltip" (void* string) void))

  (define ffi-qt-action-set-status-tip
    (foreign-procedure "qt_action_set_status_tip" (void* string) void))

  (define ffi-qt-action-on-triggered
    (foreign-procedure "chez_qt_action_on_triggered" (void* long) void))

  (define ffi-qt-action-on-toggled
    (foreign-procedure "chez_qt_action_on_toggled" (void* long) void))

  (define ffi-qt-action-set-icon
    (foreign-procedure "qt_action_set_icon" (void* void*) void))

  ;; -----------------------------------------------------------------------
  ;; Toolbar
  ;; -----------------------------------------------------------------------

  (define ffi-qt-toolbar-create
    (foreign-procedure "qt_toolbar_create" (string void*) void*))

  (define ffi-qt-toolbar-add-action
    (foreign-procedure "qt_toolbar_add_action" (void* void*) void))

  (define ffi-qt-toolbar-add-separator
    (foreign-procedure "qt_toolbar_add_separator" (void*) void))

  (define ffi-qt-toolbar-add-widget
    (foreign-procedure "qt_toolbar_add_widget" (void* void*) void))

  (define ffi-qt-toolbar-set-movable
    (foreign-procedure "qt_toolbar_set_movable" (void* int) void))

  (define ffi-qt-toolbar-set-icon-size
    (foreign-procedure "qt_toolbar_set_icon_size" (void* int int) void))

  ;; -----------------------------------------------------------------------
  ;; Timer
  ;; -----------------------------------------------------------------------

  (define ffi-qt-timer-create
    (foreign-procedure "qt_timer_create" () void*))
  (define ffi-qt-timer-start
    (foreign-procedure "qt_timer_start" (void* int) void))
  (define ffi-qt-timer-stop
    (foreign-procedure "qt_timer_stop" (void*) void))
  (define ffi-qt-timer-set-single-shot
    (foreign-procedure "qt_timer_set_single_shot" (void* int) void))
  (define ffi-qt-timer-is-active
    (foreign-procedure "qt_timer_is_active" (void*) int))
  (define ffi-qt-timer-interval
    (foreign-procedure "qt_timer_interval" (void*) int))
  (define ffi-qt-timer-set-interval
    (foreign-procedure "qt_timer_set_interval" (void* int) void))
  (define ffi-qt-timer-on-timeout
    (foreign-procedure "chez_qt_timer_on_timeout" (void* long) void))
  (define ffi-qt-timer-single-shot
    (foreign-procedure "chez_qt_timer_single_shot" (int long) void))
  (define ffi-qt-timer-destroy
    (foreign-procedure "qt_timer_destroy" (void*) void))

  ;; -----------------------------------------------------------------------
  ;; Clipboard
  ;; -----------------------------------------------------------------------

  (define ffi-qt-clipboard-text
    (foreign-procedure "qt_clipboard_text" (void*) string))
  (define ffi-qt-clipboard-set-text
    (foreign-procedure "qt_clipboard_set_text" (void* string) void))
  (define ffi-qt-clipboard-on-changed
    (foreign-procedure "chez_qt_clipboard_on_changed" (void* long) void))

  ;; -----------------------------------------------------------------------
  ;; Tree Widget
  ;; -----------------------------------------------------------------------

  (define ffi-qt-tree-widget-create
    (foreign-procedure "qt_tree_widget_create" (void*) void*))
  (define ffi-qt-tree-widget-set-column-count
    (foreign-procedure "qt_tree_widget_set_column_count" (void* int) void))
  (define ffi-qt-tree-widget-column-count
    (foreign-procedure "qt_tree_widget_column_count" (void*) int))
  (define ffi-qt-tree-widget-set-header-label
    (foreign-procedure "qt_tree_widget_set_header_label" (void* string) void))
  (define ffi-qt-tree-widget-set-header-item-text
    (foreign-procedure "qt_tree_widget_set_header_item_text" (void* int string) void))
  (define ffi-qt-tree-widget-add-top-level-item
    (foreign-procedure "qt_tree_widget_add_top_level_item" (void* void*) void))
  (define ffi-qt-tree-widget-top-level-item-count
    (foreign-procedure "qt_tree_widget_top_level_item_count" (void*) int))
  (define ffi-qt-tree-widget-top-level-item
    (foreign-procedure "qt_tree_widget_top_level_item" (void* int) void*))
  (define ffi-qt-tree-widget-current-item
    (foreign-procedure "qt_tree_widget_current_item" (void*) void*))
  (define ffi-qt-tree-widget-set-current-item
    (foreign-procedure "qt_tree_widget_set_current_item" (void* void*) void))
  (define ffi-qt-tree-widget-expand-item
    (foreign-procedure "qt_tree_widget_expand_item" (void* void*) void))
  (define ffi-qt-tree-widget-collapse-item
    (foreign-procedure "qt_tree_widget_collapse_item" (void* void*) void))
  (define ffi-qt-tree-widget-expand-all
    (foreign-procedure "qt_tree_widget_expand_all" (void*) void))
  (define ffi-qt-tree-widget-collapse-all
    (foreign-procedure "qt_tree_widget_collapse_all" (void*) void))
  (define ffi-qt-tree-widget-clear
    (foreign-procedure "qt_tree_widget_clear" (void*) void))
  (define ffi-qt-tree-widget-on-current-item-changed
    (foreign-procedure "chez_qt_tree_widget_on_current_item_changed" (void* long) void))
  (define ffi-qt-tree-widget-on-item-double-clicked
    (foreign-procedure "chez_qt_tree_widget_on_item_double_clicked" (void* long) void))
  (define ffi-qt-tree-widget-on-item-expanded
    (foreign-procedure "chez_qt_tree_widget_on_item_expanded" (void* long) void))
  (define ffi-qt-tree-widget-on-item-collapsed
    (foreign-procedure "chez_qt_tree_widget_on_item_collapsed" (void* long) void))

  ;; Tree Widget Item
  (define ffi-qt-tree-item-create
    (foreign-procedure "qt_tree_item_create" (string) void*))
  (define ffi-qt-tree-item-set-text
    (foreign-procedure "qt_tree_item_set_text" (void* int string) void))
  (define ffi-qt-tree-item-text
    (foreign-procedure "qt_tree_item_text" (void* int) string))
  (define ffi-qt-tree-item-add-child
    (foreign-procedure "qt_tree_item_add_child" (void* void*) void))
  (define ffi-qt-tree-item-child-count
    (foreign-procedure "qt_tree_item_child_count" (void*) int))
  (define ffi-qt-tree-item-child
    (foreign-procedure "qt_tree_item_child" (void* int) void*))
  (define ffi-qt-tree-item-parent
    (foreign-procedure "qt_tree_item_parent" (void*) void*))
  (define ffi-qt-tree-item-set-expanded
    (foreign-procedure "qt_tree_item_set_expanded" (void* int) void))
  (define ffi-qt-tree-item-is-expanded
    (foreign-procedure "qt_tree_item_is_expanded" (void*) int))

  ;; -----------------------------------------------------------------------
  ;; List Widget
  ;; -----------------------------------------------------------------------

  (define ffi-qt-list-widget-create
    (foreign-procedure "qt_list_widget_create" (void*) void*))
  (define ffi-qt-list-widget-add-item
    (foreign-procedure "qt_list_widget_add_item" (void* string) void))
  (define ffi-qt-list-widget-insert-item
    (foreign-procedure "qt_list_widget_insert_item" (void* int string) void))
  (define ffi-qt-list-widget-remove-item
    (foreign-procedure "qt_list_widget_remove_item" (void* int) void))
  (define ffi-qt-list-widget-current-row
    (foreign-procedure "qt_list_widget_current_row" (void*) int))
  (define ffi-qt-list-widget-set-current-row
    (foreign-procedure "qt_list_widget_set_current_row" (void* int) void))
  (define ffi-qt-list-widget-item-text
    (foreign-procedure "qt_list_widget_item_text" (void* int) string))
  (define ffi-qt-list-widget-count
    (foreign-procedure "qt_list_widget_count" (void*) int))
  (define ffi-qt-list-widget-clear
    (foreign-procedure "qt_list_widget_clear" (void*) void))
  (define ffi-qt-list-widget-set-item-data
    (foreign-procedure "qt_list_widget_set_item_data" (void* int string) void))
  (define ffi-qt-list-widget-item-data
    (foreign-procedure "qt_list_widget_item_data" (void* int) string))
  (define ffi-qt-list-widget-on-current-row-changed
    (foreign-procedure "chez_qt_list_widget_on_current_row_changed" (void* long) void))
  (define ffi-qt-list-widget-on-item-double-clicked
    (foreign-procedure "chez_qt_list_widget_on_item_double_clicked" (void* long) void))

  ;; -----------------------------------------------------------------------
  ;; Table Widget
  ;; -----------------------------------------------------------------------

  (define ffi-qt-table-widget-create
    (foreign-procedure "qt_table_widget_create" (int int void*) void*))
  (define ffi-qt-table-widget-set-item
    (foreign-procedure "qt_table_widget_set_item" (void* int int string) void))
  (define ffi-qt-table-widget-item-text
    (foreign-procedure "qt_table_widget_item_text" (void* int int) string))
  (define ffi-qt-table-widget-set-horizontal-header-item
    (foreign-procedure "qt_table_widget_set_horizontal_header_item" (void* int string) void))
  (define ffi-qt-table-widget-set-vertical-header-item
    (foreign-procedure "qt_table_widget_set_vertical_header_item" (void* int string) void))
  (define ffi-qt-table-widget-set-row-count
    (foreign-procedure "qt_table_widget_set_row_count" (void* int) void))
  (define ffi-qt-table-widget-set-column-count
    (foreign-procedure "qt_table_widget_set_column_count" (void* int) void))
  (define ffi-qt-table-widget-row-count
    (foreign-procedure "qt_table_widget_row_count" (void*) int))
  (define ffi-qt-table-widget-column-count
    (foreign-procedure "qt_table_widget_column_count" (void*) int))
  (define ffi-qt-table-widget-current-row
    (foreign-procedure "qt_table_widget_current_row" (void*) int))
  (define ffi-qt-table-widget-current-column
    (foreign-procedure "qt_table_widget_current_column" (void*) int))
  (define ffi-qt-table-widget-clear
    (foreign-procedure "qt_table_widget_clear" (void*) void))
  (define ffi-qt-table-widget-on-cell-clicked
    (foreign-procedure "chez_qt_table_widget_on_cell_clicked" (void* long) void))

  ;; -----------------------------------------------------------------------
  ;; Tab Widget
  ;; -----------------------------------------------------------------------

  (define ffi-qt-tab-widget-create
    (foreign-procedure "qt_tab_widget_create" (void*) void*))
  (define ffi-qt-tab-widget-add-tab
    (foreign-procedure "qt_tab_widget_add_tab" (void* void* string) void))
  (define ffi-qt-tab-widget-set-current-index
    (foreign-procedure "qt_tab_widget_set_current_index" (void* int) void))
  (define ffi-qt-tab-widget-current-index
    (foreign-procedure "qt_tab_widget_current_index" (void*) int))
  (define ffi-qt-tab-widget-count
    (foreign-procedure "qt_tab_widget_count" (void*) int))
  (define ffi-qt-tab-widget-set-tab-text
    (foreign-procedure "qt_tab_widget_set_tab_text" (void* int string) void))
  (define ffi-qt-tab-widget-on-current-changed
    (foreign-procedure "chez_qt_tab_widget_on_current_changed" (void* long) void))

  ;; -----------------------------------------------------------------------
  ;; Progress Bar
  ;; -----------------------------------------------------------------------

  (define ffi-qt-progress-bar-create
    (foreign-procedure "qt_progress_bar_create" (void*) void*))
  (define ffi-qt-progress-bar-set-value
    (foreign-procedure "qt_progress_bar_set_value" (void* int) void))
  (define ffi-qt-progress-bar-value
    (foreign-procedure "qt_progress_bar_value" (void*) int))
  (define ffi-qt-progress-bar-set-range
    (foreign-procedure "qt_progress_bar_set_range" (void* int int) void))
  (define ffi-qt-progress-bar-set-format
    (foreign-procedure "qt_progress_bar_set_format" (void* string) void))

  ;; -----------------------------------------------------------------------
  ;; Slider
  ;; -----------------------------------------------------------------------

  (define ffi-qt-slider-create
    (foreign-procedure "qt_slider_create" (int void*) void*))
  (define ffi-qt-slider-set-value
    (foreign-procedure "qt_slider_set_value" (void* int) void))
  (define ffi-qt-slider-value
    (foreign-procedure "qt_slider_value" (void*) int))
  (define ffi-qt-slider-set-range
    (foreign-procedure "qt_slider_set_range" (void* int int) void))
  (define ffi-qt-slider-set-single-step
    (foreign-procedure "qt_slider_set_single_step" (void* int) void))
  (define ffi-qt-slider-set-tick-interval
    (foreign-procedure "qt_slider_set_tick_interval" (void* int) void))
  (define ffi-qt-slider-set-tick-position
    (foreign-procedure "qt_slider_set_tick_position" (void* int) void))
  (define ffi-qt-slider-on-value-changed
    (foreign-procedure "chez_qt_slider_on_value_changed" (void* long) void))

  ;; -----------------------------------------------------------------------
  ;; Scroll Area
  ;; -----------------------------------------------------------------------

  (define ffi-qt-scroll-area-create
    (foreign-procedure "qt_scroll_area_create" (void*) void*))
  (define ffi-qt-scroll-area-set-widget
    (foreign-procedure "qt_scroll_area_set_widget" (void* void*) void))
  (define ffi-qt-scroll-area-set-widget-resizable
    (foreign-procedure "qt_scroll_area_set_widget_resizable" (void* int) void))
  (define ffi-qt-scroll-area-set-horizontal-scrollbar-policy
    (foreign-procedure "qt_scroll_area_set_horizontal_scrollbar_policy" (void* int) void))
  (define ffi-qt-scroll-area-set-vertical-scrollbar-policy
    (foreign-procedure "qt_scroll_area_set_vertical_scrollbar_policy" (void* int) void))

  ;; -----------------------------------------------------------------------
  ;; Splitter
  ;; -----------------------------------------------------------------------

  (define ffi-qt-splitter-create
    (foreign-procedure "qt_splitter_create" (int void*) void*))
  (define ffi-qt-splitter-add-widget
    (foreign-procedure "qt_splitter_add_widget" (void* void*) void))
  (define ffi-qt-splitter-insert-widget
    (foreign-procedure "qt_splitter_insert_widget" (void* int void*) void))
  (define ffi-qt-splitter-index-of
    (foreign-procedure "qt_splitter_index_of" (void* void*) int))
  (define ffi-qt-splitter-widget
    (foreign-procedure "qt_splitter_widget" (void* int) void*))
  (define ffi-qt-splitter-count
    (foreign-procedure "qt_splitter_count" (void*) int))
  (define ffi-qt-splitter-set-sizes-2
    (foreign-procedure "qt_splitter_set_sizes_2" (void* int int) void))
  (define ffi-qt-splitter-set-sizes-3
    (foreign-procedure "qt_splitter_set_sizes_3" (void* int int int) void))
  (define ffi-qt-splitter-size-at
    (foreign-procedure "qt_splitter_size_at" (void* int) int))
  (define ffi-qt-splitter-set-stretch-factor
    (foreign-procedure "qt_splitter_set_stretch_factor" (void* int int) void))
  (define ffi-qt-splitter-set-handle-width
    (foreign-procedure "qt_splitter_set_handle_width" (void* int) void))
  (define ffi-qt-splitter-set-collapsible
    (foreign-procedure "qt_splitter_set_collapsible" (void* int int) void))
  (define ffi-qt-splitter-is-collapsible
    (foreign-procedure "qt_splitter_is_collapsible" (void* int) int))
  (define ffi-qt-splitter-set-orientation
    (foreign-procedure "qt_splitter_set_orientation" (void* int) void))

  ;; -----------------------------------------------------------------------
  ;; Keyboard Events
  ;; -----------------------------------------------------------------------

  (define ffi-qt-install-key-handler
    (foreign-procedure "chez_qt_install_key_handler" (void* long) void))
  (define ffi-qt-install-key-handler-consuming
    (foreign-procedure "chez_qt_install_key_handler_consuming" (void* long) void))
  (define ffi-qt-last-key-code
    (foreign-procedure "qt_last_key_code" () int))
  (define ffi-qt-last-key-modifiers
    (foreign-procedure "qt_last_key_modifiers" () int))
  (define ffi-qt-last-key-text
    (foreign-procedure "qt_last_key_text" () string))

  ;; -----------------------------------------------------------------------
  ;; Pixmap
  ;; -----------------------------------------------------------------------

  (define ffi-qt-pixmap-load
    (foreign-procedure "qt_pixmap_load" (string) void*))
  (define ffi-qt-pixmap-width
    (foreign-procedure "qt_pixmap_width" (void*) int))
  (define ffi-qt-pixmap-height
    (foreign-procedure "qt_pixmap_height" (void*) int))
  (define ffi-qt-pixmap-is-null
    (foreign-procedure "qt_pixmap_is_null" (void*) int))
  (define ffi-qt-pixmap-scaled
    (foreign-procedure "qt_pixmap_scaled" (void* int int int) void*))
  (define ffi-qt-pixmap-destroy
    (foreign-procedure "qt_pixmap_destroy" (void*) void))

  ;; -----------------------------------------------------------------------
  ;; Icon
  ;; -----------------------------------------------------------------------

  (define ffi-qt-icon-create
    (foreign-procedure "qt_icon_create" (string) void*))
  (define ffi-qt-icon-create-from-pixmap
    (foreign-procedure "qt_icon_create_from_pixmap" (void*) void*))
  (define ffi-qt-icon-is-null
    (foreign-procedure "qt_icon_is_null" (void*) int))
  (define ffi-qt-icon-destroy
    (foreign-procedure "qt_icon_destroy" (void*) void))
  (define ffi-qt-widget-set-window-icon
    (foreign-procedure "qt_widget_set_window_icon" (void* void*) void))

  ;; -----------------------------------------------------------------------
  ;; Radio Button
  ;; -----------------------------------------------------------------------

  (define ffi-qt-radio-button-create
    (foreign-procedure "qt_radio_button_create" (string void*) void*))
  (define ffi-qt-radio-button-text
    (foreign-procedure "qt_radio_button_text" (void*) string))
  (define ffi-qt-radio-button-set-text
    (foreign-procedure "qt_radio_button_set_text" (void* string) void))
  (define ffi-qt-radio-button-is-checked
    (foreign-procedure "qt_radio_button_is_checked" (void*) int))
  (define ffi-qt-radio-button-set-checked
    (foreign-procedure "qt_radio_button_set_checked" (void* int) void))
  (define ffi-qt-radio-button-on-toggled
    (foreign-procedure "chez_qt_radio_button_on_toggled" (void* long) void))

  ;; -----------------------------------------------------------------------
  ;; Button Group
  ;; -----------------------------------------------------------------------

  (define ffi-qt-button-group-create
    (foreign-procedure "qt_button_group_create" (void*) void*))
  (define ffi-qt-button-group-add-button
    (foreign-procedure "qt_button_group_add_button" (void* void* int) void))
  (define ffi-qt-button-group-remove-button
    (foreign-procedure "qt_button_group_remove_button" (void* void*) void))
  (define ffi-qt-button-group-checked-id
    (foreign-procedure "qt_button_group_checked_id" (void*) int))
  (define ffi-qt-button-group-set-exclusive
    (foreign-procedure "qt_button_group_set_exclusive" (void* int) void))
  (define ffi-qt-button-group-is-exclusive
    (foreign-procedure "qt_button_group_is_exclusive" (void*) int))
  (define ffi-qt-button-group-on-clicked
    (foreign-procedure "chez_qt_button_group_on_clicked" (void* long) void))
  (define ffi-qt-button-group-destroy
    (foreign-procedure "qt_button_group_destroy" (void*) void))

  ;; -----------------------------------------------------------------------
  ;; Group Box
  ;; -----------------------------------------------------------------------

  (define ffi-qt-group-box-create
    (foreign-procedure "qt_group_box_create" (string void*) void*))
  (define ffi-qt-group-box-title
    (foreign-procedure "qt_group_box_title" (void*) string))
  (define ffi-qt-group-box-set-title
    (foreign-procedure "qt_group_box_set_title" (void* string) void))
  (define ffi-qt-group-box-set-checkable
    (foreign-procedure "qt_group_box_set_checkable" (void* int) void))
  (define ffi-qt-group-box-is-checkable
    (foreign-procedure "qt_group_box_is_checkable" (void*) int))
  (define ffi-qt-group-box-set-checked
    (foreign-procedure "qt_group_box_set_checked" (void* int) void))
  (define ffi-qt-group-box-is-checked
    (foreign-procedure "qt_group_box_is_checked" (void*) int))
  (define ffi-qt-group-box-on-toggled
    (foreign-procedure "chez_qt_group_box_on_toggled" (void* long) void))

  ;; -----------------------------------------------------------------------
  ;; Font
  ;; -----------------------------------------------------------------------

  (define ffi-qt-font-create
    (foreign-procedure "qt_font_create" (string int) void*))
  (define ffi-qt-font-family
    (foreign-procedure "qt_font_family" (void*) string))
  (define ffi-qt-font-point-size
    (foreign-procedure "qt_font_point_size" (void*) int))
  (define ffi-qt-font-is-bold
    (foreign-procedure "qt_font_is_bold" (void*) int))
  (define ffi-qt-font-set-bold
    (foreign-procedure "qt_font_set_bold" (void* int) void))
  (define ffi-qt-font-is-italic
    (foreign-procedure "qt_font_is_italic" (void*) int))
  (define ffi-qt-font-set-italic
    (foreign-procedure "qt_font_set_italic" (void* int) void))
  (define ffi-qt-font-destroy
    (foreign-procedure "qt_font_destroy" (void*) void))
  (define ffi-qt-widget-set-font
    (foreign-procedure "qt_widget_set_font" (void* void*) void))
  (define ffi-qt-widget-font
    (foreign-procedure "qt_widget_font" (void*) void*))

  ;; -----------------------------------------------------------------------
  ;; Color
  ;; -----------------------------------------------------------------------

  (define ffi-qt-color-create
    (foreign-procedure "qt_color_create_rgb" (int int int int) void*))
  (define ffi-qt-color-create-name
    (foreign-procedure "qt_color_create_name" (string) void*))
  (define ffi-qt-color-red
    (foreign-procedure "qt_color_red" (void*) int))
  (define ffi-qt-color-green
    (foreign-procedure "qt_color_green" (void*) int))
  (define ffi-qt-color-blue
    (foreign-procedure "qt_color_blue" (void*) int))
  (define ffi-qt-color-alpha
    (foreign-procedure "qt_color_alpha" (void*) int))
  (define ffi-qt-color-name
    (foreign-procedure "qt_color_name" (void*) string))
  (define ffi-qt-color-is-valid
    (foreign-procedure "qt_color_is_valid" (void*) int))
  (define ffi-qt-color-destroy
    (foreign-procedure "qt_color_destroy" (void*) void))

) ;; end library
