extends Control

# ─────────────────────────────────────────────
#  Conversor de Gráficos BMP – Godot 4 Edition
#  Basado en el original de Shackox (VB6)
#
#  Compatibilidad AO:
#  - BMP 8-bit: conserva la paleta y los índices de píxel.
#  - El tamaño se calcula como en el VB6 original.
#  - La imagen NO se escala: se copia en (0,0) sobre un fondo negro.
#  - La salida BMP 8-bit conserva una paleta de 256 entradas.
# ─────────────────────────────────────────────

const SUPPORTED_EXTENSIONS := ["bmp", "png", "jpg", "jpeg", "tga", "webp"]
const CONFIG_FILE := "user://conversor_config.cfg"
const BMP8_BPP := 8
const BMP24_BPP := 24

var input_folder: String = ""
var output_folder: String = ""
var file_list: Array[String] = []
var is_converting: bool = false
var auto_mode: bool = true

@onready var lbl_input: Label = $VBox/PanelFolders/VBoxFolders/GridFolders/LblInputPath
@onready var lbl_output: Label = $VBox/PanelFolders/VBoxFolders/GridFolders/LblOutputPath
@onready var item_list: ItemList = $VBox/PanelFiles/VBoxFiles/ItemList
@onready var spin_width: SpinBox = $VBox/PanelOptions/VBoxOpts/HBoxOpts/SpinWidth
@onready var spin_height: SpinBox = $VBox/PanelOptions/VBoxOpts/HBoxOpts/SpinHeight
@onready var check_keep_ar: CheckBox = $VBox/PanelOptions/VBoxOpts/HBoxOpts/ChkKeepAR
@onready var opt_format: OptionButton = $VBox/PanelOptions/VBoxOpts/HBoxOpts/OptFormat
@onready var opt_interp: OptionButton = $VBox/PanelOptions/VBoxOpts/HBoxOpts/OptInterp
@onready var check_subfolders: CheckBox = $VBox/PanelOptions/VBoxOpts/HBoxOpts2/ChkSubfolders
@onready var check_overwrite: CheckBox = $VBox/PanelOptions/VBoxOpts/HBoxOpts2/ChkOverwrite
@onready var progress_bar: ProgressBar = $VBox/PanelProgress/VBoxProgress/ProgressBar
@onready var lbl_status: Label = $VBox/PanelProgress/VBoxProgress/LblStatus
@onready var btn_convert: Button = $VBox/HBoxButtons/BtnConvert
@onready var btn_scan: Button = $VBox/HBoxButtons/BtnScan
@onready var lbl_count: Label = $VBox/PanelFiles/VBoxFiles/HBoxFilesHeader/LblCount
@onready var file_dialog_in: FileDialog = $FileDialogIn
@onready var file_dialog_out: FileDialog = $FileDialogOut
@onready var help_menu: MenuButton = $VBox/TitleBar/HelpMenu
@onready var help_dialog: AcceptDialog = $HelpDialog
@onready var help_text: RichTextLabel = $HelpDialog/HelpText


func _ready() -> void:
	_setup_options()
	_connect_signals()
	_setup_help_menu()
	_load_config()
	_set_status("Selecciona una carpeta de entrada para comenzar.", Color.GRAY)
	progress_bar.value = 0
	btn_convert.disabled = true
	btn_scan.disabled = true

	auto_mode = true
	spin_width.editable = false
	spin_height.editable = false
	check_keep_ar.disabled = true

	if input_folder.is_empty():
		var default_in := OS.get_executable_path().get_base_dir().path_join("Graficos")
		if DirAccess.dir_exists_absolute(default_in):
			_set_input_folder(default_in)


