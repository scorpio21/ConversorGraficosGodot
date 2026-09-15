# Changelog

## [1.1] - 2026-09-15

### Fixed
- Corregida la opción **Interpolación**, que anteriormente se mostraba pero no participaba en el redimensionado.
- Corregida la opción **Mantener proporción**, que anteriormente permanecía desactivada y no se aplicaba al convertir.
- Los campos **Ancho** y **Alto** ahora son editables en los formatos normales.
- Los presets de tamaño ahora funcionan para los formatos normales.

### Added
- Redimensionado real para PNG, JPG, WebP, EXR y DDS usando el método de interpolación seleccionado.
- Modo **Sin escalado** para conservar las dimensiones originales en los formatos normales.
- Ajuste automático de ancho/alto cuando **Mantener proporción** está activado.
- La interfaz activa o desactiva visualmente las opciones según el formato seleccionado.
- El modo **BMP 8-bit (AO)** mantiene su comportamiento automático y compatible con VB6, sin resize ni interpolación.

### Changed
- La versión del proyecto pasa a **1.1**.
- El formato **BMP 8-bit (AO)** desactiva Ancho, Alto, Mantener proporción, Interpolación y presets porque esas opciones no corresponden al flujo automático AO.
- Los formatos normales generan ahora exactamente las dimensiones configuradas, salvo cuando se usa **Sin escalado** o cuando **Mantener proporción** ajusta una de ellas para conservar la relación de aspecto.

Todos los cambios importantes de este proyecto se documentan en este archivo.

El proyecto utiliza [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0] - 2026-09-15

### Added
- Primera versión estable del Conversor de Gráficos para Godot 4.7.
- Selección de carpeta de entrada y carpeta de salida.
- Persistencia de las rutas y opciones de configuración.
- Escaneo manual y escaneo automático al iniciar cuando la ruta guardada es válida.
- Escaneo opcional de subcarpetas.
- Lista de archivos detectados y contador.
- Conversión masiva con barra de progreso y estado del archivo actual.
- Opción para sobrescribir archivos existentes.
- Presets de tamaño 16×16, 32×32, 48×48, 64×64, 128×128, 256×256 y 512×512.
- Modos de salida PNG, JPG, WebP, EXR y DDS.
- Modo **BMP 8-bit (AO)** específico para gráficos de Argentum Online.
- Lectura directa de BMP 8-bit con paleta de hasta 256 colores.
- Conservación de la paleta y de los índices de píxel en la salida BMP 8-bit.
- Soporte de padding de filas BMP y BMP bottom-up/top-down en el lector 8-bit.
- Creación de lienzo cuadrado con fondo negro siguiendo el comportamiento del conversor VB6 original.
- Copia del gráfico original desde `(0,0)` sin aplicar `resize()` en el modo BMP 8-bit (AO).
- Menú **Ayuda** con explicación de las funciones de la aplicación.
- Barra de estado inferior con hora a la izquierda y versión a la derecha.
- La versión de la interfaz se obtiene automáticamente de `project.godot` mediante `application/config/version`.
- Tema oscuro y estructura organizada del proyecto.

### Fixed
- Corregido el problema por el que las rutas guardadas no activaban el escaneo al iniciar.
- Corregido el escaneo automático de la carpeta de gráficos al arrancar.
- Corregido el comportamiento de BMP 8-bit para evitar perder la paleta mediante una conversión genérica de Godot.
- Corregido el comportamiento del modo AO para no estirar la imagen original.
- Corregido el formato de salida del modo AO para generar BMP en lugar de convertirlo automáticamente a PNG/JPG.
- Corregido el desbordamiento horizontal de las opciones de la interfaz mediante contenedores adaptables.

### Changed
- Se establece **1.0** como versión inicial del programa.
- La versión visible ya no está escrita de forma independiente en la interfaz: se obtiene de `project.godot`.
- La interfaz muestra la hora actual y la versión en una barra de estado inferior.
- El modo BMP 8-bit (AO) queda orientado específicamente a mantener un comportamiento compatible con el conversor VB6 original.

### Technical
- Proyecto desarrollado con Godot 4.7.
- Lógica principal implementada en GDScript.
- `application/config/version="1.0"` es la fuente única de la versión mostrada por la aplicación.
- El modo BMP 8-bit utiliza lectura y escritura binaria directa para preservar paleta e índices.

