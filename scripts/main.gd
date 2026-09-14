extends Control

# ─────────────────────────────────────────────
#  Conversor de Gráficos BMP – Godot 4 Edition
#  Basado en el original de Shackox (VB6)
#  "Gracias Blizzard por liberar el código :)"
# ─────────────────────────────────────────────

const SUPPORTED_EXTENSIONS := ["bmp", "png", "jpg", "jpeg", "tga", "webp"]
const CONFIG_FILE := "user://conversor_config.cfg"

var input_folder  : String = ""
var output_folder : String = ""
var file_list     : Array[String] = []
var is_converting : bool = false
var auto_mode     : bool = true   # Modo automático SIEMPRE activo (como VB6 original)

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
	_load_config()  # Cargar configuración guardada
	_set_status("Selecciona una carpeta de entrada para comenzar.", Color.GRAY)
	progress_bar.value = 0
	btn_convert.disabled = true
	btn_scan.disabled = true
	
	# Modo automático siempre activo (como VB6 original)
	auto_mode = true
	# Deshabilitar controles manuales ya que siempre es automático
	spin_width.editable = false
	spin_height.editable = false
	check_keep_ar.disabled = true

	# Intentar detectar carpeta Graficos junto al ejecutable solo si no hay configuración guardada
	if input_folder.is_empty():
		var default_in := OS.get_executable_path().get_base_dir().path_join("Graficos")
		if DirAccess.dir_exists_absolute(default_in):
			_set_input_folder(default_in)


func _setup_options() -> void:
	opt_format.clear()
	opt_format.add_item("PNG", 0)
	opt_format.add_item("JPG", 1)
	opt_format.add_item("WebP", 2)
	opt_format.add_item("EXR (HDR)", 3)
	opt_format.add_item("DDS", 4)
	opt_format.selected = 0

	opt_interp.clear()
	opt_interp.add_item("Nearest (pixel-art)", 0)
	opt_interp.add_item("Bilineal", 1)
	opt_interp.add_item("Cúbica", 2)
	opt_interp.add_item("Lanczos", 3)
	opt_interp.selected = 0  # Nearest por defecto para similaridad con VB6

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
	_save_config()  # Guardar configuración al cambiar ruta


func _on_file_dialog_out_dir_selected(dir: String) -> void:
	output_folder = dir
	lbl_output.text = dir
	lbl_output.tooltip_text = dir
	_check_ready()
	_save_config()  # Guardar configuración al cambiar ruta


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
	
	# Modo automático siempre activo (como VB6 original)
	auto_mode = true

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

		# Tamaño destino
		var dw := target_w
		var dh := target_h
		
		if auto_mode:
			# Lógica original del código VB6
			var orig_w := img.get_width()
			var orig_h := img.get_height()
			var max_dim := maxi(orig_w, orig_h)
			var auto_size := _obtener_dimension(max_dim)
			print("DEBUG: Imagen original: ", orig_w, "x", orig_h, " | Max dim: ", max_dim, " | Auto size: ", auto_size)
			dw = auto_size
			dh = auto_size
			print("DEBUG: Resize a: ", dw, "x", dh)
		elif keep_ar:
			# Preservar aspect ratio manual
			var ratio := float(img.get_width()) / float(img.get_height())
			if ratio >= 1.0:
				dh = maxi(1, int(float(dw) / ratio))
			else:
				dw = maxi(1, int(float(dh) * ratio))

		print("DEBUG: Antes de resize - Tamaño actual: ", img.get_width(), "x", img.get_height())
		img.resize(dw, dh, interp)
		print("DEBUG: Después de resize - Tamaño actual: ", img.get_width(), "x", img.get_height())

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
		1: return "jpg"
		2: return "webp"
		3: return "exr"
		4: return "dds"
	return "png"


# Función original del código VB6 para determinar tamaño automáticamente
func _obtener_dimension(dim: int) -> int:
	if dim <= 32:
		return 32
	elif dim <= 64:
		return 64
	elif dim <= 128:
		return 128
	elif dim <= 256:
		return 256
	elif dim <= 512:
		return 512
	elif dim <= 1024:
		return 1024
	elif dim <= 2048:
		return 2048
	elif dim <= 4096:
		return 4096
	else:
		return 4096


func _save_image(img: Image, path: String, fmt_idx: int) -> Error:
	match fmt_idx:
		0: return img.save_png(path)
		1: return img.save_jpg(path, 0.92)
		2: return img.save_webp(path, false, 0.92)
		3: return img.save_exr(path, false)
		4: return img.save_dds(path)
	return img.save_png(path)


func _set_status(msg: String, color: Color = Color.WHITE) -> void:
	if is_instance_valid(lbl_status):
		lbl_status.text = msg
		lbl_status.modulate = color


# ─────────────────────────────────────────────
#  CONFIGURACIÓN
# ─────────────────────────────────────────────

func _save_config() -> void:
	var config := ConfigFile.new()
	config.set_value("paths", "input_folder", input_folder)
	config.set_value("paths", "output_folder", output_folder)
	config.set_value("settings", "keep_ar", check_keep_ar.button_pressed)
	config.set_value("settings", "subfolders", check_subfolders.button_pressed)
	config.set_value("settings", "overwrite", check_overwrite.button_pressed)
	config.set_value("settings", "format", opt_format.selected)
	config.set_value("settings", "interpolation", opt_interp.selected)
	
	var err := config.save(CONFIG_FILE)
	if err != OK:
		print("Error guardando configuración: ", err)


func _load_config() -> void:
	var config := ConfigFile.new()
	var err := config.load(CONFIG_FILE)
	
	if err != OK:
		print("No hay configuración guardada o error al cargar: ", err)
		return
	
	# Cargar rutas
	input_folder = config.get_value("paths", "input_folder", "")
	output_folder = config.get_value("paths", "output_folder", "")
	
	# Aplicar rutas si existen
	if not input_folder.is_empty() and DirAccess.dir_exists_absolute(input_folder):
		lbl_input.text = input_folder
		lbl_input.tooltip_text = input_folder
		btn_scan.disabled = false
	
	if not output_folder.is_empty():
		lbl_output.text = output_folder
		lbl_output.tooltip_text = output_folder
	
	# Cargar configuraciones
	var loaded_keep_ar := config.get_value("settings", "keep_ar", false) as bool
	var loaded_subfolders := config.get_value("settings", "subfolders", true) as bool
	var loaded_overwrite := config.get_value("settings", "overwrite", true) as bool
	var loaded_format := config.get_value("settings", "format", 0) as int
	var loaded_interp := config.get_value("settings", "interpolation", 0) as int  # Nearest por defecto
	
	# Aplicar configuraciones después de que la UI esté lista
	call_deferred("_apply_loaded_config", loaded_keep_ar, loaded_subfolders, 
				   loaded_overwrite, loaded_format, loaded_interp)


func _apply_loaded_config(keep: bool, sub: bool, over: bool, fmt: int, inter: int) -> void:
	check_keep_ar.button_pressed = keep
	check_subfolders.button_pressed = sub
	check_overwrite.button_pressed = over
	opt_format.selected = fmt
	opt_interp.selected = inter
	
	# Modo automático siempre activo
	auto_mode = true
	spin_width.editable = false
	spin_height.editable = false
	check_keep_ar.disabled = true


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
	_save_config()  # Guardar configuración al cambiar tamaño


func _on_spin_height_value_changed(value: float) -> void:
	if check_keep_ar.button_pressed:
		spin_width.set_value_no_signal(value)
