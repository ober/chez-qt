/* qt_chez_shim.c — Callback bridge for Chez Scheme FFI
 *
 * Chez Scheme's foreign-callable creates function pointers at runtime,
 * unlike Gambit's c-define which creates static trampolines at compile time.
 *
 * This shim stores the Chez-provided callback function pointers and
 * provides C functions that qt_shim.cpp can call through them.
 *
 * Pattern:
 *   1. Chez creates foreign-callable → gets a C function pointer
 *   2. Chez calls chez_qt_set_*_callback() to register that pointer
 *   3. Signal connection wrappers use the stored pointer as the trampoline
 */

#include "qt_shim.h"
#include <stddef.h>

/* ---- Stored callback function pointers (set from Chez at init time) ---- */
static qt_callback_void   chez_void_callback   = NULL;
static qt_callback_string chez_string_callback  = NULL;
static qt_callback_int    chez_int_callback     = NULL;
static qt_callback_bool   chez_bool_callback    = NULL;

/* ---- Registration functions (called once from Chez at library load) ---- */
void chez_qt_set_void_callback(qt_callback_void cb)     { chez_void_callback = cb; }
void chez_qt_set_string_callback(qt_callback_string cb)  { chez_string_callback = cb; }
void chez_qt_set_int_callback(qt_callback_int cb)        { chez_int_callback = cb; }
void chez_qt_set_bool_callback(qt_callback_bool cb)      { chez_bool_callback = cb; }

/* ---- Application lifecycle ---- */
void* chez_qt_application_create(void) {
    return qt_application_create(0, NULL);
}

/* ---- Signal connection wrappers ---- */
/* Each wrapper inserts the stored Chez trampoline as the callback */

/* Push Button */
void chez_qt_push_button_on_clicked(void* b, long callback_id) {
    if (chez_void_callback)
        qt_push_button_on_clicked(b, chez_void_callback, callback_id);
}

/* Line Edit */
void chez_qt_line_edit_on_text_changed(void* e, long callback_id) {
    if (chez_string_callback)
        qt_line_edit_on_text_changed(e, chez_string_callback, callback_id);
}
void chez_qt_line_edit_on_return_pressed(void* e, long callback_id) {
    if (chez_void_callback)
        qt_line_edit_on_return_pressed(e, chez_void_callback, callback_id);
}

/* Check Box */
void chez_qt_check_box_on_toggled(void* c, long callback_id) {
    if (chez_bool_callback)
        qt_check_box_on_toggled(c, chez_bool_callback, callback_id);
}

/* Combo Box */
void chez_qt_combo_box_on_current_index_changed(void* c, long callback_id) {
    if (chez_int_callback)
        qt_combo_box_on_current_index_changed(c, chez_int_callback, callback_id);
}

/* Text Edit */
void chez_qt_text_edit_on_text_changed(void* e, long callback_id) {
    if (chez_void_callback)
        qt_text_edit_on_text_changed(e, chez_void_callback, callback_id);
}

/* Spin Box */
void chez_qt_spin_box_on_value_changed(void* s, long callback_id) {
    if (chez_int_callback)
        qt_spin_box_on_value_changed(s, chez_int_callback, callback_id);
}

/* Action */
void chez_qt_action_on_triggered(void* a, long callback_id) {
    if (chez_void_callback)
        qt_action_on_triggered(a, chez_void_callback, callback_id);
}
void chez_qt_action_on_toggled(void* a, long callback_id) {
    if (chez_bool_callback)
        qt_action_on_toggled(a, chez_bool_callback, callback_id);
}

/* List Widget */
void chez_qt_list_widget_on_current_row_changed(void* l, long callback_id) {
    if (chez_int_callback)
        qt_list_widget_on_current_row_changed(l, chez_int_callback, callback_id);
}
void chez_qt_list_widget_on_item_double_clicked(void* l, long callback_id) {
    if (chez_int_callback)
        qt_list_widget_on_item_double_clicked(l, chez_int_callback, callback_id);
}

/* Table Widget */
void chez_qt_table_widget_on_cell_clicked(void* t, long callback_id) {
    if (chez_void_callback)
        qt_table_widget_on_cell_clicked(t, chez_void_callback, callback_id);
}

/* Tab Widget */
void chez_qt_tab_widget_on_current_changed(void* t, long callback_id) {
    if (chez_int_callback)
        qt_tab_widget_on_current_changed(t, chez_int_callback, callback_id);
}

/* Slider */
void chez_qt_slider_on_value_changed(void* s, long callback_id) {
    if (chez_int_callback)
        qt_slider_on_value_changed(s, chez_int_callback, callback_id);
}