func _setup_options() -> void:
	opt_format.clear()
	opt_format.add_item("BMP 8-bit (AO)", 0)
	opt_format.add_item("PNG", 1)
	opt_format.add_item("JPG", 2)
	opt_format.add_item("WebP", 3)
	opt_format.add_item("EXR (HDR)", 4)
	opt_format.add_item("DDS", 5)
	opt_format.selected = 0

	opt_interp.clear()
	opt_interp.add_item("Sin escalado (VB6/AO)", 0)
	opt_interp.add_item("Nearest (pixel-art)", 1)
	opt_interp.add_item("Bilineal", 2)
	opt_interp.add_item("Cúbica", 3)
	opt_interp.add_item("Lanczos", 4)
	opt_interp.selected = 0

	spin_width.value = 32.0
	spin_height.value = 32.0
	spin_width.min_value = 1.0
	spin_height.min_value = 1.0
	spin_width.max_value = 4096.0
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

	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn16.pressed.connect(func(): _on_btn_preset_pressed(16, 16))
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn32.pressed.connect(func(): _on_btn_preset_pressed(32, 32))
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn48.pressed.connect(func(): _on_btn_preset_pressed(48, 48))
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn64.pressed.connect(func(): _on_btn_preset_pressed(64, 64))
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn128.pressed.connect(func(): _on_btn_preset_pressed(128, 128))
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn256.pressed.connect(func(): _on_btn_preset_pressed(256, 256))
	$VBox/PanelOptions/VBoxOpts/HBoxPresets/Btn512.pressed.connect(func(): _on_btn_preset_pressed(512, 512))




func _setup_help_menu() -> void:
	var popup := help_menu.get_popup()
	popup.clear()
	popup.add_item("Cómo funciona", 1)
	popup.add_item("Carpetas de entrada y salida", 2)
	popup.add_item("Tamaño y presets", 3)
	popup.add_item("Formato BMP 8-bit (AO)", 4)
	popup.add_item("Interpolación", 5)
	popup.add_item("Subcarpetas y sobrescritura", 6)
	popup.add_separator()
	popup.add_item("Flujo recomendado para Argentum Online", 7)
	popup.id_pressed.connect(_on_help_menu_id_pressed)


