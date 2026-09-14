extends Control

# ─────────────────────────────────────────────
#  Conversor de Gráficos BMP – Godot 4 Edition
#  Basado en el original de Shackox (VB6)
#  "Gracias Blizzard por liberar el código :)"
# ─────────────────────────────────────────────

const SUPPORTED_EXTENSIONS := ["bmp", "png", "jpg", "jpeg", "tga", "webp"]

var input_folder  : String = ""
var output_folder : String = ""
var file_list     : Array[String] = []
var is_converting : bool = false

# ── referencias UI ───────────────────────────
@onready var lbl_input        : Label        = $VBox/PanelFolders/VBoxFolders/GridFolders/LblInputPath
@onready var lbl_output       : Label        = $VBox/PanelFolders/VBoxFolders/GridFolders/LblOutputPath
@onready var item_list        : ItemList     = $VBox/PanelFiles/VBoxFiles/ItemList
@onready var spin_width       : SpinBox      = $VBox/PanelOptions/VBoxOpts/HBoxOpts/SpinWidth
@onready var spin_height      : SpinBox      = $VBox/PanelOptions/VBoxOpts/HBoxOpts/SpinHeight
@onready var check_keep_ar    : CheckBox     = $VBox/PanelOptions/VBoxOpts/HBoxOpts/ChkKeepAR
@onready var opt_format       : OptionButton = $VBox/PanelOptions/VBoxOpts/HBoxOpts/OptFormat
@onready var opt_interp       : OptionButton = $VBox/PanelOptions/VBoxOpts/HBoxOpts/OptInterp
@onready var check_subfolders : CheckBox     = $VBox/PanelOptions/VBoxOpts/HBoxOpts2/ChkSubfolders
@onready var check_overwrite  : CheckBox     = $VBox/PanelOptions/VBoxOpts/HBoxOpts2/ChkOverwrite
@onready var progress_bar     : ProgressBar  = $VBox/PanelProgress/VBoxProgress/ProgressBar
@onready var lbl_status       : Label        = $VBox/PanelProgress/VBoxProgress/LblStatus
@onready var btn_convert      : Button       = $VBox/HBoxButtons/BtnConvert
@onready var btn_scan         : Button       = $VBox/HBoxButtons/BtnScan
@onready var lbl_count        : Label        = $VBox/PanelFiles/VBoxFiles/HBoxFilesHeader/LblCount
@onready var file_dialog_in   : FileDialog   = $FileDialogIn
@onready var file_dialog_out  : FileDialog   = $FileDialogOut


func _ready() -> void:
	_setup_options()
	_connect_signals()
	_set_status("Selecciona una carpeta de entrada para comenzar.", Color.GRAY)
	progress_bar.value = 0
	btn_convert.disabled = true
	btn_scan.disabled = true

	# Intentar detectar carpeta Graficos junto al ejecutable
	var default_in := OS.get_executable_path().get_base_dir().path_join("Graficos")
	if DirAccess.dir_exists_absolute(default_in):
		_set_input_folder(default_in)


func _setup_options() -> void:
	opt_format.clear()
	opt_format.add_item("PNG", 0)
	opt_format.add_item("BMP", 1)
	opt_format.add_item("JPG", 2)
	opt_format.add_item("WebP", 3)
	opt_format.selected = 0

	opt_interp.clear()
	opt_interp.add_item("Nearest (pixel-art)", 0)
	opt_interp.add_item("Bilineal", 1)
	opt_interp.add_item("Cúbica", 2)
	opt_interp.add_item("Lanczos", 3)
	opt_interp.selected = 0

	spin_width.value  = 32.0
	spin_height.value = 32.0
	spin_width.min_value  = 1.0
	spin_height.min_value = 1.0
	spin_width.max_value  = 4096.0
	spin_height.max_value = 4096.0