/* Timer */
void chez_qt_timer_on_timeout(void* t, long callback_id) {
    if (chez_void_callback)
        qt_timer_on_timeout(t, chez_void_callback, callback_id);
}
void chez_qt_timer_single_shot(int msec, long callback_id) {
    if (chez_void_callback)
        qt_timer_single_shot(msec, chez_void_callback, callback_id);
}

/* Clipboard */
void chez_qt_clipboard_on_changed(void* app, long callback_id) {
    if (chez_void_callback)
        qt_clipboard_on_changed(app, chez_void_callback, callback_id);
}

/* Tree Widget */
void chez_qt_tree_widget_on_current_item_changed(void* t, long callback_id) {
    if (chez_void_callback)
        qt_tree_widget_on_current_item_changed(t, chez_void_callback, callback_id);
}
void chez_qt_tree_widget_on_item_double_clicked(void* t, long callback_id) {
    if (chez_void_callback)
        qt_tree_widget_on_item_double_clicked(t, chez_void_callback, callback_id);
}
void chez_qt_tree_widget_on_item_expanded(void* t, long callback_id) {
    if (chez_void_callback)
        qt_tree_widget_on_item_expanded(t, chez_void_callback, callback_id);
}
void chez_qt_tree_widget_on_item_collapsed(void* t, long callback_id) {
    if (chez_void_callback)
        qt_tree_widget_on_item_collapsed(t, chez_void_callback, callback_id);
}

/* Keyboard Events */
void chez_qt_install_key_handler(void* w, long callback_id) {
    if (chez_void_callback)
        qt_widget_install_key_handler(w, chez_void_callback, callback_id);
}
void chez_qt_install_key_handler_consuming(void* w, long callback_id) {
    if (chez_void_callback)
        qt_widget_install_key_handler_consuming(w, chez_void_callback, callback_id);
}

/* Scroll Area — no signals, just direct pass-through */

/* Splitter — no signals */

/* Progress Bar — no signal wrapper needed, progress bar has no on_value_changed in qt_shim */

/* Radio Button */
void chez_qt_radio_button_on_toggled(void* r, long callback_id) {
    if (chez_bool_callback)
        qt_radio_button_on_toggled(r, chez_bool_callback, callback_id);
}

/* Button Group */
void chez_qt_button_group_on_clicked(void* g, long callback_id) {
    if (chez_int_callback)
        qt_button_group_on_id_clicked(g, chez_int_callback, callback_id);
}

/* Group Box */
void chez_qt_group_box_on_toggled(void* g, long callback_id) {
    if (chez_bool_callback)
        qt_group_box_on_toggled(g, chez_bool_callback, callback_id);
}

/* Stacked Widget */
void chez_qt_stacked_widget_on_current_changed(void* s, long callback_id) {
    if (chez_int_callback)
        qt_stacked_widget_on_current_changed(s, chez_int_callback, callback_id);
}

/* System Tray */
void chez_qt_system_tray_icon_on_activated(void* t, long callback_id) {
    if (chez_int_callback)
        qt_system_tray_icon_on_activated(t, chez_int_callback, callback_id);
}

/* Paint Widget */
void chez_qt_paint_widget_on_paint(void* w, long callback_id) {
    if (chez_void_callback)
        qt_paint_widget_on_paint(w, chez_void_callback, callback_id);
}

/* Completer */
void chez_qt_completer_on_activated(void* c, long callback_id) {
    if (chez_string_callback)
        qt_completer_on_activated(c, chez_string_callback, callback_id);
}

/* Double Spin Box — value comes as string */
void chez_qt_double_spin_box_on_value_changed(void* s, long callback_id) {
    if (chez_string_callback)
        qt_double_spin_box_on_value_changed(s, chez_string_callback, callback_id);
}

/* Date Edit — date comes as string */
void chez_qt_date_edit_on_date_changed(void* d, long callback_id) {
    if (chez_string_callback)
        qt_date_edit_on_date_changed(d, chez_string_callback, callback_id);
}

/* Time Edit — time comes as string */
void chez_qt_time_edit_on_time_changed(void* t, long callback_id) {
    if (chez_string_callback)
        qt_time_edit_on_time_changed(t, chez_string_callback, callback_id);
}

/* Progress Dialog */
void chez_qt_progress_dialog_on_canceled(void* d, long callback_id) {
    if (chez_void_callback)
        qt_progress_dialog_on_canceled(d, chez_void_callback, callback_id);
}

/* Shortcut */
void chez_qt_shortcut_on_activated(void* s, long callback_id) {
    if (chez_void_callback)
        qt_shortcut_on_activated(s, chez_void_callback, callback_id);
}

/* Text Browser */
void chez_qt_text_browser_on_anchor_clicked(void* b, long callback_id) {
    if (chez_string_callback)
        qt_text_browser_on_anchor_clicked(b, chez_string_callback, callback_id);
}

