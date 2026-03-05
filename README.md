# chez-qt

Qt6 Widgets bindings for Chez Scheme.

Build desktop GUI applications with native Qt6 widgets from Chez Scheme, using a thin C++ shim and Chez's FFI. API-compatible with [gerbil-qt](https://github.com/jafourni/gerbil-qt).

## Requirements

- [Chez Scheme](https://cisco.github.io/ChezScheme/) 10.0+
- Qt6 development libraries
- gcc
- The [gerbil-qt](https://github.com/jafourni/gerbil-qt) C++ shim (provides `vendor/qt_shim.h` and `vendor/libqt_shim.so`)

### Linux (Ubuntu/Debian)

```sh
sudo apt install qt6-base-dev libgl1-mesa-dev chezscheme
```

### Linux (Fedora)

```sh
sudo dnf install qt6-qtbase-devel chez-scheme
```

### macOS (Homebrew)

```sh
brew install qt@6 chezscheme
export PKG_CONFIG_PATH="$(brew --prefix qt@6)/lib/pkgconfig:$PKG_CONFIG_PATH"
```

## Build

First, build gerbil-qt to get the C++ shim:

```sh
cd ~/mine/gerbil-qt
make build
```

Then build chez-qt:

```sh
cd ~/mine/chez-qt
make
```

This compiles the Chez-specific callback bridge (`qt_chez_shim.so`) and the Scheme libraries (`chez-qt/ffi.so`, `chez-qt/qt.so`).

## Test

```sh
make test
```

Tests run headless using Qt's offscreen platform plugin (`QT_QPA_PLATFORM=offscreen`).

## Usage

```scheme
(import (chez-qt qt))

(define (main)
  (with-qt-app app
    (let* ((win (qt-main-window-create))
           (central (qt-widget-create))
           (layout (qt-vbox-layout-create central))
           (label (qt-label-create "Count: 0"))
           (button (qt-push-button-create "Click me!"))
           (count 0))
      (qt-layout-add-widget! layout label)
      (qt-layout-add-widget! layout button)
      (qt-on-clicked! button
        (lambda ()
          (set! count (+ count 1))
          (qt-label-set-text! label
            (string-append "Count: " (number->string count)))))
      (qt-main-window-set-central-widget! win central)
      (qt-main-window-set-title! win "Counter")
      (qt-widget-resize! win 300 200)
      (qt-widget-show! win)
      (qt-app-exec! app))))

(main)
```

### Running Examples

All examples are standalone Chez Scheme scripts. Run them with:

```sh
# Set up the library path (required for every invocation)
export LD_LIBRARY_PATH=~/mine/gerbil-qt/vendor:$LD_LIBRARY_PATH

# Run any example
scheme --libdirs ~/mine/chez-qt --script examples/hello.ss
scheme --libdirs ~/mine/chez-qt --script examples/counter.ss
scheme --libdirs ~/mine/chez-qt --script examples/form.ss
scheme --libdirs ~/mine/chez-qt --script examples/editor.ss
scheme --libdirs ~/mine/chez-qt --script examples/dashboard.ss
scheme --libdirs ~/mine/chez-qt --script examples/filebrowser.ss
scheme --libdirs ~/mine/chez-qt --script examples/styled.ss
scheme --libdirs ~/mine/chez-qt --script examples/settings.ss
scheme --libdirs ~/mine/chez-qt --script examples/painter.ss
scheme --libdirs ~/mine/chez-qt --script examples/datainput.ss
scheme --libdirs ~/mine/chez-qt --script examples/planner.ss
scheme --libdirs ~/mine/chez-qt --script examples/autocomplete.ss
scheme --libdirs ~/mine/chez-qt --script examples/modelviewer.ss
scheme --libdirs ~/mine/chez-qt --script examples/polished.ss
scheme --libdirs ~/mine/chez-qt --script examples/diagram.ss
scheme --libdirs ~/mine/chez-qt --script examples/terminal.ss
scheme --libdirs ~/mine/chez-qt --script examples/widgets.ss
scheme --libdirs ~/mine/chez-qt --script examples/filemanager.ss
scheme --libdirs ~/mine/chez-qt --script examples/wizard.ss
scheme --libdirs ~/mine/chez-qt --script examples/mdi.ss
scheme --libdirs ~/mine/chez-qt --script examples/dockable.ss
scheme --libdirs ~/mine/chez-qt --script examples/trayapp.ss
scheme --libdirs ~/mine/chez-qt --script examples/dragdrop.ss
scheme --libdirs ~/mine/chez-qt --script examples/keyboard.ss
scheme --libdirs ~/mine/chez-qt --script examples/dialogs.ss
scheme --libdirs ~/mine/chez-qt --script examples/richtext.ss
```

Or run headless (no display required):

```sh
QT_QPA_PLATFORM=offscreen scheme --libdirs ~/mine/chez-qt --script examples/hello.ss
```

### Using from the REPL

```sh
export LD_LIBRARY_PATH=~/mine/gerbil-qt/vendor:$LD_LIBRARY_PATH
scheme --libdirs ~/mine/chez-qt
```

```scheme
> (import (chez-qt qt))
> (define app (qt-app-create))
> (define win (qt-main-window-create))
> (qt-main-window-set-title! win "REPL Window")
> (qt-widget-resize! win 400 300)
> (qt-widget-show! win)
> (qt-app-exec! app)
```

## Differences from gerbil-qt

| Aspect | gerbil-qt | chez-qt |
|--------|-----------|---------|
| Import | `(import :gerbil-qt/qt)` | `(import (chez-qt qt))` |
| Define | `(def (name args) ...)` | `(define (name args) ...)` |
| Main | `(def (main) ...)` in build target | `(define (main) ...) (main)` at end of script |
| Keyword args | `parent: #f` | Not supported; positional or omitted |
| Build | `gerbil build` | `make` |
| Run examples | `make demo-hello` | `scheme --libdirs . --script examples/hello.ss` |
| FFI mechanism | Gambit `c-define` (compile-time) | Chez `foreign-callable` (runtime) |

The high-level API (`qt-*` functions) is identical between both projects. Code that uses only the `(chez-qt qt)` / `:gerbil-qt/qt` API can be ported by changing the import line and using `define` instead of `def`.

## API Reference

### Application Lifecycle

| Function | Description |
|----------|-------------|
| `(qt-app-create)` | Create QApplication |
| `(qt-app-exec! app)` | Run the event loop |
| `(qt-app-quit! app)` | Quit the event loop |
| `(qt-app-process-events! app)` | Process pending events (cooperative polling) |
| `(qt-app-destroy! app)` | Destroy application |
| `(with-qt-app app body ...)` | Macro: create app, run body, destroy on exit |

### Widget Base

All widget types support these operations:

| Function | Description |
|----------|-------------|
| `(qt-widget-create)` | Create a generic widget |
| `(qt-widget-show! w)` | Show widget |
| `(qt-widget-hide! w)` | Hide widget |
| `(qt-widget-close! w)` | Close widget |
| `(qt-widget-set-enabled! w bool)` | Enable/disable |
| `(qt-widget-enabled? w)` | Check if enabled |
| `(qt-widget-set-visible! w bool)` | Set visibility |
| `(qt-widget-visible? w)` | Check if visible |
| `(qt-widget-resize! w width height)` | Resize |
| `(qt-widget-set-fixed-size! w width height)` | Set fixed size |
| `(qt-widget-set-minimum-size! w width height)` | Set minimum size |
| `(qt-widget-set-maximum-size! w width height)` | Set maximum size |
| `(qt-widget-set-minimum-width! w pixels)` | Set minimum width |
| `(qt-widget-set-minimum-height! w pixels)` | Set minimum height |
| `(qt-widget-set-maximum-width! w pixels)` | Set maximum width |
| `(qt-widget-set-maximum-height! w pixels)` | Set maximum height |
| `(qt-widget-set-cursor! w cursor)` | Set cursor shape (use `QT_CURSOR_*` constants) |
| `(qt-widget-unset-cursor! w)` | Reset cursor to default |
| `(qt-widget-set-style-sheet! w css)` | Apply CSS stylesheet |
| `(qt-widget-set-tooltip! w text)` | Set tooltip text |
| `(qt-widget-set-font-size! w size)` | Set font point size |
| `(qt-widget-destroy! w)` | Destroy widget |

### Main Window

| Function | Description |
|----------|-------------|
| `(qt-main-window-create)` | Create main window |
| `(qt-main-window-set-title! w title)` | Set window title |
| `(qt-main-window-set-central-widget! w child)` | Set central widget |

### Layouts

| Function | Description |
|----------|-------------|
| `(qt-vbox-layout-create parent)` | Vertical box layout |
| `(qt-hbox-layout-create parent)` | Horizontal box layout |
| `(qt-layout-add-widget! layout widget)` | Add widget to layout |
| `(qt-layout-add-stretch! layout)` | Add stretch spacer |
| `(qt-layout-set-spacing! layout spacing)` | Set item spacing |
| `(qt-layout-set-margins! layout l t r b)` | Set content margins |
| `(qt-layout-add-spacing! layout pixels)` | Add fixed pixel spacing |
| `(qt-layout-set-stretch-factor! layout widget stretch)` | Set relative stretch factor |

### Labels

| Function | Description |
|----------|-------------|
| `(qt-label-create text)` | Create label |
| `(qt-label-text l)` | Get text |
| `(qt-label-set-text! l text)` | Set text |
| `(qt-label-set-alignment! l alignment)` | Set alignment (use `QT_ALIGN_*` constants) |
| `(qt-label-set-word-wrap! l bool)` | Enable/disable word wrap |

### Push Button

| Function | Description |
|----------|-------------|
| `(qt-push-button-create text)` | Create button |
| `(qt-push-button-text b)` | Get button text |
| `(qt-push-button-set-text! b text)` | Set button text |
| `(qt-on-clicked! button handler)` | Connect clicked signal: `(lambda () ...)` |

### Line Edit

| Function | Description |
|----------|-------------|
| `(qt-line-edit-create)` | Create single-line text input |
| `(qt-line-edit-text e)` | Get text |
| `(qt-line-edit-set-text! e text)` | Set text |
| `(qt-line-edit-set-placeholder! e text)` | Set placeholder text |
| `(qt-line-edit-set-read-only! e bool)` | Set read-only |
| `(qt-line-edit-set-echo-mode! e mode)` | Set echo mode (use `QT_ECHO_*` constants) |
| `(qt-on-text-changed! e handler)` | Connect textChanged: `(lambda (text) ...)` |
| `(qt-on-return-pressed! e handler)` | Connect returnPressed: `(lambda () ...)` |

### Check Box

| Function | Description |
|----------|-------------|
| `(qt-check-box-create text)` | Create checkbox |
| `(qt-check-box-checked? c)` | Is checked? |
| `(qt-check-box-set-checked! c bool)` | Set checked state |
| `(qt-check-box-set-text! c text)` | Set label text |
| `(qt-on-toggled! c handler)` | Connect toggled: `(lambda (checked?) ...)` |

### Combo Box

| Function | Description |
|----------|-------------|
| `(qt-combo-box-create)` | Create dropdown |
| `(qt-combo-box-add-item! c text)` | Add item |
| `(qt-combo-box-set-current-index! c index)` | Set selection |
| `(qt-combo-box-current-index c)` | Get selected index |
| `(qt-combo-box-current-text c)` | Get selected text |
| `(qt-combo-box-count c)` | Get item count |
| `(qt-combo-box-clear! c)` | Remove all items |
| `(qt-on-index-changed! c handler)` | Connect indexChanged: `(lambda (index) ...)` |

### Text Edit

| Function | Description |
|----------|-------------|
| `(qt-text-edit-create)` | Create multi-line text editor |
| `(qt-text-edit-text e)` | Get plain text |
| `(qt-text-edit-set-text! e text)` | Set text |
| `(qt-text-edit-set-placeholder! e text)` | Set placeholder |
| `(qt-text-edit-set-read-only! e bool)` | Set read-only |
| `(qt-text-edit-append! e text)` | Append text |
| `(qt-text-edit-clear! e)` | Clear all text |
| `(qt-text-edit-scroll-to-bottom! e)` | Scroll to bottom |
| `(qt-text-edit-html e)` | Get HTML content |
| `(qt-on-text-edit-changed! e handler)` | Connect textChanged: `(lambda () ...)` |

### Spin Box

| Function | Description |
|----------|-------------|
| `(qt-spin-box-create)` | Create integer spinner |
| `(qt-spin-box-value s)` | Get value |
| `(qt-spin-box-set-value! s value)` | Set value |
| `(qt-spin-box-set-range! s min max)` | Set min/max range |
| `(qt-spin-box-set-single-step! s step)` | Set step increment |
| `(qt-spin-box-set-prefix! s prefix)` | Set display prefix |
| `(qt-spin-box-set-suffix! s suffix)` | Set display suffix |
| `(qt-on-value-changed! s handler)` | Connect valueChanged: `(lambda (value) ...)` |

### Dialog

| Function | Description |
|----------|-------------|
| `(qt-dialog-create)` | Create dialog window |
| `(qt-dialog-exec! d)` | Run modal dialog |
| `(qt-dialog-accept! d)` | Accept and close |
| `(qt-dialog-reject! d)` | Reject and close |
| `(qt-dialog-set-title! d title)` | Set dialog title |

### Message Box

| Function | Description |
|----------|-------------|
| `(qt-message-box-information parent title text)` | Show info dialog |
| `(qt-message-box-warning parent title text)` | Show warning dialog |
| `(qt-message-box-question parent title text)` | Show yes/no dialog, returns boolean |
| `(qt-message-box-critical parent title text)` | Show error dialog |

Pass `0` for `parent` if none.

### File Dialog

| Function | Description |
|----------|-------------|
| `(qt-file-dialog-open-file parent caption dir filter)` | Open file picker, returns path or `""` |
| `(qt-file-dialog-save-file parent caption dir filter)` | Save file picker, returns path or `""` |
| `(qt-file-dialog-open-directory parent caption dir)` | Directory picker, returns path or `""` |

### Menu Bar

| Function | Description |
|----------|-------------|
| `(qt-main-window-menu-bar win)` | Get menu bar from main window |

### Menu

| Function | Description |
|----------|-------------|
| `(qt-menu-bar-add-menu bar title)` | Add menu to menu bar |
| `(qt-menu-add-menu menu title)` | Add submenu |
| `(qt-menu-add-action! menu action)` | Add action to menu |
| `(qt-menu-add-separator! menu)` | Add separator |

### Action

| Function | Description |
|----------|-------------|
| `(qt-action-create text)` | Create action |
| `(qt-action-text a)` | Get text |
| `(qt-action-set-text! a text)` | Set text |
| `(qt-action-set-shortcut! a key-sequence)` | Set keyboard shortcut (e.g. `"Ctrl+S"`) |
| `(qt-action-set-enabled! a bool)` | Enable/disable |
| `(qt-action-enabled? a)` | Is enabled? |
| `(qt-action-set-checkable! a bool)` | Make checkable |
| `(qt-action-checkable? a)` | Is checkable? |
| `(qt-action-set-checked! a bool)` | Set checked state |
| `(qt-action-checked? a)` | Is checked? |
| `(qt-action-set-tooltip! a text)` | Set tooltip |
| `(qt-action-set-status-tip! a text)` | Set status bar tip |
| `(qt-on-triggered! a handler)` | Connect triggered: `(lambda () ...)` |
| `(qt-on-action-toggled! a handler)` | Connect toggled: `(lambda (checked?) ...)` |

### Toolbar

| Function | Description |
|----------|-------------|
| `(qt-toolbar-create title)` | Create toolbar |
| `(qt-main-window-add-toolbar! win toolbar)` | Add toolbar to main window |
| `(qt-toolbar-add-action! toolbar action)` | Add action to toolbar |
| `(qt-toolbar-add-separator! toolbar)` | Add separator |
| `(qt-toolbar-add-widget! toolbar widget)` | Add widget to toolbar |
| `(qt-toolbar-set-movable! toolbar bool)` | Set movable |
| `(qt-toolbar-set-icon-size! toolbar w h)` | Set icon size |

### Status Bar

| Function | Description |
|----------|-------------|
| `(qt-main-window-set-status-bar-text! win text)` | Set status bar message |

### Grid Layout

| Function | Description |
|----------|-------------|
| `(qt-grid-layout-create parent)` | Create grid layout |
| `(qt-grid-layout-add-widget! grid widget row col)` | Add widget at position |
| `(qt-grid-layout-set-row-stretch! grid row stretch)` | Set row stretch factor |
| `(qt-grid-layout-set-column-stretch! grid col stretch)` | Set column stretch factor |
| `(qt-grid-layout-set-row-minimum-height! grid row height)` | Set row minimum height |
| `(qt-grid-layout-set-column-minimum-width! grid col width)` | Set column minimum width |

### Timer

| Function | Description |
|----------|-------------|
| `(qt-timer-create)` | Create timer |
| `(qt-timer-start! t msec)` | Start with interval |
| `(qt-timer-stop! t)` | Stop timer |
| `(qt-timer-set-single-shot! t bool)` | Set single-shot mode |
| `(qt-timer-active? t)` | Is running? |
| `(qt-timer-interval t)` | Get interval |
| `(qt-timer-set-interval! t msec)` | Set interval |
| `(qt-on-timeout! t handler)` | Connect timeout: `(lambda () ...)` |
| `(qt-timer-single-shot! msec handler)` | One-shot timer (static convenience) |
| `(qt-timer-destroy! t)` | Destroy timer |

### Clipboard

| Function | Description |
|----------|-------------|
| `(qt-clipboard-text app)` | Get clipboard text |
| `(qt-clipboard-set-text! app text)` | Set clipboard text |
| `(qt-on-clipboard-changed! app handler)` | Connect dataChanged: `(lambda () ...)` |

The clipboard is a singleton owned by QApplication -- never destroy it.

### Tree Widget

| Function | Description |
|----------|-------------|
| `(qt-tree-widget-create)` | Create tree widget |
| `(qt-tree-widget-set-column-count! t count)` | Set number of columns |
| `(qt-tree-widget-column-count t)` | Get column count |
| `(qt-tree-widget-set-header-label! t label)` | Set single header label |
| `(qt-tree-widget-set-header-item-text! t col text)` | Set individual header text |
| `(qt-tree-widget-add-top-level-item! t item)` | Add top-level item |
| `(qt-tree-widget-top-level-item-count t)` | Count top-level items |
| `(qt-tree-widget-top-level-item t index)` | Get top-level item by index |
| `(qt-tree-widget-current-item t)` | Get selected item (or `#f`) |
| `(qt-tree-widget-set-current-item! t item)` | Set selected item |
| `(qt-tree-widget-expand-item! t item)` | Expand item |
| `(qt-tree-widget-collapse-item! t item)` | Collapse item |
| `(qt-tree-widget-expand-all! t)` | Expand all |
| `(qt-tree-widget-collapse-all! t)` | Collapse all |
| `(qt-tree-widget-clear! t)` | Remove all items |
| `(qt-on-current-item-changed! t handler)` | `(lambda () ...)` |
| `(qt-on-tree-item-double-clicked! t handler)` | `(lambda () ...)` |
| `(qt-on-item-expanded! t handler)` | `(lambda () ...)` |
| `(qt-on-item-collapsed! t handler)` | `(lambda () ...)` |

### Tree Widget Item

| Function | Description |
|----------|-------------|
| `(qt-tree-item-create text)` | Create tree item |
| `(qt-tree-item-set-text! item col text)` | Set text at column |
| `(qt-tree-item-text item col)` | Get text at column |
| `(qt-tree-item-add-child! parent child)` | Add child item |
| `(qt-tree-item-child-count item)` | Get child count |
| `(qt-tree-item-child item index)` | Get child by index |
| `(qt-tree-item-parent item)` | Get parent item |
| `(qt-tree-item-set-expanded! item bool)` | Set expanded state |
| `(qt-tree-item-expanded? item)` | Is expanded? |

### List Widget

| Function | Description |
|----------|-------------|
| `(qt-list-widget-create)` | Create list widget |
| `(qt-list-widget-add-item! l text)` | Add item |
| `(qt-list-widget-insert-item! l row text)` | Insert at position |
| `(qt-list-widget-remove-item! l row)` | Remove by position |
| `(qt-list-widget-current-row l)` | Get selected row |
| `(qt-list-widget-set-current-row! l row)` | Set selected row |
| `(qt-list-widget-item-text l row)` | Get item text |
| `(qt-list-widget-count l)` | Get item count |
| `(qt-list-widget-clear! l)` | Remove all items |
| `(qt-list-widget-set-item-data! l row data)` | Set hidden data string |
| `(qt-list-widget-item-data l row)` | Get hidden data string |
| `(qt-on-current-row-changed! l handler)` | `(lambda (row) ...)` |
| `(qt-on-item-double-clicked! l handler)` | `(lambda (row) ...)` |

### Table Widget

| Function | Description |
|----------|-------------|
| `(qt-table-widget-create rows cols)` | Create table widget |
| `(qt-table-widget-set-item! t row col text)` | Set cell text |
| `(qt-table-widget-item-text t row col)` | Get cell text |
| `(qt-table-widget-set-horizontal-header! t col text)` | Set column header |
| `(qt-table-widget-set-vertical-header! t row text)` | Set row header |
| `(qt-table-widget-set-row-count! t count)` | Set row count |
| `(qt-table-widget-set-column-count! t count)` | Set column count |
| `(qt-table-widget-row-count t)` | Get row count |
| `(qt-table-widget-column-count t)` | Get column count |
| `(qt-table-widget-current-row t)` | Get current row |
| `(qt-table-widget-current-column t)` | Get current column |
| `(qt-table-widget-clear! t)` | Clear all cells |
| `(qt-on-cell-clicked! t handler)` | `(lambda () ...)` |

### Tab Widget

| Function | Description |
|----------|-------------|
| `(qt-tab-widget-create)` | Create tab widget |
| `(qt-tab-widget-add-tab! tw page title)` | Add tab page |
| `(qt-tab-widget-set-current-index! tw index)` | Set active tab |
| `(qt-tab-widget-current-index tw)` | Get active tab index |
| `(qt-tab-widget-count tw)` | Get tab count |
| `(qt-tab-widget-set-tab-text! tw index text)` | Change tab label |
| `(qt-on-tab-changed! tw handler)` | `(lambda (index) ...)` |

### Progress Bar

| Function | Description |
|----------|-------------|
| `(qt-progress-bar-create)` | Create progress bar |
| `(qt-progress-bar-set-value! p value)` | Set current value |
| `(qt-progress-bar-value p)` | Get current value |
| `(qt-progress-bar-set-range! p min max)` | Set value range |
| `(qt-progress-bar-set-format! p fmt)` | Set display format (e.g. `"%p%"`) |

### Slider

| Function | Description |
|----------|-------------|
| `(qt-slider-create orientation)` | Create slider (`QT_HORIZONTAL` / `QT_VERTICAL`) |
| `(qt-slider-set-value! s value)` | Set value |
| `(qt-slider-value s)` | Get value |
| `(qt-slider-set-range! s min max)` | Set range |
| `(qt-slider-set-single-step! s step)` | Set step |
| `(qt-slider-set-tick-interval! s interval)` | Set tick spacing |
| `(qt-slider-set-tick-position! s position)` | Set tick position (use `QT_TICKS_*` constants) |
| `(qt-on-slider-value-changed! s handler)` | `(lambda (value) ...)` |

### Window State

| Function | Description |
|----------|-------------|
| `(qt-widget-show-minimized! w)` | Minimize |
| `(qt-widget-show-maximized! w)` | Maximize |
| `(qt-widget-show-fullscreen! w)` | Fullscreen |
| `(qt-widget-show-normal! w)` | Normal |
| `(qt-widget-window-state w)` | Get state constant |
| `(qt-widget-move! w x y)` | Move window |
| `(qt-widget-x w)` | Get X position |
| `(qt-widget-y w)` | Get Y position |
| `(qt-widget-width w)` | Get width |
| `(qt-widget-height w)` | Get height |
| `(qt-widget-set-focus! w)` | Set keyboard focus |

### App-wide Style Sheet

| Function | Description |
|----------|-------------|
| `(qt-app-set-style-sheet! app css)` | Apply CSS to entire application |

### Scroll Area

| Function | Description |
|----------|-------------|
| `(qt-scroll-area-create)` | Create scroll area |
| `(qt-scroll-area-set-widget! sa widget)` | Set scrollable content |
| `(qt-scroll-area-set-widget-resizable! sa bool)` | Allow content to resize |
| `(qt-scroll-area-set-horizontal-scrollbar-policy! sa policy)` | Set horizontal scrollbar |
| `(qt-scroll-area-set-vertical-scrollbar-policy! sa policy)` | Set vertical scrollbar |

### Splitter

| Function | Description |
|----------|-------------|
| `(qt-splitter-create orientation)` | Create splitter (`QT_HORIZONTAL` / `QT_VERTICAL`) |
| `(qt-splitter-add-widget! sp widget)` | Add widget |
| `(qt-splitter-insert-widget! sp index widget)` | Insert at position |
| `(qt-splitter-count sp)` | Get widget count |
| `(qt-splitter-set-handle-width! sp pixels)` | Set handle width |
| `(qt-splitter-set-collapsible! sp index bool)` | Set collapsible |
| `(qt-splitter-collapsible? sp index)` | Is collapsible? |
| `(qt-splitter-set-orientation! sp orientation)` | Change orientation |

### Keyboard Events

| Function | Description |
|----------|-------------|
| `(qt-on-key-press! w handler)` | Key press: `(lambda () ...)`, then query key info |
| `(qt-on-key-press-consuming! w handler)` | Same but consumes the event |
| `(qt-last-key-code)` | Get last key code (use `QT_KEY_*` constants) |
| `(qt-last-key-modifiers)` | Get modifier flags (use `QT_MOD_*` constants) |
| `(qt-last-key-text)` | Get key text |

### Pixmap

| Function | Description |
|----------|-------------|
| `(qt-pixmap-load path)` | Load image from file |
| `(qt-pixmap-create-blank w h)` | Create blank pixmap |
| `(qt-pixmap-width pm)` | Get width |
| `(qt-pixmap-height pm)` | Get height |
| `(qt-pixmap-null? pm)` | Is empty? |
| `(qt-pixmap-scaled pm w h)` | Scale pixmap, returns new pixmap |
| `(qt-pixmap-fill! pm r g b a)` | Fill with color |
| `(qt-pixmap-destroy! pm)` | Destroy pixmap |
| `(qt-label-set-pixmap! label pm)` | Display pixmap in label |

### Icon

| Function | Description |
|----------|-------------|
| `(qt-icon-create path)` | Create icon from file |
| `(qt-icon-create-from-pixmap pm)` | Create icon from pixmap |
| `(qt-icon-null? icon)` | Is empty? |
| `(qt-icon-destroy! icon)` | Destroy icon |
| `(qt-push-button-set-icon! button icon)` | Set button icon |
| `(qt-action-set-icon! action icon)` | Set action icon |
| `(qt-widget-set-window-icon! w icon)` | Set window icon |

### Radio Button

| Function | Description |
|----------|-------------|
| `(qt-radio-button-create text)` | Create radio button |
| `(qt-radio-button-text r)` | Get text |
| `(qt-radio-button-set-text! r text)` | Set text |
| `(qt-radio-button-checked? r)` | Is checked? |
| `(qt-radio-button-set-checked! r bool)` | Set checked state |
| `(qt-on-radio-toggled! r handler)` | `(lambda (checked?) ...)` |

### Button Group

| Function | Description |
|----------|-------------|
| `(qt-button-group-create)` | Create button group |
| `(qt-button-group-add-button! bg button id)` | Add button with ID |
| `(qt-button-group-remove-button! bg button)` | Remove button |
| `(qt-button-group-checked-id bg)` | Get checked button ID |
| `(qt-button-group-set-exclusive! bg bool)` | Set exclusive mode |
| `(qt-button-group-exclusive? bg)` | Is exclusive? |
| `(qt-on-button-group-clicked! bg handler)` | `(lambda (id) ...)` |
| `(qt-button-group-destroy! bg)` | Destroy group |

### Group Box

| Function | Description |
|----------|-------------|
| `(qt-group-box-create title)` | Create group box |
| `(qt-group-box-title gb)` | Get title |
| `(qt-group-box-set-title! gb title)` | Set title |
| `(qt-group-box-set-checkable! gb bool)` | Make checkable |
| `(qt-group-box-checkable? gb)` | Is checkable? |
| `(qt-group-box-set-checked! gb bool)` | Set checked state |
| `(qt-group-box-checked? gb)` | Is checked? |
| `(qt-on-group-box-toggled! gb handler)` | `(lambda (checked?) ...)` |

### QFont

| Function | Description |
|----------|-------------|
| `(qt-font-create family point-size)` | Create font |
| `(qt-font-family f)` | Get font family name |
| `(qt-font-point-size f)` | Get point size |
| `(qt-font-bold? f)` | Check if bold |
| `(qt-font-set-bold! f bool)` | Set bold |
| `(qt-font-italic? f)` | Check if italic |
| `(qt-font-set-italic! f bool)` | Set italic |
| `(qt-font-destroy! f)` | Destroy font |
| `(qt-widget-set-font! w f)` | Set font on any widget |
| `(qt-widget-font w)` | Get widget's font (new copy -- caller must destroy) |

### QColor

| Function | Description |
|----------|-------------|
| `(qt-color-create r g b a)` | Create from RGBA (0-255) |
| `(qt-color-create-name name)` | Create from `"#rrggbb"` or named color |
| `(qt-color-red c)` | Red channel |
| `(qt-color-green c)` | Green channel |
| `(qt-color-blue c)` | Blue channel |
| `(qt-color-alpha c)` | Alpha channel |
| `(qt-color-name c)` | Hex string `"#rrggbb"` |
| `(qt-color-valid? c)` | Is color valid? |
| `(qt-color-destroy! c)` | Destroy color |

### QFontDialog / QColorDialog

| Function | Description |
|----------|-------------|
| `(qt-font-dialog-get-font)` | Show font picker, returns QFont or `#f` |
| `(qt-color-dialog-get-color)` | Show color picker, returns QColor or `#f` |

### Stacked Widget

| Function | Description |
|----------|-------------|
| `(qt-stacked-widget-create)` | Create stacked widget |
| `(qt-stacked-widget-add-widget! sw widget)` | Add page |
| `(qt-stacked-widget-set-current-index! sw index)` | Set visible page |
| `(qt-stacked-widget-current-index sw)` | Get visible page index |
| `(qt-stacked-widget-count sw)` | Get page count |
| `(qt-on-stacked-current-changed! sw handler)` | `(lambda (index) ...)` |

### Dock Widget

| Function | Description |
|----------|-------------|
| `(qt-dock-widget-create title)` | Create dock widget |
| `(qt-dock-widget-set-widget! dock widget)` | Set dock content |
| `(qt-dock-widget-widget dock)` | Get dock content |
| `(qt-dock-widget-set-title! dock title)` | Set dock title |
| `(qt-dock-widget-title dock)` | Get dock title |
| `(qt-dock-widget-set-floating! dock bool)` | Set floating state |
| `(qt-dock-widget-floating? dock)` | Is floating? |
| `(qt-main-window-add-dock-widget! win area dock)` | Add to main window (use `QT_DOCK_*` constants) |

### System Tray Icon

| Function | Description |
|----------|-------------|
| `(qt-system-tray-icon-create)` | Create tray icon |
| `(qt-system-tray-icon-set-tooltip! tray text)` | Set tooltip |
| `(qt-system-tray-icon-set-icon! tray icon)` | Set tray icon |
| `(qt-system-tray-icon-show! tray)` | Show in tray |
| `(qt-system-tray-icon-hide! tray)` | Hide from tray |
| `(qt-system-tray-icon-show-message! tray title msg icon-type msec)` | Show notification |
| `(qt-system-tray-icon-set-context-menu! tray menu)` | Set right-click menu |
| `(qt-on-tray-activated! tray handler)` | `(lambda (reason) ...)` |
| `(qt-system-tray-icon-available?)` | Is system tray available? |
| `(qt-system-tray-icon-destroy! tray)` | Destroy tray icon |

### QPainter

| Function | Description |
|----------|-------------|
| `(qt-painter-create target)` | Create painter on pixmap or paint widget |
| `(qt-painter-end! p)` | End painting |
| `(qt-painter-destroy! p)` | Destroy painter |
| `(qt-painter-set-pen-color! p r g b)` | Set pen color |
| `(qt-painter-set-pen-width! p width)` | Set pen width |
| `(qt-painter-set-brush-color! p r g b)` | Set fill color |
| `(qt-painter-set-font! p font)` | Set text font |
| `(qt-painter-set-antialiasing! p bool)` | Enable antialiasing |
| `(qt-painter-draw-line! p x1 y1 x2 y2)` | Draw line |
| `(qt-painter-draw-rect! p x y w h)` | Draw rectangle |
| `(qt-painter-fill-rect! p x y w h)` | Fill rectangle |
| `(qt-painter-draw-ellipse! p x y w h)` | Draw ellipse |
| `(qt-painter-draw-text! p x y text)` | Draw text at point |
| `(qt-painter-draw-text-rect! p x y w h flags text)` | Draw text in rectangle |
| `(qt-painter-draw-pixmap! p x y pixmap)` | Draw pixmap |
| `(qt-painter-draw-point! p x y)` | Draw point |
| `(qt-painter-draw-arc! p x y w h start-angle span-angle)` | Draw arc |
| `(qt-painter-save! p)` | Save painter state |
| `(qt-painter-restore! p)` | Restore painter state |
| `(qt-painter-translate! p dx dy)` | Translate origin |
| `(qt-painter-rotate! p angle)` | Rotate (degrees) |
| `(qt-painter-scale! p sx sy)` | Scale |
| `(with-painter (p target) body ...)` | Macro: create, paint, auto end+destroy |

### Drag and Drop

| Function | Description |
|----------|-------------|
| `(qt-widget-set-accept-drops! w bool)` | Enable drop target |
| `(qt-drop-filter-install! w)` | Install drop event filter |
| `(qt-drop-filter-last-text)` | Get last dropped text |
| `(qt-drop-filter-destroy! filter)` | Destroy drop filter |
| `(qt-drag-text! source text)` | Initiate text drag |

### Double Spin Box

| Function | Description |
|----------|-------------|
| `(qt-double-spin-box-create)` | Create decimal spinner |
| `(qt-double-spin-box-set-value! s value)` | Set value |
| `(qt-double-spin-box-value s)` | Get value |
| `(qt-double-spin-box-set-range! s min max)` | Set range |
| `(qt-double-spin-box-set-single-step! s step)` | Set step |
| `(qt-double-spin-box-set-decimals! s n)` | Set decimal places |
| `(qt-double-spin-box-decimals s)` | Get decimal places |
| `(qt-double-spin-box-set-prefix! s prefix)` | Set prefix |
| `(qt-double-spin-box-set-suffix! s suffix)` | Set suffix |
| `(qt-on-double-spin-value-changed! s handler)` | `(lambda (value) ...)` |

### Date Edit

| Function | Description |
|----------|-------------|
| `(qt-date-edit-create)` | Create date picker |
| `(qt-date-edit-set-date! d year month day)` | Set date |
| `(qt-date-edit-year d)` | Get year |
| `(qt-date-edit-month d)` | Get month |
| `(qt-date-edit-day d)` | Get day |
| `(qt-date-edit-date-string d)` | Get ISO date string |
| `(qt-date-edit-set-minimum-date! d year month day)` | Set minimum |
| `(qt-date-edit-set-maximum-date! d year month day)` | Set maximum |
| `(qt-date-edit-set-calendar-popup! d bool)` | Enable calendar popup |
| `(qt-date-edit-set-display-format! d format)` | Set display format |
| `(qt-on-date-changed! d handler)` | `(lambda () ...)` |

### Time Edit

| Function | Description |
|----------|-------------|
| `(qt-time-edit-create)` | Create time picker |
| `(qt-time-edit-set-time! t hour minute second)` | Set time |
| `(qt-time-edit-hour t)` | Get hour |
| `(qt-time-edit-minute t)` | Get minute |
| `(qt-time-edit-second t)` | Get second |
| `(qt-time-edit-time-string t)` | Get time string |
| `(qt-time-edit-set-display-format! t format)` | Set display format |
| `(qt-on-time-changed! t handler)` | `(lambda () ...)` |

### Frame

| Function | Description |
|----------|-------------|
| `(qt-frame-create)` | Create frame |
| `(qt-frame-set-frame-shape! f shape)` | Set shape (use `QT_FRAME_*` constants) |
| `(qt-frame-frame-shape f)` | Get shape |
| `(qt-frame-set-frame-shadow! f shadow)` | Set shadow |
| `(qt-frame-frame-shadow f)` | Get shadow |
| `(qt-frame-set-line-width! f width)` | Set line width |
| `(qt-frame-line-width f)` | Get line width |
| `(qt-frame-set-mid-line-width! f width)` | Set mid-line width |

### Progress Dialog

| Function | Description |
|----------|-------------|
| `(qt-progress-dialog-create title cancel-text min max)` | Create progress dialog |
| `(qt-progress-dialog-set-value! d value)` | Set progress |
| `(qt-progress-dialog-value d)` | Get progress |
| `(qt-progress-dialog-set-range! d min max)` | Set range |
| `(qt-progress-dialog-set-label-text! d text)` | Set label |
| `(qt-progress-dialog-was-canceled? d)` | Was cancelled? |
| `(qt-progress-dialog-set-minimum-duration! d msec)` | Set delay before showing |
| `(qt-progress-dialog-set-auto-close! d bool)` | Auto close on completion |
| `(qt-progress-dialog-set-auto-reset! d bool)` | Auto reset on completion |
| `(qt-progress-dialog-reset! d)` | Reset dialog |
| `(qt-on-progress-canceled! d handler)` | `(lambda () ...)` |

### Input Dialog

| Function | Description |
|----------|-------------|
| `(qt-input-dialog-get-text title label default)` | Get text from user; returns string or `""` |
| `(qt-input-dialog-get-int title label value min max step)` | Get integer |
| `(qt-input-dialog-get-double title label value min max decimals)` | Get double |
| `(qt-input-dialog-get-item title label items current editable)` | Choose from list |
| `(qt-input-dialog-was-accepted?)` | Was last dialog accepted? |

### Form Layout

| Function | Description |
|----------|-------------|
| `(qt-form-layout-create parent)` | Create form layout (label:field rows) |
| `(qt-form-layout-add-row! form label widget)` | Add labeled row |
| `(qt-form-layout-add-row-widget! form widget)` | Add spanning row |
| `(qt-form-layout-add-spanning-widget! form widget)` | Add spanning widget |
| `(qt-form-layout-row-count form)` | Get number of rows |

### Shortcut

| Function | Description |
|----------|-------------|
| `(qt-shortcut-create key-sequence parent)` | Create shortcut (e.g. `"Ctrl+S"`) |
| `(qt-shortcut-set-key! sc key-sequence)` | Change key sequence |
| `(qt-shortcut-set-enabled! sc bool)` | Enable/disable |
| `(qt-shortcut-enabled? sc)` | Is enabled? |
| `(qt-on-shortcut-activated! sc handler)` | `(lambda () ...)` |
| `(qt-shortcut-destroy! sc)` | Destroy shortcut |

### Calendar

| Function | Description |
|----------|-------------|
| `(qt-calendar-create)` | Create calendar widget |
| `(qt-calendar-set-selected-date! cal year month day)` | Set selected date |
| `(qt-calendar-selected-year cal)` | Get year |
| `(qt-calendar-selected-month cal)` | Get month (1-12) |
| `(qt-calendar-selected-day cal)` | Get day (1-31) |
| `(qt-calendar-selected-date-string cal)` | Get ISO date string |
| `(qt-calendar-set-minimum-date! cal year month day)` | Set minimum date |
| `(qt-calendar-set-maximum-date! cal year month day)` | Set maximum date |
| `(qt-calendar-set-first-day-of-week! cal day)` | Set first day (use `QT_MONDAY`..`QT_SUNDAY`) |
| `(qt-calendar-set-grid-visible! cal bool)` | Show/hide grid |
| `(qt-calendar-grid-visible? cal)` | Is grid visible? |
| `(qt-calendar-set-navigation-bar-visible! cal bool)` | Show/hide navigation |
| `(qt-on-calendar-selection-changed! cal handler)` | `(lambda () ...)` |
| `(qt-on-calendar-clicked! cal handler)` | `(lambda (iso-date) ...)` |

### Text Browser

| Function | Description |
|----------|-------------|
| `(qt-text-browser-create)` | Create rich text/HTML viewer |
| `(qt-text-browser-set-html! tb html)` | Set HTML content |
| `(qt-text-browser-set-plain-text! tb text)` | Set plain text |
| `(qt-text-browser-plain-text tb)` | Get plain text |
| `(qt-text-browser-set-open-external-links! tb bool)` | Enable browser launch on click |
| `(qt-text-browser-set-source! tb url)` | Load content from URL/file |
| `(qt-text-browser-source tb)` | Get current source URL |
| `(qt-text-browser-scroll-to-bottom! tb)` | Scroll to bottom |
| `(qt-text-browser-append! tb text)` | Append text |
| `(qt-text-browser-html tb)` | Get HTML content |
| `(qt-on-anchor-clicked! tb handler)` | Link clicked: `(lambda (url) ...)` |

### Dialog Button Box

| Function | Description |
|----------|-------------|
| `(qt-button-box-create flags)` | Create with standard button flags (`bitwise-ior`) |
| `(qt-button-box-button bb role)` | Get button by standard constant |
| `(qt-button-box-add-button! bb text role)` | Add custom button |
| `(qt-on-button-box-accepted! bb handler)` | `(lambda () ...)` |
| `(qt-on-button-box-rejected! bb handler)` | `(lambda () ...)` |
| `(qt-on-button-box-clicked! bb handler)` | `(lambda () ...)` |

**Standard buttons:** `QT_BUTTON_OK`, `QT_BUTTON_CANCEL`, `QT_BUTTON_APPLY`, `QT_BUTTON_CLOSE`, `QT_BUTTON_YES`, `QT_BUTTON_NO`, `QT_BUTTON_RESET`, `QT_BUTTON_HELP`, `QT_BUTTON_SAVE`, `QT_BUTTON_DISCARD`

### QSettings

| Function | Description |
|----------|-------------|
| `(qt-settings-create org app)` | Create settings for org/app |
| `(qt-settings-create-file path format)` | Create file-backed settings |
| `(qt-settings-set-string! s key value)` | Store string |
| `(qt-settings-value-string s key default)` | Read string |
| `(qt-settings-set-int! s key value)` | Store integer |
| `(qt-settings-value-int s key default)` | Read integer |
| `(qt-settings-set-double! s key value)` | Store double |
| `(qt-settings-value-double s key default)` | Read double |
| `(qt-settings-set-bool! s key value)` | Store boolean |
| `(qt-settings-value-bool s key default)` | Read boolean |
| `(qt-settings-contains? s key)` | Check if key exists |
| `(qt-settings-remove! s key)` | Remove key |
| `(qt-settings-all-keys s)` | List all keys |
| `(qt-settings-child-keys s)` | Keys in current group |
| `(qt-settings-child-groups s)` | Subgroups in current group |
| `(qt-settings-begin-group! s prefix)` | Enter group |
| `(qt-settings-end-group! s)` | Leave group |
| `(qt-settings-group s)` | Current group name |
| `(qt-settings-sync! s)` | Flush to storage |
| `(qt-settings-clear! s)` | Remove all keys |
| `(qt-settings-file-name s)` | Path to storage file |
| `(qt-settings-writable? s)` | Can write? |
| `(qt-settings-destroy! s)` | Destroy settings |

**Format constants:** `QT_SETTINGS_NATIVE`, `QT_SETTINGS_INI`

### QCompleter

| Function | Description |
|----------|-------------|
| `(qt-completer-create items)` | Create from list of strings |
| `(qt-completer-set-model-strings! c items)` | Update completion list |
| `(qt-completer-set-case-sensitivity! c sensitive?)` | Case-sensitive matching |
| `(qt-completer-set-completion-mode! c mode)` | Set popup/inline mode |
| `(qt-completer-set-filter-mode! c mode)` | Set starts-with/contains/ends-with |
| `(qt-completer-set-max-visible-items! c count)` | Max visible popup items |
| `(qt-completer-completion-count c)` | Number of completions |
| `(qt-completer-current-completion c)` | Current completion text |
| `(qt-completer-set-completion-prefix! c prefix)` | Set prefix to match |
| `(qt-on-completer-activated! c handler)` | `(lambda (text) ...)` |
| `(qt-line-edit-set-completer! e c)` | Attach to line edit |
| `(qt-completer-set-widget! c widget)` | Attach to arbitrary widget |
| `(qt-completer-complete-rect! c x y w h)` | Show popup at rect |
| `(qt-completer-destroy! c)` | Destroy (only if not attached) |

**Mode constants:** `QT_COMPLETER_POPUP`, `QT_COMPLETER_INLINE`, `QT_COMPLETER_UNFILTERED_POPUP`

**Case constants:** `QT_CASE_INSENSITIVE`, `QT_CASE_SENSITIVE`

**Filter constants:** `QT_MATCH_STARTS_WITH`, `QT_MATCH_CONTAINS`, `QT_MATCH_ENDS_WITH`

### Tooltip / WhatsThis

| Function | Description |
|----------|-------------|
| `(qt-tooltip-show-text! x y text)` | Show tooltip at screen position |
| `(qt-tooltip-hide-text!)` | Hide current tooltip |
| `(qt-tooltip-visible?)` | Is tooltip visible? |
| `(qt-widget-tooltip w)` | Get widget's tooltip text |
| `(qt-widget-set-whats-this! w text)` | Set "What's This?" text |
| `(qt-widget-whats-this w)` | Get "What's This?" text |

### QStandardItemModel

| Function | Description |
|----------|-------------|
| `(qt-standard-model-create rows cols)` | Create model |
| `(qt-standard-model-destroy! m)` | Destroy model |
| `(qt-standard-model-row-count m)` | Row count |
| `(qt-standard-model-column-count m)` | Column count |
| `(qt-standard-model-set-row-count! m rows)` | Set rows |
| `(qt-standard-model-set-column-count! m cols)` | Set columns |
| `(qt-standard-model-set-item! m row col item)` | Set item (transfers ownership) |
| `(qt-standard-model-item m row col)` | Get item |
| `(qt-standard-model-insert-row! m row)` | Insert row |
| `(qt-standard-model-insert-column! m col)` | Insert column |
| `(qt-standard-model-remove-row! m row)` | Remove row |
| `(qt-standard-model-remove-column! m col)` | Remove column |
| `(qt-standard-model-clear! m)` | Clear all items |
| `(qt-standard-model-set-horizontal-header! m col text)` | Set column header |
| `(qt-standard-model-set-vertical-header! m row text)` | Set row header |

### QStandardItem

| Function | Description |
|----------|-------------|
| `(qt-standard-item-create text)` | Create item |
| `(qt-standard-item-text item)` | Get text |
| `(qt-standard-item-set-text! item text)` | Set text |
| `(qt-standard-item-tooltip item)` | Get tooltip |
| `(qt-standard-item-set-tooltip! item text)` | Set tooltip |
| `(qt-standard-item-set-editable! item bool)` | Set editable |
| `(qt-standard-item-editable? item)` | Is editable? |
| `(qt-standard-item-set-enabled! item bool)` | Set enabled |
| `(qt-standard-item-enabled? item)` | Is enabled? |
| `(qt-standard-item-set-selectable! item bool)` | Set selectable |
| `(qt-standard-item-selectable? item)` | Is selectable? |
| `(qt-standard-item-set-checkable! item bool)` | Set checkable |
| `(qt-standard-item-checkable? item)` | Is checkable? |
| `(qt-standard-item-set-check-state! item state)` | Set check state |
| `(qt-standard-item-check-state item)` | Get check state |
| `(qt-standard-item-set-icon! item icon)` | Set icon |
| `(qt-standard-item-append-row! parent child)` | Add child (tree hierarchy) |
| `(qt-standard-item-row-count item)` | Child row count |
| `(qt-standard-item-column-count item)` | Child column count |
| `(qt-standard-item-child item row col)` | Get child item |

Items transfer ownership to the model after `set-item!` or `append-row!`. Do not destroy manually.

### QStringListModel

| Function | Description |
|----------|-------------|
| `(qt-string-list-model-create items)` | Create from list of strings |
| `(qt-string-list-model-destroy! m)` | Destroy model |
| `(qt-string-list-model-set-strings! m items)` | Replace all strings |
| `(qt-string-list-model-strings m)` | Get all strings as list |
| `(qt-string-list-model-row-count m)` | Number of items |

### Views (QListView, QTableView, QTreeView)

| Function | Description |
|----------|-------------|
| `(qt-list-view-create)` | Create list view |
| `(qt-table-view-create)` | Create table view |
| `(qt-tree-view-create)` | Create tree view |
| `(qt-view-set-model! view model)` | Set data model |
| `(qt-view-set-selection-mode! view mode)` | Set selection mode |
| `(qt-view-set-selection-behavior! view behavior)` | Set selection behavior |
| `(qt-view-set-alternating-row-colors! view bool)` | Alternating colors |
| `(qt-view-set-sorting-enabled! view bool)` | Enable sorting |
| `(qt-view-set-edit-triggers! view triggers)` | Set edit triggers |
| `(qt-list-view-set-flow! v flow)` | Set list flow direction |
| `(qt-table-view-set-column-width! v col w)` | Set column width |
| `(qt-table-view-set-row-height! v row h)` | Set row height |
| `(qt-table-view-hide-column! v col)` | Hide column |
| `(qt-table-view-show-column! v col)` | Show column |
| `(qt-table-view-hide-row! v row)` | Hide row |
| `(qt-table-view-show-row! v row)` | Show row |
| `(qt-table-view-resize-columns-to-contents! v)` | Auto-fit columns |
| `(qt-table-view-resize-rows-to-contents! v)` | Auto-fit rows |
| `(qt-tree-view-expand-all! v)` | Expand all nodes |
| `(qt-tree-view-collapse-all! v)` | Collapse all nodes |
| `(qt-tree-view-set-indentation! v pixels)` | Set indentation |
| `(qt-tree-view-indentation v)` | Get indentation |
| `(qt-tree-view-set-root-is-decorated! v bool)` | Root decoration |
| `(qt-tree-view-set-header-hidden! v bool)` | Hide header |
| `(qt-tree-view-set-column-width! v col w)` | Set column width |

### QHeaderView (via view)

| Function | Description |
|----------|-------------|
| `(qt-view-header-set-stretch-last-section! view bool)` | Stretch last section |
| `(qt-view-header-set-section-resize-mode! view mode)` | Set resize mode |
| `(qt-view-header-hide! view)` | Hide header |
| `(qt-view-header-show! view)` | Show header |
| `(qt-view-header-set-default-section-size! view size)` | Set default section size |

### QSortFilterProxyModel

| Function | Description |
|----------|-------------|
| `(qt-sort-filter-proxy-create)` | Create proxy |
| `(qt-sort-filter-proxy-destroy! p)` | Destroy proxy |
| `(qt-sort-filter-proxy-set-source-model! p model)` | Set source model |
| `(qt-sort-filter-proxy-set-filter-regex! p pattern)` | Set filter regex |
| `(qt-sort-filter-proxy-set-filter-column! p col)` | Filter column |
| `(qt-sort-filter-proxy-set-filter-case-sensitivity! p cs)` | Case sensitivity |
| `(qt-sort-filter-proxy-set-filter-role! p role)` | Filter data role |
| `(qt-sort-filter-proxy-sort! p col)` | Sort by column |
| `(qt-sort-filter-proxy-set-sort-role! p role)` | Sort data role |
| `(qt-sort-filter-proxy-set-dynamic-sort-filter! p bool)` | Auto re-sort |
| `(qt-sort-filter-proxy-invalidate-filter! p)` | Force re-filter |
| `(qt-sort-filter-proxy-row-count p)` | Visible row count |

### View Signals + Selection

| Function | Description |
|----------|-------------|
| `(qt-on-view-clicked! view handler)` | `(lambda () ...)` |
| `(qt-on-view-double-clicked! view handler)` | `(lambda () ...)` |
| `(qt-on-view-activated! view handler)` | `(lambda () ...)` |
| `(qt-on-view-selection-changed! view handler)` | `(lambda () ...)` |
| `(qt-view-last-clicked-row)` | Row of last click |
| `(qt-view-last-clicked-col)` | Column of last click |
| `(qt-view-selected-rows view)` | List of selected row indices |
| `(qt-view-current-row view)` | Current row (-1 if none) |

### Validators

| Function | Description |
|----------|-------------|
| `(qt-int-validator-create min max)` | Integer range validator |
| `(qt-double-validator-create bottom top decimals)` | Decimal range validator |
| `(qt-regex-validator-create pattern)` | Regex validator |
| `(qt-validator-destroy! v)` | Destroy validator |
| `(qt-validator-validate v input)` | Validate string, returns state constant |
| `(qt-line-edit-set-validator! edit validator)` | Attach to line edit |
| `(qt-line-edit-has-acceptable-input? edit)` | Current input passes? |

**Validator state constants:** `QT_VALIDATOR_INVALID` (0), `QT_VALIDATOR_INTERMEDIATE` (1), `QT_VALIDATOR_ACCEPTABLE` (2)

### QPlainTextEdit

Efficient plain text editor for large documents.

| Function | Description |
|----------|-------------|
| `(qt-plain-text-edit-create)` | Create editor |
| `(qt-plain-text-edit-set-text! e text)` | Set text |
| `(qt-plain-text-edit-text e)` | Get text |
| `(qt-plain-text-edit-append! e text)` | Append line |
| `(qt-plain-text-edit-clear! e)` | Clear all |
| `(qt-plain-text-edit-set-read-only! e bool)` | Set read-only |
| `(qt-plain-text-edit-read-only? e)` | Is read-only? |
| `(qt-plain-text-edit-set-placeholder! e text)` | Set placeholder |
| `(qt-plain-text-edit-line-count e)` | Line count |
| `(qt-plain-text-edit-set-max-block-count! e n)` | Limit max lines |
| `(qt-plain-text-edit-cursor-line e)` | Cursor line (0-based) |
| `(qt-plain-text-edit-cursor-column e)` | Cursor column (0-based) |
| `(qt-plain-text-edit-set-line-wrap! e mode)` | Set wrap mode |
| `(qt-on-plain-text-changed! e handler)` | `(lambda () ...)` |

**Editor extensions:**

| Function | Description |
|----------|-------------|
| `(qt-plain-text-edit-cursor-position e)` | Get cursor position |
| `(qt-plain-text-edit-set-cursor-position! e pos)` | Set cursor position |
| `(qt-plain-text-edit-move-cursor! e operation anchor)` | Move cursor |
| `(qt-plain-text-edit-select-all! e)` | Select all text |
| `(qt-plain-text-edit-selected-text e)` | Get selection |
| `(qt-plain-text-edit-selection-start e)` | Selection start |
| `(qt-plain-text-edit-selection-end e)` | Selection end |
| `(qt-plain-text-edit-set-selection! e start end)` | Set selection range |
| `(qt-plain-text-edit-has-selection? e)` | Has selection? |
| `(qt-plain-text-edit-insert-text! e text)` | Insert at cursor |
| `(qt-plain-text-edit-remove-selected-text! e)` | Delete selection |
| `(qt-plain-text-edit-undo! e)` | Undo |
| `(qt-plain-text-edit-redo! e)` | Redo |
| `(qt-plain-text-edit-can-undo? e)` | Can undo? |
| `(qt-plain-text-edit-cut! e)` | Cut |
| `(qt-plain-text-edit-copy! e)` | Copy |
| `(qt-plain-text-edit-paste! e)` | Paste |
| `(qt-plain-text-edit-text-length e)` | Total text length |
| `(qt-plain-text-edit-text-range e start end)` | Get text range |
| `(qt-plain-text-edit-line-from-position e pos)` | Line at position |
| `(qt-plain-text-edit-line-end-position e line)` | End of line |
| `(qt-plain-text-edit-find-text e text flags)` | Find text |
| `(qt-plain-text-edit-ensure-cursor-visible! e)` | Scroll to cursor |
| `(qt-plain-text-edit-center-cursor! e)` | Center cursor in view |

**Line wrap constants:** `QT_PLAIN_NO_WRAP` (0), `QT_PLAIN_WIDGET_WRAP` (1)

**Cursor movement constants:** `QT_CURSOR_NO_MOVE`, `QT_CURSOR_START`, `QT_CURSOR_UP`, `QT_CURSOR_START_OF_LINE`, `QT_CURSOR_END_OF_LINE`, `QT_CURSOR_NEXT_CHAR`, `QT_CURSOR_PREVIOUS_CHAR`, `QT_CURSOR_END`, `QT_CURSOR_DOWN`, etc.

**Anchor constants:** `QT_MOVE_ANCHOR`, `QT_KEEP_ANCHOR`

**Find flags:** `QT_FIND_BACKWARD`, `QT_FIND_CASE_SENSITIVE`, `QT_FIND_WHOLE_WORDS`

### QTextDocument

| Function | Description |
|----------|-------------|
| `(qt-text-document-create)` | Create document |
| `(qt-plain-text-document-create)` | Create plain text document |
| `(qt-text-document-destroy! doc)` | Destroy document |
| `(qt-plain-text-edit-document e)` | Get editor's document |
| `(qt-plain-text-edit-set-document! e doc)` | Set editor's document |
| `(qt-text-document-modified? doc)` | Is modified? |
| `(qt-text-document-set-modified! doc bool)` | Set modified flag |

### QToolButton

| Function | Description |
|----------|-------------|
| `(qt-tool-button-create)` | Create tool button |
| `(qt-tool-button-set-text! b text)` | Set text |
| `(qt-tool-button-text b)` | Get text |
| `(qt-tool-button-set-icon! b path)` | Set icon from file |
| `(qt-tool-button-set-menu! b menu)` | Attach dropdown menu |
| `(qt-tool-button-set-popup-mode! b mode)` | Set popup mode |
| `(qt-tool-button-set-auto-raise! b bool)` | Auto-raise appearance |
| `(qt-tool-button-set-arrow-type! b arrow)` | Set arrow indicator |
| `(qt-tool-button-set-tool-button-style! b style)` | Set display style |
| `(qt-on-tool-button-clicked! b handler)` | `(lambda () ...)` |

**Popup mode:** `QT_DELAYED_POPUP` (0), `QT_MENU_BUTTON_POPUP` (1), `QT_INSTANT_POPUP` (2)

**Arrow type:** `QT_NO_ARROW` (0), `QT_UP_ARROW` (1), `QT_DOWN_ARROW` (2), `QT_LEFT_ARROW` (3), `QT_RIGHT_ARROW` (4)

**Style:** `QT_TOOL_BUTTON_ICON_ONLY` (0), `QT_TOOL_BUTTON_TEXT_ONLY` (1), `QT_TOOL_BUTTON_TEXT_BESIDE_ICON` (2), `QT_TOOL_BUTTON_TEXT_UNDER_ICON` (3)

### QSizePolicy

| Function | Description |
|----------|-------------|
| `(qt-widget-set-size-policy! w h-policy v-policy)` | Set size policy |

**Constants:** `QT_SIZE_FIXED` (0), `QT_SIZE_MINIMUM` (1), `QT_SIZE_MINIMUM_EXPANDING` (3), `QT_SIZE_MAXIMUM` (4), `QT_SIZE_PREFERRED` (5), `QT_SIZE_EXPANDING` (7), `QT_SIZE_IGNORED` (13)

### QGraphicsScene

2D scene graph for interactive diagrams.

| Function | Description |
|----------|-------------|
| `(qt-graphics-scene-create x y w h)` | Create scene with bounds |
| `(qt-graphics-scene-add-rect! scene x y w h)` | Add rectangle |
| `(qt-graphics-scene-add-ellipse! scene x y w h)` | Add ellipse |
| `(qt-graphics-scene-add-line! scene x1 y1 x2 y2)` | Add line |
| `(qt-graphics-scene-add-text! scene text)` | Add text item |
| `(qt-graphics-scene-add-pixmap! scene pixmap)` | Add pixmap |
| `(qt-graphics-scene-remove-item! scene item)` | Remove item |
| `(qt-graphics-scene-clear! scene)` | Clear all items |
| `(qt-graphics-scene-items-count scene)` | Item count |
| `(qt-graphics-scene-set-background! scene r g b)` | Set background color |
| `(qt-graphics-scene-destroy! scene)` | Destroy scene (and all items) |

### QGraphicsView

| Function | Description |
|----------|-------------|
| `(qt-graphics-view-create scene)` | Create view for scene |
| `(qt-graphics-view-set-render-hint! view hint)` | Set render hint |
| `(qt-graphics-view-set-drag-mode! view mode)` | Set drag mode |
| `(qt-graphics-view-fit-in-view! view)` | Fit scene to view |
| `(qt-graphics-view-scale! view sx sy)` | Zoom |
| `(qt-graphics-view-center-on! view x y)` | Center on coordinates |

### QGraphicsItem

| Function | Description |
|----------|-------------|
| `(qt-graphics-item-set-pos! item x y)` | Set position |
| `(qt-graphics-item-x item)` | Get X |
| `(qt-graphics-item-y item)` | Get Y |
| `(qt-graphics-item-set-pen! item r g b width)` | Set outline |
| `(qt-graphics-item-set-brush! item r g b)` | Set fill |
| `(qt-graphics-item-set-flags! item flags)` | Set interaction flags |
| `(qt-graphics-item-set-tooltip! item text)` | Set tooltip |
| `(qt-graphics-item-set-zvalue! item z)` | Set stacking order |
| `(qt-graphics-item-zvalue item)` | Get stacking order |
| `(qt-graphics-item-set-rotation! item angle)` | Set rotation |
| `(qt-graphics-item-set-scale! item factor)` | Set scale |
| `(qt-graphics-item-set-visible! item bool)` | Show/hide |

**Item flags:** `QT_ITEM_MOVABLE` (0x1), `QT_ITEM_SELECTABLE` (0x2), `QT_ITEM_FOCUSABLE` (0x4). Combine with `bitwise-ior`.

**Drag modes:** `QT_DRAG_NONE` (0), `QT_DRAG_SCROLL` (1), `QT_DRAG_RUBBER_BAND` (2)

**Render hints:** `QT_RENDER_ANTIALIASING` (0x01), `QT_RENDER_SMOOTH_PIXMAP` (0x02), `QT_RENDER_TEXT_ANTIALIASING` (0x04)

### PaintWidget (custom paintEvent)

A QWidget subclass that fires a Scheme callback during `paintEvent()`.

| Function | Description |
|----------|-------------|
| `(qt-paint-widget-create)` | Create custom paint widget |
| `(qt-on-paint! widget handler)` | Register paint callback |
| `(qt-paint-widget-painter widget)` | Get active QPainter (only valid inside callback) |
| `(qt-paint-widget-update! widget)` | Request repaint |
| `(qt-paint-widget-width widget)` | Current width |
| `(qt-paint-widget-height widget)` | Current height |

### QProcess

| Function | Description |
|----------|-------------|
| `(qt-process-create)` | Create process |
| `(qt-process-start! proc program args)` | Start process |
| `(qt-process-write! proc data)` | Write to stdin |
| `(qt-process-close-write! proc)` | Close stdin |
| `(qt-process-read-stdout proc)` | Read stdout |
| `(qt-process-read-stderr proc)` | Read stderr |
| `(qt-process-wait-for-finished! proc msecs)` | Wait for exit |
| `(qt-process-exit-code proc)` | Get exit code |
| `(qt-process-state proc)` | Get state |
| `(qt-process-kill! proc)` | Kill (SIGKILL) |
| `(qt-process-terminate! proc)` | Terminate (SIGTERM) |
| `(qt-on-process-finished! proc handler)` | `(lambda (exit-code) ...)` |
| `(qt-on-process-ready-read! proc handler)` | `(lambda () ...)` |
| `(qt-process-destroy! proc)` | Destroy process |

**Constants:** `QT_PROCESS_NOT_RUNNING` (0), `QT_PROCESS_STARTING` (1), `QT_PROCESS_RUNNING` (2)

### QWizard / QWizardPage

| Function | Description |
|----------|-------------|
| `(qt-wizard-create)` | Create wizard dialog |
| `(qt-wizard-add-page! wizard page)` | Add page, returns ID |
| `(qt-wizard-set-start-id! wizard id)` | Set starting page |
| `(qt-wizard-current-id wizard)` | Current page ID |
| `(qt-wizard-set-title! wizard title)` | Set title |
| `(qt-wizard-exec! wizard)` | Run modal wizard |
| `(qt-wizard-page-create)` | Create page |
| `(qt-wizard-page-set-title! page title)` | Set page title |
| `(qt-wizard-page-set-subtitle! page subtitle)` | Set subtitle |
| `(qt-wizard-page-set-layout! page layout)` | Set page layout |
| `(qt-on-wizard-current-changed! wizard handler)` | `(lambda (page-id) ...)` |

### QMdiArea / QMdiSubWindow

| Function | Description |
|----------|-------------|
| `(qt-mdi-area-create)` | Create MDI area |
| `(qt-mdi-area-add-sub-window! area widget)` | Add sub-window |
| `(qt-mdi-area-remove-sub-window! area sub)` | Remove sub-window |
| `(qt-mdi-area-active-sub-window area)` | Get active (or `#f`) |
| `(qt-mdi-area-sub-window-count area)` | Count sub-windows |
| `(qt-mdi-area-cascade! area)` | Cascade layout |
| `(qt-mdi-area-tile! area)` | Tile layout |
| `(qt-mdi-area-set-view-mode! area mode)` | Set view mode |
| `(qt-mdi-sub-window-set-title! sub title)` | Set title |
| `(qt-on-mdi-sub-window-activated! area handler)` | `(lambda () ...)` |

**Constants:** `QT_MDI_SUBWINDOW` (0), `QT_MDI_TABBED` (1)

### QDial

| Function | Description |
|----------|-------------|
| `(qt-dial-create)` | Create dial (knob) |
| `(qt-dial-set-value! dial value)` | Set value |
| `(qt-dial-value dial)` | Get value |
| `(qt-dial-set-range! dial min max)` | Set range |
| `(qt-dial-set-notches-visible! dial bool)` | Show notches |
| `(qt-dial-set-wrapping! dial bool)` | Enable wrap-around |
| `(qt-on-dial-value-changed! dial handler)` | `(lambda (value) ...)` |

### QLCDNumber

| Function | Description |
|----------|-------------|
| `(qt-lcd-create digits)` | Create LCD display |
| `(qt-lcd-display-int! lcd value)` | Display integer |
| `(qt-lcd-display-double! lcd value)` | Display float |
| `(qt-lcd-display-string! lcd text)` | Display string |
| `(qt-lcd-set-mode! lcd mode)` | Set mode (dec/hex/oct/bin) |
| `(qt-lcd-set-segment-style! lcd style)` | Set style |

**Constants:** `QT_LCD_DEC` (0), `QT_LCD_HEX` (1), `QT_LCD_OCT` (2), `QT_LCD_BIN` (3); `QT_LCD_OUTLINE` (0), `QT_LCD_FILLED` (1), `QT_LCD_FLAT` (2)

### QToolBox

| Function | Description |
|----------|-------------|
| `(qt-tool-box-create)` | Create accordion widget |
| `(qt-tool-box-add-item! tb widget text)` | Add page |
| `(qt-tool-box-set-current-index! tb index)` | Switch page |
| `(qt-tool-box-current-index tb)` | Current page index |
| `(qt-tool-box-count tb)` | Page count |
| `(qt-tool-box-set-item-text! tb index text)` | Change label |
| `(qt-on-tool-box-current-changed! tb handler)` | `(lambda (index) ...)` |

### QUndoStack

| Function | Description |
|----------|-------------|
| `(qt-undo-stack-create)` | Create undo stack |
| `(qt-undo-stack-push! stack text undo-handler redo-handler)` | Push command |
| `(qt-undo-stack-undo! stack)` | Undo |
| `(qt-undo-stack-redo! stack)` | Redo |
| `(qt-undo-stack-can-undo? stack)` | Can undo? |
| `(qt-undo-stack-can-redo? stack)` | Can redo? |
| `(qt-undo-stack-undo-text stack)` | Next undo text |
| `(qt-undo-stack-redo-text stack)` | Next redo text |
| `(qt-undo-stack-clear! stack)` | Clear history |
| `(qt-undo-stack-create-undo-action stack)` | Create undo QAction |
| `(qt-undo-stack-create-redo-action stack)` | Create redo QAction |
| `(qt-undo-stack-destroy! stack)` | Destroy stack |

```scheme
;; Undo/redo example
(qt-undo-stack-push! stack "Increment"
  (lambda () (set! counter (- counter 1)))    ; undo
  (lambda () (set! counter (+ counter 1))))   ; redo (called immediately)
(qt-undo-stack-undo! stack)  ; counter goes back
(qt-undo-stack-redo! stack)  ; counter goes forward
```

### QFileSystemModel

| Function | Description |
|----------|-------------|
| `(qt-file-system-model-create)` | Create filesystem model |
| `(qt-file-system-model-set-root-path! model path)` | Set root directory |
| `(qt-file-system-model-set-filter! model filters)` | Set filters (`bitwise-ior`) |
| `(qt-file-system-model-set-name-filters! model patterns)` | Set glob patterns (list of strings) |
| `(qt-file-system-model-file-path model row col)` | Get file path |
| `(qt-tree-view-set-file-system-root! view model path)` | Set tree root |
| `(qt-file-system-model-destroy! model)` | Destroy model |

**Constants:** `QT_DIR_DIRS`, `QT_DIR_FILES`, `QT_DIR_HIDDEN`, `QT_DIR_NO_DOT_AND_DOT_DOT`

### QSyntaxHighlighter

Regex-based syntax highlighting for QPlainTextEdit.

| Function | Description |
|----------|-------------|
| `(qt-syntax-highlighter-create document)` | Create highlighter on a document |
| `(qt-syntax-highlighter-destroy! h)` | Destroy highlighter |
| `(qt-syntax-highlighter-add-rule! h pattern fg-color bold)` | Add regex rule |
| `(qt-syntax-highlighter-add-keywords! h words fg-color bold)` | Add keyword list |
| `(qt-syntax-highlighter-add-multiline-rule! h start end fg-color bold)` | Add multiline pattern |
| `(qt-syntax-highlighter-clear-rules! h)` | Clear all rules |
| `(qt-syntax-highlighter-rehighlight! h)` | Re-apply highlighting |

### Line Number Area

| Function | Description |
|----------|-------------|
| `(qt-line-number-area-create editor)` | Create line numbers for QPlainTextEdit |
| `(qt-line-number-area-destroy! area)` | Destroy line number area |
| `(qt-line-number-area-set-visible! area bool)` | Show/hide |
| `(qt-line-number-area-set-bg-color! area color)` | Set background color |
| `(qt-line-number-area-set-fg-color! area color)` | Set text color |

### Extra Selections

| Function | Description |
|----------|-------------|
| `(qt-plain-text-edit-clear-extra-selections! e)` | Clear highlights |
| `(qt-plain-text-edit-add-extra-selection-line! e line bg-color)` | Highlight line |
| `(qt-plain-text-edit-add-extra-selection-range! e start end fg bg)` | Highlight range |
| `(qt-plain-text-edit-apply-extra-selections! e)` | Apply pending highlights |

### QScintilla

Advanced code editor component (requires libqscintilla2).

| Function | Description |
|----------|-------------|
| `(qt-scintilla-create)` | Create Scintilla editor |
| `(qt-scintilla-destroy! s)` | Destroy editor |
| `(qt-scintilla-send-message s msg wparam lparam)` | Send raw Scintilla message |
| `(qt-scintilla-send-message-string s msg wparam str)` | Send message with string |
| `(qt-scintilla-receive-string s msg wparam)` | Receive string from message |
| `(qt-scintilla-set-text! s text)` | Set text |
| `(qt-scintilla-get-text s)` | Get text |
| `(qt-scintilla-get-text-length s)` | Get text length |
| `(qt-scintilla-set-lexer-language! s language)` | Set lexer (e.g. `"cpp"`) |
| `(qt-scintilla-get-lexer-language s)` | Get lexer language |
| `(qt-scintilla-set-read-only! s bool)` | Set read-only |
| `(qt-scintilla-read-only? s)` | Is read-only? |
| `(qt-scintilla-set-margin-width! s margin pixels)` | Set margin width |
| `(qt-scintilla-set-margin-type! s margin type)` | Set margin type |
| `(qt-scintilla-set-focus! s)` | Set keyboard focus |
| `(qt-on-scintilla-text-changed! s handler)` | `(lambda () ...)` |
| `(qt-on-scintilla-char-added! s handler)` | `(lambda () ...)` |
| `(qt-on-scintilla-save-point-reached! s handler)` | `(lambda () ...)` |
| `(qt-on-scintilla-save-point-left! s handler)` | `(lambda () ...)` |
| `(qt-on-scintilla-margin-clicked! s handler)` | `(lambda () ...)` |
| `(qt-on-scintilla-modified! s handler)` | `(lambda () ...)` |

### Signal Disconnect & Callback Management

| Function | Description |
|----------|-------------|
| `(unregister-qt-handler! id)` | Remove callback by ID (returned from `qt-on-*!`) |
| `(qt-disconnect-all! obj)` | Disconnect all signals from a QObject |

All `qt-on-*!` functions return a callback ID:

```scheme
(let ((id (qt-on-clicked! button (lambda () (display "clicked!\n")))))
  ;; Later, remove the handler:
  (unregister-qt-handler! id))
```

Calling `qt-on-*!` multiple times accumulates connections. To replace a handler, unregister the old one first.

### Resource Safety Macros

RAII-style macros that guarantee cleanup even on exceptions.

| Macro | Description |
|-------|-------------|
| `(with-painter (p target) body ...)` | Create QPainter, auto end+destroy |
| `(with-qt-app app body ...)` | Create QApplication, auto destroy |

## Constants Reference

### Alignment
`QT_ALIGN_LEFT`, `QT_ALIGN_RIGHT`, `QT_ALIGN_CENTER`, `QT_ALIGN_TOP`, `QT_ALIGN_BOTTOM`

### Orientation
`QT_HORIZONTAL`, `QT_VERTICAL`

### Echo Mode
`QT_ECHO_NORMAL`, `QT_ECHO_NO_ECHO`, `QT_ECHO_PASSWORD`, `QT_ECHO_PASSWORD_ON_EDIT`

### Tick Position
`QT_TICKS_NONE`, `QT_TICKS_ABOVE`, `QT_TICKS_BELOW`, `QT_TICKS_BOTH_SIDES`

### Window State
`QT_WINDOW_NO_STATE`, `QT_WINDOW_MINIMIZED`, `QT_WINDOW_MAXIMIZED`, `QT_WINDOW_FULL_SCREEN`

### Scrollbar Policy
`QT_SCROLLBAR_AS_NEEDED`, `QT_SCROLLBAR_ALWAYS_OFF`, `QT_SCROLLBAR_ALWAYS_ON`

### Cursor Shape
`QT_CURSOR_ARROW`, `QT_CURSOR_CROSS`, `QT_CURSOR_WAIT`, `QT_CURSOR_IBEAM`, `QT_CURSOR_POINTING_HAND`, `QT_CURSOR_FORBIDDEN`, `QT_CURSOR_BUSY`

### Frame
**Shape:** `QT_FRAME_NO_FRAME`, `QT_FRAME_BOX`, `QT_FRAME_PANEL`, `QT_FRAME_WIN_PANEL`, `QT_FRAME_HLINE`, `QT_FRAME_VLINE`, `QT_FRAME_STYLED_PANEL`

**Shadow:** `QT_FRAME_PLAIN`, `QT_FRAME_RAISED`, `QT_FRAME_SUNKEN`

### Dock Area
`QT_DOCK_LEFT`, `QT_DOCK_RIGHT`, `QT_DOCK_TOP`, `QT_DOCK_BOTTOM`

### Tray Icon
`QT_TRAY_NO_ICON`, `QT_TRAY_INFORMATION`, `QT_TRAY_WARNING`, `QT_TRAY_CRITICAL`

### Key Codes
`QT_KEY_ESCAPE`, `QT_KEY_TAB`, `QT_KEY_BACKTAB`, `QT_KEY_BACKSPACE`, `QT_KEY_RETURN`, `QT_KEY_ENTER`, `QT_KEY_INSERT`, `QT_KEY_DELETE`, `QT_KEY_PAUSE`, `QT_KEY_HOME`, `QT_KEY_END`, `QT_KEY_LEFT`, `QT_KEY_UP`, `QT_KEY_RIGHT`, `QT_KEY_DOWN`, `QT_KEY_PAGE_UP`, `QT_KEY_PAGE_DOWN`, `QT_KEY_F1`..`QT_KEY_F12`, `QT_KEY_SPACE`

### Key Modifiers
`QT_MOD_NONE`, `QT_MOD_SHIFT`, `QT_MOD_CONTROL`, `QT_MOD_ALT`, `QT_MOD_META`

### Selection
**Mode:** `QT_SELECT_NO_SELECTION`, `QT_SELECT_SINGLE`, `QT_SELECT_MULTI`, `QT_SELECT_EXTENDED`, `QT_SELECT_CONTIGUOUS`

**Behavior:** `QT_SELECT_ITEMS`, `QT_SELECT_ROWS`, `QT_SELECT_COLUMNS`

### Sort Order
`QT_SORT_ASCENDING`, `QT_SORT_DESCENDING`

### Check State
`QT_UNCHECKED`, `QT_PARTIALLY_CHECKED`, `QT_CHECKED`

### Header Resize Mode
`QT_HEADER_INTERACTIVE`, `QT_HEADER_STRETCH`, `QT_HEADER_FIXED`, `QT_HEADER_RESIZE_TO_CONTENTS`

### Edit Triggers
`QT_NO_EDIT_TRIGGERS`, `QT_EDIT_DOUBLE_CLICK`, `QT_EDIT_SELECTED_CLICK`, `QT_EDIT_ANY_KEY_PRESSED`, `QT_EDIT_ALL_TRIGGERS`

### Flow Direction
`QT_FLOW_TOP_TO_BOTTOM`, `QT_FLOW_LEFT_TO_RIGHT`

### Day of Week
`QT_MONDAY`, `QT_TUESDAY`, `QT_WEDNESDAY`, `QT_THURSDAY`, `QT_FRIDAY`, `QT_SATURDAY`, `QT_SUNDAY`

## Architecture

The binding uses a three-layer architecture:

1. **C++ shim** (`vendor/qt_shim.h`, `vendor/qt_shim.cpp` in gerbil-qt) -- thin `extern "C"` wrappers around Qt6 C++ classes. All Qt objects are opaque `void*` handles. Compiled as `libqt_shim.so`.

2. **Chez callback bridge** (`qt_chez_shim.c`) -- stores Chez-provided `foreign-callable` function pointers and provides C wrapper functions that pass them to the C++ shim's signal connection APIs. Unlike Gambit's compile-time `c-define` trampolines, Chez creates callback pointers at runtime.

3. **FFI layer** (`chez-qt/ffi.ss`) -- Chez `foreign-procedure` bindings for each C function. Loads `libqt_shim.so` and `qt_chez_shim.so` at library import time. Registers the four callback trampolines (void/string/int/bool) that dispatch to Scheme closures via a callback table.

4. **High-level API** (`chez-qt/qt.ss`) -- Idiomatic Chez Scheme wrappers with boolean conversions, the `with-qt-app` macro, and all the `qt-on-*!` signal registration functions.

### Callback Pattern

Qt signals are connected to Scheme handlers through a callback trampoline system:

```
Qt signal -> C++ lambda -> chez_qt_*() wrapper -> foreign-callable trampoline
  -> callback table lookup -> user's Scheme closure
```

Four callback types cover all signals: `void`, `string(text)`, `int(value)`, `bool(checked)`.

All `qt-on-*!` signal registration functions return a callback ID (integer). Use `unregister-qt-handler!` to remove a specific callback, or `qt-disconnect-all!` to disconnect all signals from a QObject.

### Memory Management

Qt uses parent-child ownership: destroying a parent automatically destroys all children. No GC finalizers are used on parented widgets. The QApplication must be explicitly destroyed (or use `with-qt-app`).

## Examples

| Example | Description |
|---------|-------------|
| `hello.ss` | Minimal window with label |
| `counter.ss` | Button click counter |
| `form.ss` | Form with text inputs, checkboxes, combo box, spin box, message boxes |
| `editor.ss` | Text editor with menus, toolbar, keyboard shortcuts, file I/O |
| `dashboard.ss` | Tabbed dashboard with todo list, data table, slider + progress bar |
| `filebrowser.ss` | File browser with tree view, grid layout, timer clock, clipboard |
| `styled.ss` | Dark-themed split-pane app with scroll area, key events, fullscreen toggle |
| `settings.ss` | Settings dialog with radio buttons, button groups, group boxes, dark theme |
| `painter.ss` | QPainter demo with shapes, text, transforms, compositing |
| `datainput.ss` | Double spin box, date/time pickers, frames, progress dialog, input dialogs |
| `planner.ss` | Event planner with form layout, calendar, rich text preview, dialog buttons, shortcuts |
| `autocomplete.ss` | Search with auto-complete, persistent history (QSettings), tooltips |
| `modelviewer.ss` | Model/View with sortable table, live text filter, tree hierarchy |
| `polished.ss` | Validated inputs, tool buttons, log area, size policies |
| `diagram.ss` | Interactive diagram with QGraphicsScene/View and custom PaintWidget |
| `terminal.ss` | Simple terminal with QProcess, command input, streaming output |
| `widgets.ss` | QDial + QLCDNumber, QToolBox accordion, QUndoStack undo/redo |
| `filemanager.ss` | File system browser with QFileSystemModel + QTreeView, filters |
| `wizard.ss` | Multi-step wizard dialog with QWizard/QWizardPage |
| `mdi.ss` | Multi-document interface with QMdiArea, undo/redo, tile/cascade |
| `dockable.ss` | Dock widgets with QDockWidget |
| `trayapp.ss` | System tray icon with context menu and notifications |
| `dragdrop.ss` | Drag and drop text between widgets |
| `keyboard.ss` | Keyboard event handling demo |
| `dialogs.ss` | All dialog types (message, file, input, color, font) |
| `richtext.ss` | Rich text editing with QTextBrowser |

## License

MIT