func _connect_signals() -> void:
	$VBox/PanelFolders/VBoxFolders/GridFolders/BtnInput.pressed.connect(_on_btn_input_pressed)
	$VBox/PanelFolders/VBoxFolders/GridFolders/BtnOutput.pressed.connect(_on_btn_output_pressed)
	file_dialog_in.dir_selected.connect(_on_file_dialog_in_dir_selected)
	file_dialog_out.dir_selected.connect(_on_file_dialog_out_dir_selected)

	btn_scan.pressed.connect(_on_btn_scan_pressed)
	btn_convert.pressed.connect(_on_btn_convert_pressed)

	$VBox/HBoxButtons/BtnOpenOutput.pressed.connect(_on_btn_open_output_pressed)
	$VBox/HBoxButtons/BtnClear.pressed.connect(_on_btn_clear_pressed)

	spin_width.value_changed.connect(_on_spin_width_value_changed)
	spin_height.value_changed.connect(_on_spin_height_value_changed)

	# Presets
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn16.pressed.connect( func(): _on_btn_preset_pressed(16,16))
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn32.pressed.connect( func(): _on_btn_preset_pressed(32,32))
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn48.pressed.connect( func(): _on_btn_preset_pressed(48,48))
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn64.pressed.connect( func(): _on_btn_preset_pressed(64,64))
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn128.pressed.connect(func(): _on_btn_preset_pressed(128,128))
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn256.pressed.connect(func(): _on_btn_preset_pressed(256,256))
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn512.pressed.connect(func(): _on_btn_preset_pressed(512,512))


# ══════════════════════════════════════════════
#  CARPETAS
# ══════════════════════════════════════════════

func _on_btn_input_pressed() -> void:
	file_dialog_in.popup_centered(Vector2i(800, 520))


func _on_btn_output_pressed() -> void:
	file_dialog_out.popup_centered(Vector2i(800, 520))


func _on_file_dialog_in_dir_selected(dir: String) -> void:
	_set_input_folder(dir)


func _on_file_dialog_out_dir_selected(dir: String) -> void:
	output_folder = dir
	lbl_output.text = dir
	lbl_output.tooltip_text = dir
	_check_ready()


func _set_input_folder(dir: String) -> void:
	input_folder = dir
	lbl_input.text = dir
	lbl_input.tooltip_text = dir

	# Auto output: carpeta hermana _Output
	if output_folder.is_empty():
		output_folder = dir.get_base_dir().path_join(dir.get_file() + "_Output")
		lbl_output.text = output_folder
		lbl_output.tooltip_text = output_folder

	btn_scan.disabled = false
	_scan_files()
	_check_ready()


# ══════════════════════════════════════════════
#  ESCANEO
# ══════════════════════════════════════════════

func _on_btn_scan_pressed() -> void:
	_scan_files()


func _scan_files() -> void:
	file_list.clear()
	item_list.clear()

	if input_folder.is_empty():
		return

	var recursive := check_subfolders.button_pressed
	_scan_dir(input_folder, recursive)

	lbl_count.text = "Archivos encontrados: %d" % file_list.size()
	_set_status(
		"Escaneado completo. %d archivo(s) encontrado(s)." % file_list.size(),
		Color.CYAN if file_list.size() > 0 else Color.ORANGE
	)
	_check_ready()


func _scan_dir(path: String, recursive: bool) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return

	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not fname.begins_with("."):
			var full := path.path_join(fname)
			if dir.current_is_dir():
				if recursive:
					_scan_dir(full, true)
			else:
				var ext := fname.get_extension().to_lower()
				if ext in SUPPORTED_EXTENSIONS:
					file_list.append(full)
					var display := full.trim_prefix(input_folder).trim_prefix("/").trim_prefix("\\")
					item_list.add_item("  " + display)
		fname = dir.get_next()
	dir.list_dir_end()


# ══════════════════════════════════════════════
#  PRESETS
# ══════════════════════════════════════════════

func _on_btn_preset_pressed(w: int, h: int) -> void:
	spin_width.set_value_no_signal(float(w))
	spin_height.set_value_no_signal(float(h))


# ══════════════════════════════════════════════
#  CONVERSIÓN
# ══════════════════════════════════════════════

func _check_ready() -> void:
	btn_convert.disabled = file_list.is_empty() or is_converting


func _on_btn_convert_pressed() -> void:
	if file_list.is_empty() or is_converting:
		return
	_start_conversion()