func _on_help_menu_id_pressed(id: int) -> void:
	var title := "Ayuda - Conversor de Gráficos"
	var text := ""

	match id:
		1:
			title = "Cómo funciona"
			text = """[font_size=18][b]Cómo funciona el conversor[/b][/font_size]

1. Selecciona la carpeta [b]Entrada[/b], donde están tus gráficos.
2. Selecciona la carpeta [b]Salida[/b], donde se guardarán los resultados.
3. Pulsa [b]Escanear carpeta[/b] para detectar los archivos.
4. Revisa el número de archivos encontrados.
5. Pulsa [b]Convertir todo[/b].

En el modo [b]BMP 8-bit (AO)[/b], la imagen original no se estira ni se interpola: se coloca desde la posición (0,0) sobre un lienzo cuadrado negro, siguiendo el comportamiento del conversor VB6 original."""

		2:
			title = "Carpetas de entrada y salida"
			text = """[font_size=18][b]Carpetas[/b][/font_size]

[b]Entrada:[/b] carpeta que contiene los gráficos que quieres procesar.
[b]Salida:[/b] carpeta donde se crean los archivos convertidos.

Puedes cambiar ambas carpetas con [b]Seleccionar...[/b]. La aplicación recuerda las rutas utilizadas.

Si está activada la opción [b]Incluir subcarpetas[/b], también se procesan los gráficos que estén dentro de carpetas inferiores y se mantiene su estructura en la salida."""

		3:
			title = "Tamaño y presets"
			text = """[font_size=18][b]Tamaño[/b][/font_size]

Los campos [b]Ancho[/b] y [b]Alto[/b] indican el tamaño manual cuando se utiliza un modo que lo necesita.

Los botones [b]16×16, 32×32, 48×48, 64×64, 128×128, 256×256 y 512×512[/b] son accesos rápidos para elegir un tamaño.

En [b]BMP 8-bit (AO)[/b] el tamaño final se calcula automáticamente a partir de la mayor dimensión del BMP: 32, 64, 128, 256, 512, 1024, 2048 o 4096 píxeles. La imagen original se copia sin escalar."""

		4:
			title = "Formato BMP 8-bit (AO)"
			text = """[font_size=18][b]BMP 8-bit (AO)[/b][/font_size]

Este modo está pensado especialmente para los gráficos de [b]Argentum Online[/b].

• Lee directamente BMP de 8 bits.
• Conserva la paleta de hasta 256 colores.
• Conserva los índices de píxel.
• Respeta el padding de las filas BMP.
• Admite BMP almacenados de abajo hacia arriba y de arriba hacia abajo.
• Crea el cuadrado final con fondo negro.
• No aplica resize ni interpolación al gráfico original.

Si el archivo de entrada es un BMP de 8 bits, el resultado también se escribe como BMP de 8 bits con una paleta de 256 entradas."""

		5:
			title = "Interpolación"
			text = """[font_size=18][b]Interpolación[/b][/font_size]

La interpolación solo tiene sentido cuando se cambia el tamaño de una imagen.

[b]Sin escalado (VB6/AO):[/b] no modifica el tamaño del gráfico; lo copia en (0,0). Es la opción recomendada para Argentum Online.

[b]Nearest:[/b] conserva bordes duros y es adecuada para pixel-art.
[b]Bilineal:[/b] suaviza la imagen.
[b]Cúbica:[/b] realiza una interpolación más suave.
[b]Lanczos:[/b] está pensada para redimensionados de alta calidad.

En [b]BMP 8-bit (AO)[/b] no se utiliza interpolación para la copia del gráfico original."""

		6:
			title = "Subcarpetas y sobrescritura"
			text = """[font_size=18][b]Opciones adicionales[/b][/font_size]

[b]Incluir subcarpetas:[/b] busca BMP y otros formatos compatibles dentro de las carpetas inferiores y conserva su estructura relativa en la salida.

[b]Sobreescribir existentes:[/b] si está activada, un archivo de salida existente se reemplaza. Si está desactivada, el archivo se omite y aparece como omitido en el resultado.

Estas opciones permiten procesar grandes carpetas sin tener que reorganizar los gráficos manualmente."""

		7:
			title = "Flujo recomendado para Argentum Online"
			text = """[font_size=18][b]Configuración recomendada para AO[/b][/font_size]

1. [b]Formato:[/b] BMP 8-bit (AO).
2. [b]Interpolación:[/b] Sin escalado (VB6/AO).
3. [b]Incluir subcarpetas:[/b] actívalo si tus gráficos están organizados por carpetas.
4. [b]Sobreescribir existentes:[/b] actívalo si quieres regenerar la salida.
5. Selecciona Entrada y Salida.
6. Escanea y comprueba los archivos detectados.
7. Convierte.

El objetivo de este modo es mantener el comportamiento del conversor VB6 utilizado con los gráficos de Argentum Online: [b]BMP 8-bit, paleta conservada, fondo negro y gráfico original sin escalar en (0,0).[/b]"""

		_:
			return

	help_dialog.title = title
	help_text.text = text
	help_dialog.popup_centered(Vector2i(760, 520))


func _on_btn_input_pressed() -> void:
	file_dialog_in.popup_centered(Vector2i(800, 520))


func _on_btn_output_pressed() -> void:
	file_dialog_out.popup_centered(Vector2i(800, 520))


func _on_file_dialog_in_dir_selected(dir: String) -> void:
	_set_input_folder(dir)
	_save_config()


func _on_file_dialog_out_dir_selected(dir: String) -> void:
	output_folder = dir
	lbl_output.text = dir
	lbl_output.tooltip_text = dir
	_check_ready()
	_save_config()


func _set_input_folder(dir: String) -> void:
	input_folder = dir
	lbl_input.text = dir
	lbl_input.tooltip_text = dir

	if output_folder.is_empty():
		output_folder = dir.get_base_dir().path_join(dir.get_file() + "_Output")
		lbl_output.text = output_folder
		lbl_output.tooltip_text = output_folder

	btn_scan.disabled = false
	_scan_files()
	_check_ready()


func _on_btn_scan_pressed() -> void:
	_scan_files()