/* Button Box */
void chez_qt_button_box_on_accepted(void* b, long callback_id) {
    if (chez_void_callback)
        qt_button_box_on_accepted(b, chez_void_callback, callback_id);
}
void chez_qt_button_box_on_rejected(void* b, long callback_id) {
    if (chez_void_callback)
        qt_button_box_on_rejected(b, chez_void_callback, callback_id);
}
void chez_qt_button_box_on_clicked(void* b, long callback_id) {
    if (chez_void_callback)
        qt_button_box_on_clicked(b, chez_void_callback, callback_id);
}

/* Calendar */
void chez_qt_calendar_on_selection_changed(void* c, long callback_id) {
    if (chez_void_callback)
        qt_calendar_on_selection_changed(c, chez_void_callback, callback_id);
}
void chez_qt_calendar_on_clicked(void* c, long callback_id) {
    if (chez_string_callback)
        qt_calendar_on_clicked(c, chez_string_callback, callback_id);
}

/* View signals */
void chez_qt_view_on_clicked(void* v, long callback_id) {
    if (chez_void_callback)
        qt_view_on_clicked(v, chez_void_callback, callback_id);
}
void chez_qt_view_on_double_clicked(void* v, long callback_id) {
    if (chez_void_callback)
        qt_view_on_double_clicked(v, chez_void_callback, callback_id);
}
void chez_qt_view_on_activated(void* v, long callback_id) {
    if (chez_void_callback)
        qt_view_on_activated(v, chez_void_callback, callback_id);
}
void chez_qt_view_on_selection_changed(void* v, long callback_id) {
    if (chez_void_callback)
        qt_view_on_selection_changed(v, chez_void_callback, callback_id);
}

/* Plain Text Edit */
void chez_qt_plain_text_edit_on_text_changed(void* e, long callback_id) {
    if (chez_void_callback)
        qt_plain_text_edit_on_text_changed(e, chez_void_callback, callback_id);
}

/* Tool Button */
void chez_qt_tool_button_on_clicked(void* b, long callback_id) {
    if (chez_void_callback)
        qt_tool_button_on_clicked(b, chez_void_callback, callback_id);
}

/* Process */
void chez_qt_process_on_finished(void* p, long callback_id) {
    if (chez_int_callback)
        qt_process_on_finished(p, chez_int_callback, callback_id);
}
void chez_qt_process_on_ready_read(void* p, long callback_id) {
    if (chez_void_callback)
        qt_process_on_ready_read(p, chez_void_callback, callback_id);
}

/* Wizard */
void chez_qt_wizard_on_current_changed(void* w, long callback_id) {
    if (chez_int_callback)
        qt_wizard_on_current_changed(w, chez_int_callback, callback_id);
}

/* MDI Area */
void chez_qt_mdi_area_on_sub_window_activated(void* a, long callback_id) {
    if (chez_void_callback)
        qt_mdi_area_on_sub_window_activated(a, chez_void_callback, callback_id);
}

/* Dial */
void chez_qt_dial_on_value_changed(void* d, long callback_id) {
    if (chez_int_callback)
        qt_dial_on_value_changed(d, chez_int_callback, callback_id);
}

/* Tool Box */
void chez_qt_tool_box_on_current_changed(void* t, long callback_id) {
    if (chez_int_callback)
        qt_tool_box_on_current_changed(t, chez_int_callback, callback_id);
}

/* QScintilla (conditional) */
#ifdef QT_SCINTILLA_AVAILABLE
void chez_qt_scintilla_on_text_changed(void* s, long callback_id) {
    if (chez_void_callback)
        qt_scintilla_on_text_changed(s, chez_void_callback, callback_id);
}
void chez_qt_scintilla_on_char_added(void* s, long callback_id) {
    if (chez_int_callback)
        qt_scintilla_on_char_added(s, chez_int_callback, callback_id);
}
void chez_qt_scintilla_on_save_point_reached(void* s, long callback_id) {
    if (chez_void_callback)
        qt_scintilla_on_save_point_reached(s, chez_void_callback, callback_id);
}
void chez_qt_scintilla_on_save_point_left(void* s, long callback_id) {
    if (chez_void_callback)
        qt_scintilla_on_save_point_left(s, chez_void_callback, callback_id);
}
void chez_qt_scintilla_on_margin_clicked(void* s, long callback_id) {
    if (chez_int_callback)
        qt_scintilla_on_margin_clicked(s, chez_int_callback, callback_id);
}
void chez_qt_scintilla_on_modified(void* s, long callback_id) {
    if (chez_void_callback)
        qt_scintilla_on_modified(s, chez_void_callback, callback_id);
}
#endif