func _start_conversion() -> void:
	is_converting = true
	btn_convert.disabled = true
	btn_scan.disabled = true

	if not DirAccess.dir_exists_absolute(output_folder):
		var err := DirAccess.make_dir_recursive_absolute(output_folder)
		if err != OK:
			_set_status("❌ ERROR: No se pudo crear la carpeta Output.", Color.RED)
			_finish_conversion()
			return

	var target_w   := int(spin_width.value)
	var target_h   := int(spin_height.value)
	var keep_ar    := check_keep_ar.button_pressed
	var fmt_idx    := opt_format.selected
	var interp_idx := opt_interp.selected
	var overwrite  := check_overwrite.button_pressed
	var interp     := _get_interpolation(interp_idx)
	var ext        := _get_extension(fmt_idx)

	progress_bar.max_value = float(file_list.size())
	progress_bar.value = 0.0

	var ok_count   := 0
	var skip_count := 0
	var err_count  := 0

	for i in file_list.size():
		var src_path := file_list[i]
		_set_status("⏳ Convirtiendo (%d/%d): %s" % [i + 1, file_list.size(), src_path.get_file()], Color.YELLOW)
		progress_bar.value = float(i)

		item_list.deselect_all()
		item_list.select(i)
		item_list.ensure_current_is_visible()

		var img := Image.new()
		if img.load(src_path) != OK:
			_set_item_color(i, Color(1.0, 0.3, 0.3))
			err_count += 1
			await get_tree().process_frame
			continue

		# Tamaño destino con proporción
		var dw := target_w
		var dh := target_h
		if keep_ar:
			var ratio := float(img.get_width()) / float(img.get_height())
			if ratio >= 1.0:
				dh = maxi(1, int(float(dw) / ratio))
			else:
				dw = maxi(1, int(float(dh) * ratio))

		img.resize(dw, dh, interp)

		# Ruta de salida
		var rel := file_list[i].trim_prefix(input_folder).trim_prefix("/").trim_prefix("\\")
		var out_path := output_folder.path_join(
			rel.get_base_dir()
		).path_join(
			rel.get_file().get_basename() + "." + ext
		)

		# Crear subcarpetas
		var out_dir := out_path.get_base_dir()
		if not DirAccess.dir_exists_absolute(out_dir):
			DirAccess.make_dir_recursive_absolute(out_dir)

		# Sobreescritura
		if not overwrite and FileAccess.file_exists(out_path):
			_set_item_color(i, Color(0.9, 0.8, 0.2))
			skip_count += 1
			await get_tree().process_frame
			continue

		# Guardar
		if _save_image(img, out_path, fmt_idx) == OK:
			_set_item_color(i, Color(0.2, 1.0, 0.5))
			ok_count += 1
		else:
			_set_item_color(i, Color(1.0, 0.3, 0.3))
			err_count += 1

		await get_tree().process_frame

	progress_bar.value = float(file_list.size())

	var summary := "✅ Completado — %d convertidos" % ok_count
	if skip_count > 0: summary += "  |  %d omitidos" % skip_count
	if err_count  > 0: summary += "  |  %d errores"  % err_count
	summary += "   →   %s" % output_folder
	_set_status(summary, Color.GREEN)
	_finish_conversion()


func _finish_conversion() -> void:
	is_converting = false
	btn_convert.disabled = file_list.is_empty()
	btn_scan.disabled = input_folder.is_empty()


func _set_item_color(idx: int, color: Color) -> void:
	if idx < item_list.get_item_count():
		item_list.set_item_custom_fg_color(idx, color)


func _get_interpolation(idx: int) -> Image.Interpolation:
	match idx:
		0: return Image.INTERPOLATE_NEAREST
		1: return Image.INTERPOLATE_BILINEAR
		2: return Image.INTERPOLATE_CUBIC
		3: return Image.INTERPOLATE_LANCZOS
	return Image.INTERPOLATE_NEAREST


func _get_extension(fmt_idx: int) -> String:
	match fmt_idx:
		0: return "png"
		1: return "bmp"
		2: return "jpg"
		3: return "webp"
	return "png"


func _save_image(img: Image, path: String, fmt_idx: int) -> Error:
	match fmt_idx:
		0: return img.save_png(path)
		1: return img.save_bmp(path)
		2: return img.save_jpg(path, 0.92)
		3: return img.save_webp(path)
	return img.save_png(path)


func _set_status(msg: String, color: Color = Color.WHITE) -> void:
	if is_instance_valid(lbl_status):
		lbl_status.text = msg
		lbl_status.modulate = color


# ══════════════════════════════════════════════
#  BOTONES EXTRA
# ══════════════════════════════════════════════

func _on_btn_open_output_pressed() -> void:
	if output_folder.is_empty(): return
	if not DirAccess.dir_exists_absolute(output_folder):
		DirAccess.make_dir_recursive_absolute(output_folder)
	OS.shell_open(output_folder)


func _on_btn_clear_pressed() -> void:
	file_list.clear()
	item_list.clear()
	lbl_count.text = "Archivos encontrados: 0"
	progress_bar.value = 0.0
	_set_status("Lista limpiada.", Color.GRAY)
	_check_ready()


func _on_spin_width_value_changed(value: float) -> void:
	if check_keep_ar.button_pressed:
		spin_height.set_value_no_signal(value)


func _on_spin_height_value_changed(value: float) -> void:
	if check_keep_ar.button_pressed:
		spin_width.set_value_no_signal(value)