func _scan_files() -> void:
	file_list.clear()
	item_list.clear()

	if input_folder.is_empty():
		return

	_scan_dir(input_folder, check_subfolders.button_pressed)

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


func _on_btn_preset_pressed(w: int, h: int) -> void:
	spin_width.set_value_no_signal(float(w))
	spin_height.set_value_no_signal(float(h))


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
			_set_status("❌ ERROR: No se pudo crear la carpeta de salida.", Color.RED)
			_finish_conversion()
			return

	var overwrite := check_overwrite.button_pressed
	var fmt_idx := opt_format.selected

	progress_bar.max_value = float(file_list.size())
	progress_bar.value = 0.0

	var ok_count := 0
	var skip_count := 0
	var err_count := 0

	for i in file_list.size():
		var src_path := file_list[i]
		_set_status("⏳ Convirtiendo (%d/%d): %s" % [i + 1, file_list.size(), src_path.get_file()], Color.YELLOW)
		progress_bar.value = float(i)

		item_list.deselect_all()
		item_list.select(i)
		item_list.ensure_current_is_visible()

		var out_path := _build_output_path(src_path, fmt_idx)
		var out_dir := out_path.get_base_dir()
		if not DirAccess.dir_exists_absolute(out_dir):
			var dir_err := DirAccess.make_dir_recursive_absolute(out_dir)
			if dir_err != OK:
				_set_item_color(i, Color(1.0, 0.3, 0.3))
				err_count += 1
				await get_tree().process_frame
				continue

		if not overwrite and FileAccess.file_exists(out_path):
			_set_item_color(i, Color(0.9, 0.8, 0.2))
			skip_count += 1
			await get_tree().process_frame
			continue

		var result := _convert_file(src_path, out_path, fmt_idx)
		if result == OK:
			_set_item_color(i, Color(0.2, 1.0, 0.5))
			ok_count += 1
		else:
			_set_item_color(i, Color(1.0, 0.3, 0.3))
			err_count += 1
			print("ERROR convirtiendo ", src_path, " -> ", out_path, " | Error: ", result)

		await get_tree().process_frame

	progress_bar.value = float(file_list.size())

	var summary := "✅ Completado — %d convertidos" % ok_count
	if skip_count > 0:
		summary += "  |  %d omitidos" % skip_count
	if err_count > 0:
		summary += "  |  %d errores" % err_count
	summary += "   →   %s" % output_folder
	_set_status(summary, Color.GREEN if err_count == 0 else Color.ORANGE)
	_finish_conversion()


func _finish_conversion() -> void:
	is_converting = false
	btn_convert.disabled = file_list.is_empty()
	btn_scan.disabled = input_folder.is_empty()


func _build_output_path(src_path: String, fmt_idx: int) -> String:
	var rel := src_path.trim_prefix(input_folder).trim_prefix("/").trim_prefix("\\")
	var extension := _get_extension(fmt_idx)
	return output_folder.path_join(rel.get_base_dir()).path_join(rel.get_file().get_basename() + "." + extension)


func _convert_file(src_path: String, out_path: String, fmt_idx: int) -> Error:
	# El modo BMP AO usa un lector/escritor propio para no perder la paleta 8-bit.
	if fmt_idx == 0 and src_path.get_extension().to_lower() == "bmp":
		return _convert_bmp_ao(src_path, out_path)

	var img := Image.new()
	var load_err := img.load(src_path)
	if load_err != OK:
		return load_err

	var orig_w := img.get_width()
	var orig_h := img.get_height()
	var size := _obtener_dimension(maxi(orig_w, orig_h))

	# Igual que VB6: lienzo negro y copia de la imagen en 0,0.
	var canvas := Image.create(size, size, false, Image.FORMAT_RGBA8)
	canvas.fill(Color.BLACK)
	canvas.blit_rect(img, Rect2i(0, 0, orig_w, orig_h), Vector2i(0, 0))

	return _save_image(canvas, out_path, fmt_idx)


# ══════════════════════════════════════════════
#  BMP 8-BIT / PALETA
# ══════════════════════════════════════════════

