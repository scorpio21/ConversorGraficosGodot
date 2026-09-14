extends Control

## ──────────────────────────────────────────
## Autoload: Theme builder + signal wirer
## Se ejecuta al iniciar la escena principal
## ──────────────────────────────────────────

func _ready() -> void:
	_apply_dark_theme()


func _apply_dark_theme() -> void:
	var theme := Theme.new()

	# ── Paleta ──────────────────────────────
	var col_bg       := Color(0.071, 0.078, 0.118)   # #121320
	var col_panel    := Color(0.11,  0.12,  0.18)    # #1c1f2e
	var col_panel2   := Color(0.13,  0.14,  0.21)    # #22243a
	var col_accent   := Color(0.325, 0.588, 1.0)     # #53B2FF (azul)
	var col_accent2  := Color(0.902, 0.584, 0.251)   # #E69540 (naranja)
	var col_txt      := Color(0.88,  0.88,  0.94)
	var col_subtle   := Color(0.50,  0.50,  0.60)
	var col_success  := Color(0.2,   0.8,   0.45)
	var col_btn_hover := Color(0.18, 0.22,  0.38)

	# ── StyleBox helpers ────────────────────
	var sb_panel := _make_flat(col_panel, 8)
	var sb_panel2 := _make_flat(col_panel2, 6)
	var sb_btn := _make_flat(Color(0.17, 0.20, 0.32), 6, col_accent, 1)
	var sb_btn_hover := _make_flat(col_btn_hover, 6, col_accent, 1)
	var sb_btn_press := _make_flat(Color(0.10, 0.14, 0.26), 6, col_accent2, 1)
	var sb_btn_dis := _make_flat(Color(0.12, 0.13, 0.18), 6, col_subtle, 1)

	# PanelContainer ─────────────────────────
	theme.set_stylebox("panel", "PanelContainer", sb_panel)

	# Button ─────────────────────────────────
	theme.set_stylebox("normal",   "Button", sb_btn)
	theme.set_stylebox("hover",    "Button", sb_btn_hover)
	theme.set_stylebox("pressed",  "Button", sb_btn_press)
	theme.set_stylebox("disabled", "Button", sb_btn_dis)
	theme.set_color("font_color",          "Button", col_txt)
	theme.set_color("font_hover_color",    "Button", col_accent)
	theme.set_color("font_pressed_color",  "Button", col_accent2)
	theme.set_color("font_disabled_color", "Button", col_subtle)
	theme.set_constant("outline_size", "Button", 0)
	theme.set_font_size("font_size", "Button", 13)

	# Label ──────────────────────────────────
	theme.set_color("font_color", "Label", col_txt)
	theme.set_font_size("font_size", "Label", 13)

	# ItemList ───────────────────────────────
	var sb_il := _make_flat(Color(0.08, 0.09, 0.14), 6, col_subtle, 1)
	var sb_il_sel := _make_flat(Color(0.15, 0.25, 0.45), 4, col_accent, 1)
	theme.set_stylebox("panel",    "ItemList", sb_il)
	theme.set_stylebox("selected", "ItemList", sb_il_sel)
	theme.set_stylebox("selected_focus", "ItemList", sb_il_sel)
	theme.set_stylebox("cursor",   "ItemList", sb_il_sel)
	theme.set_color("font_color",          "ItemList", col_txt)
	theme.set_color("font_selected_color", "ItemList", Color.WHITE)
	theme.set_font_size("font_size", "ItemList", 12)

	# ProgressBar ────────────────────────────
	var sb_pb_bg   := _make_flat(Color(0.10, 0.11, 0.17), 4)
	var sb_pb_fill := _make_flat(col_accent, 4)
	theme.set_stylebox("background", "ProgressBar", sb_pb_bg)
	theme.set_stylebox("fill",       "ProgressBar", sb_pb_fill)
	theme.set_color("font_color", "ProgressBar", col_txt)
	theme.set_font_size("font_size", "ProgressBar", 11)

	# SpinBox ────────────────────────────────
	var sb_spin := _make_flat(Color(0.10, 0.11, 0.17), 5, col_subtle, 1)
	theme.set_stylebox("normal",    "LineEdit", sb_spin)
	theme.set_stylebox("focus",     "LineEdit", _make_flat(Color(0.10, 0.11, 0.17), 5, col_accent, 1))
	theme.set_color("font_color",         "LineEdit", col_txt)
	theme.set_color("caret_color",        "LineEdit", col_accent)
	theme.set_color("selection_color",    "LineEdit", Color(col_accent, 0.4))
	theme.set_font_size("font_size", "LineEdit", 13)

	# OptionButton ───────────────────────────
	theme.set_stylebox("normal",   "OptionButton", sb_btn)
	theme.set_stylebox("hover",    "OptionButton", sb_btn_hover)
	theme.set_stylebox("pressed",  "OptionButton", sb_btn_press)
	theme.set_color("font_color",       "OptionButton", col_txt)
	theme.set_color("font_hover_color", "OptionButton", col_accent)
	theme.set_font_size("font_size", "OptionButton", 13)

	# Popup (dropdown) ───────────────────────
	var sb_popup := _make_flat(Color(0.12, 0.14, 0.22), 6, col_subtle, 1)
	theme.set_stylebox("panel", "PopupPanel", sb_popup)

	# CheckBox ───────────────────────────────
	theme.set_color("font_color",       "CheckBox", col_txt)
	theme.set_color("font_hover_color", "CheckBox", col_accent)
	theme.set_font_size("font_size", "CheckBox", 13)

	# ScrollBar ──────────────────────────────
	var sb_scroll_bg   := _make_flat(Color(0.10, 0.10, 0.15), 3)
	var sb_scroll_grab := _make_flat(col_subtle, 3)
	var sb_scroll_hover:= _make_flat(col_accent * Color(1,1,1,0.7), 3)
	for orient in ["HScrollBar", "VScrollBar"]:
		theme.set_stylebox("scroll",            orient, sb_scroll_bg)
		theme.set_stylebox("scroll_focus",      orient, sb_scroll_bg)
		theme.set_stylebox("grabber",           orient, sb_scroll_grab)
		theme.set_stylebox("grabber_highlight", orient, sb_scroll_hover)
		theme.set_stylebox("grabber_pressed",   orient, _make_flat(col_accent, 3))

	# FileDialog ─────────────────────────────
	theme.set_stylebox("panel", "FileDialog", _make_flat(Color(0.09, 0.10, 0.16), 8, col_subtle, 1))

	# VSeparator / HSeparator ────────────────
	theme.set_color("color", "VSeparator", Color(col_subtle, 0.4))
	theme.set_color("color", "HSeparator", Color(col_subtle, 0.4))

	get_tree().root.theme = theme


func _make_flat(bg: Color, radius: int, border: Color = Color.TRANSPARENT, border_w: int = 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left     = radius
	sb.corner_radius_top_right    = radius
	sb.corner_radius_bottom_left  = radius
	sb.corner_radius_bottom_right = radius
	sb.border_color = border
	sb.border_width_top    = border_w
	sb.border_width_bottom = border_w
	sb.border_width_left   = border_w
	sb.border_width_right  = border_w
	sb.content_margin_left   = 8.0
	sb.content_margin_right  = 8.0
	sb.content_margin_top    = 6.0
	sb.content_margin_bottom = 6.0
	return sb