func _convert_bmp_ao(src_path: String, out_path: String) -> Error:
	var file := FileAccess.open(src_path, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()

	var data := file.get_buffer(file.get_length())
	file.close()

	if data.size() < 54:
		return ERR_FILE_CORRUPT
	if _u16(data, 0) != 0x4D42:
		return ERR_FILE_UNRECOGNIZED

	var pixel_offset := _u32(data, 10)
	var dib_size := _u32(data, 14)
	if dib_size < 40 or data.size() < 14 + dib_size:
		return ERR_FILE_CORRUPT

	var width := _i32(data, 18)
	var raw_height := _i32(data, 22)
	var planes := _u16(data, 26)
	var bpp := _u16(data, 28)
	var compression := _u32(data, 30)
	var colors_used := _u32(data, 46)

	if width <= 0 or raw_height == 0 or planes != 1:
		return ERR_FILE_CORRUPT
	if bpp != BMP8_BPP:
		# Un BMP que no es 8-bit se procesa por el camino genérico.
		var img := Image.new()
		var load_err := img.load(src_path)
		if load_err != OK:
			return load_err
		var size := _obtener_dimension(maxi(img.get_width(), img.get_height()))
		var canvas := Image.create(size, size, false, Image.FORMAT_RGBA8)
		canvas.fill(Color.BLACK)
		canvas.blit_rect(img, Rect2i(0, 0, img.get_width(), img.get_height()), Vector2i(0, 0))
		return _write_bmp24_from_image(canvas, out_path)
	if compression != 0:
		return ERR_UNAVAILABLE

	var height := absi(raw_height)
	var palette_count := int(colors_used)
	if palette_count <= 0:
		palette_count = 256
	palette_count = mini(palette_count, 256)

	var palette_offset := 14 + int(dib_size)
	if palette_offset + palette_count * 4 > data.size():
		return ERR_FILE_CORRUPT
	if pixel_offset >= data.size():
		return ERR_FILE_CORRUPT

	var src_stride := ((width + 3) / 4) * 4
	var required_pixels := src_stride * height
	if int(pixel_offset) + required_pixels > data.size():
		return ERR_FILE_CORRUPT

	var dest_size := _obtener_dimension(maxi(width, height))
	var dest_stride := ((dest_size + 3) / 4) * 4
	var dest_pixel_bytes := dest_stride * dest_size

	# Copiamos la paleta original. Si existe un índice negro lo usamos como fondo.
	var palette := PackedByteArray()
	palette.resize(256 * 4)
	for i in 256 * 4:
		palette[i] = 0

	for i in palette_count:
		var p := palette_offset + i * 4
		palette[i * 4] = data[p]
		palette[i * 4 + 1] = data[p + 1]
		palette[i * 4 + 2] = data[p + 2]
		palette[i * 4 + 3] = 0

	var black_index := _find_black_palette_index(palette, palette_count)
	if black_index < 0:
		black_index = _find_unused_palette_index(data, pixel_offset, src_stride, width, height, raw_height, palette_count)
		if black_index >= 0:
			palette[black_index * 4] = 0
			palette[black_index * 4 + 1] = 0
			palette[black_index * 4 + 2] = 0
			palette[black_index * 4 + 3] = 0
		else:
			black_index = _find_closest_black_palette_index(palette, palette_count)

	var pixels := PackedByteArray()
	pixels.resize(dest_pixel_bytes)
	pixels.fill(black_index)

	# Copia directa de índices: no hay resize ni interpolación.
	# Coordenadas y/x se interpretan desde arriba a la izquierda, igual que PaintPicture.
	for y in height:
		var src_row: int
		if raw_height > 0:
			src_row = height - 1 - y
		else:
			src_row = y
		var src_base := int(pixel_offset) + src_row * src_stride
		var dst_row := dest_size - 1 - y
		var dst_base := dst_row * dest_stride
		for x in width:
			pixels[dst_base + x] = data[src_base + x]

	return _write_bmp8(out_path, dest_size, dest_size, palette, pixels, dest_stride)


func _write_bmp8(path: String, width: int, height: int, palette: PackedByteArray, pixels: PackedByteArray, stride: int) -> Error:
	var pixel_offset := 14 + 40 + 256 * 4
	var image_size := stride * height
	var file_size := pixel_offset + image_size

	var out := PackedByteArray()
	out.resize(file_size)
	out.fill(0)

	# BITMAPFILEHEADER
	_w16(out, 0, 0x4D42)
	_w32(out, 2, file_size)
	_w32(out, 10, pixel_offset)

	# BITMAPINFOHEADER
	_w32(out, 14, 40)
	_w32(out, 18, width)
	_w32(out, 22, height) # bottom-up
	_w16(out, 26, 1)
	_w16(out, 28, 8)
	_w32(out, 30, 0) # BI_RGB
	_w32(out, 34, image_size)
	_w32(out, 38, 0)
	_w32(out, 42, 0)
	_w32(out, 46, 256)
	_w32(out, 50, 256)

	for i in 256 * 4:
		out[54 + i] = palette[i]

	for i in image_size:
		out[pixel_offset + i] = pixels[i]

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_buffer(out)
	file.close()
	return OK


func _find_black_palette_index(palette: PackedByteArray, count: int) -> int:
	for i in count:
		if palette[i * 4] == 0 and palette[i * 4 + 1] == 0 and palette[i * 4 + 2] == 0:
			return i
	return -1


func _find_unused_palette_index(data: PackedByteArray, pixel_offset: int, stride: int, width: int, height: int, raw_height: int, palette_count: int) -> int:
	var used := PackedByteArray()
	used.resize(256)
	used.fill(0)

	for y in height:
		var src_row := height - 1 - y if raw_height > 0 else y
		var base := pixel_offset + src_row * stride
		for x in width:
			used[data[base + x]] = 1

	for i in palette_count:
		if used[i] == 0:
			return i
	return -1


func _find_closest_black_palette_index(palette: PackedByteArray, count: int) -> int:
	var best := 0
	var best_dist := 1 << 30
	for i in count:
		var b := int(palette[i * 4])
		var g := int(palette[i * 4 + 1])
		var r := int(palette[i * 4 + 2])
		var dist := r * r + g * g + b * b
		if dist < best_dist:
			best_dist = dist
			best = i
	return best


# Escritura genérica de 24-bit para BMP que no sean 8-bit cuando se selecciona el modo AO.
func _write_bmp24_from_image(img: Image, path: String) -> Error:
	var width := img.get_width()
	var height := img.get_height()
	var stride := ((width * 3 + 3) / 4) * 4
	var image_size := stride * height
	var pixel_offset := 54
	var file_size := pixel_offset + image_size
	var out := PackedByteArray()
	out.resize(file_size)
	out.fill(0)

	_w16(out, 0, 0x4D42)
	_w32(out, 2, file_size)
	_w32(out, 10, pixel_offset)
	_w32(out, 14, 40)
	_w32(out, 18, width)
	_w32(out, 22, height)
	_w16(out, 26, 1)
	_w16(out, 28, 24)
	_w32(out, 30, 0)
	_w32(out, 34, image_size)
	_w32(out, 38, 0)
	_w32(out, 42, 0)
	_w32(out, 46, 0)
	_w32(out, 50, 0)

	for y in height:
		var src_y := height - 1 - y
		var row := pixel_offset + y * stride
		for x in width:
			var c := img.get_pixel(x, src_y)
			out[row + x * 3] = int(round(c.b * 255.0))
			out[row + x * 3 + 1] = int(round(c.g * 255.0))
			out[row + x * 3 + 2] = int(round(c.r * 255.0))

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_buffer(out)
	file.close()
	return OK


# ══════════════════════════════════════════════
#  UTILIDADES BMP / BINARIO
# ══════════════════════════════════════════════

func _u16(data: PackedByteArray, offset: int) -> int:
	return int(data[offset]) | (int(data[offset + 1]) << 8)


func _u32(data: PackedByteArray, offset: int) -> int:
	return int(data[offset]) | (int(data[offset + 1]) << 8) | (int(data[offset + 2]) << 16) | (int(data[offset + 3]) << 24)


func _i32(data: PackedByteArray, offset: int) -> int:
	var v := _u32(data, offset)
	if v >= 0x80000000:
		return v - 0x100000000
	return v


func _w16(data: PackedByteArray, offset: int, value: int) -> void:
	data[offset] = value & 0xFF
	data[offset + 1] = (value >> 8) & 0xFF


func _w32(data: PackedByteArray, offset: int, value: int) -> void:
	data[offset] = value & 0xFF
	data[offset + 1] = (value >> 8) & 0xFF
	data[offset + 2] = (value >> 16) & 0xFF
	data[offset + 3] = (value >> 24) & 0xFF


func _get_extension(fmt_idx: int) -> String:
	match fmt_idx:
		0: return "bmp"
		1: return "png"
		2: return "jpg"
		3: return "webp"
		4: return "exr"
		5: return "dds"
	return "bmp"


func _save_image(img: Image, path: String, fmt_idx: int) -> Error:
	match fmt_idx:
		1: return img.save_png(path)
		2: return img.save_jpg(path, 0.92)
		3: return img.save_webp(path, false, 0.92)
		4: return img.save_exr(path, false)
		5: return img.save_dds(path)
	return _write_bmp24_from_image(img, path)


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
	return 4096


func _get_interpolation(idx: int) -> Image.Interpolation:
	match idx:
		1: return Image.INTERPOLATE_NEAREST
		2: return Image.INTERPOLATE_BILINEAR
		3: return Image.INTERPOLATE_CUBIC
		4: return Image.INTERPOLATE_LANCZOS
	return Image.INTERPOLATE_NEAREST


func _set_item_color(idx: int, color: Color) -> void:
	if idx < item_list.get_item_count():
		item_list.set_item_custom_fg_color(idx, color)


func _set_status(msg: String, color: Color = Color.WHITE) -> void:
	if is_instance_valid(lbl_status):
		lbl_status.text = msg
		lbl_status.modulate = color


# ══════════════════════════════════════════════
#  CONFIGURACIÓN
# ══════════════════════════════════════════════

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
		return

	input_folder = config.get_value("paths", "input_folder", "")
	output_folder = config.get_value("paths", "output_folder", "")

	if not input_folder.is_empty() and DirAccess.dir_exists_absolute(input_folder):
		lbl_input.text = input_folder
		lbl_input.tooltip_text = input_folder
		btn_scan.disabled = false

	if not output_folder.is_empty():
		lbl_output.text = output_folder
		lbl_output.tooltip_text = output_folder

	var loaded_keep_ar := config.get_value("settings", "keep_ar", false) as bool
	var loaded_subfolders := config.get_value("settings", "subfolders", true) as bool
	var loaded_overwrite := config.get_value("settings", "overwrite", true) as bool
	var loaded_format := config.get_value("settings", "format", 0) as int
	var loaded_interp := config.get_value("settings", "interpolation", 0) as int
	call_deferred("_apply_loaded_config", loaded_keep_ar, loaded_subfolders, loaded_overwrite, loaded_format, loaded_interp)


func _apply_loaded_config(keep: bool, sub: bool, over: bool, fmt: int, inter: int) -> void:
	check_keep_ar.button_pressed = keep
	check_subfolders.button_pressed = sub
	check_overwrite.button_pressed = over
	opt_format.selected = clampi(fmt, 0, opt_format.item_count - 1)
	opt_interp.selected = clampi(inter, 0, opt_interp.item_count - 1)
	auto_mode = true
	spin_width.editable = false
	spin_height.editable = false
	check_keep_ar.disabled = true


func _on_btn_open_output_pressed() -> void:
	if output_folder.is_empty():
		return
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
	_save_config()


func _on_spin_height_value_changed(value: float) -> void:
	if check_keep_ar.button_pressed:
		spin_width.set_value_no_signal(value)
	_save_config()
