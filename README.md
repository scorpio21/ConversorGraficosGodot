# Conversor de Gráficos

**Versión actual: 1.1**

Conversor de gráficos desarrollado en **Godot 4.7**, basado en el conversor de gráficos BMP original de Shackox (VB6). Está orientado especialmente al procesamiento de gráficos de **Argentum Online**.

![Godot](https://img.shields.io/badge/Godot-4.7-blue.svg)
![Version](https://img.shields.io/badge/Version-1.1-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Características

- 🎨 **Formatos de entrada**: BMP, PNG, JPG, JPEG, TGA y WebP.
- 🎯 **Modo BMP 8-bit (AO)**: lectura directa de BMP de 8 bits con paleta.
- 🎨 **Paleta BMP**: conserva las 256 entradas de la paleta y los índices de píxel cuando la entrada es BMP 8-bit.
- ⬛ **Lienzo cuadrado**: calcula automáticamente 32, 64, 128, 256, 512, 1024, 2048 o 4096 píxeles según la mayor dimensión original.
- 📍 **Comportamiento VB6/AO**: en el modo BMP 8-bit la imagen original no se escala; se copia desde `(0,0)` sobre un fondo negro.
- 📦 **Formatos de salida**: BMP 8-bit (AO), PNG, JPG, WebP, EXR y DDS.
- 📁 **Escaneo recursivo**: permite incluir subcarpetas y conservar su estructura relativa en la salida.
- 🔄 **Sobrescritura**: permite reemplazar archivos existentes o conservarlos.
- 📊 **Progreso en tiempo real**: barra de progreso, contador y estado del archivo actual.
- 💾 **Persistencia de configuración**: recuerda carpetas y opciones utilizadas.
- 🚀 **Escaneo automático al iniciar**: si la carpeta guardada sigue existiendo, se escanea automáticamente.
- ❓ **Menú Ayuda**: explica de forma clara las funciones de cada opción.
- 🕒 **Barra de estado**: muestra la hora actual a la izquierda y la versión a la derecha.
- 🌙 **Interfaz moderna**: tema oscuro adaptado a Godot 4.7.

## Versión

La versión se define en un único punto del proyecto:

```ini
config/version="1.1"
```

Está en `project.godot`. La interfaz lee automáticamente este valor y muestra `Versión 1.1` en la barra de estado.

Al publicar una nueva versión, basta con cambiar ese valor en `project.godot`.

## Requisitos

- Godot 4.7 o superior.
- Windows, Linux o macOS.

## Instalación

1. Clona el repositorio:

```bash
git clone https://github.com/scorpio21/ConversorGraficosGodot.git
cd ConversorGraficosGodot
```

2. Abre la carpeta del proyecto en Godot 4.7.
3. Ejecuta el proyecto con **F6/F5** o mediante el botón de ejecutar.

## Uso

### 1. Carpeta de entrada

Pulsa **Seleccionar...** y elige la carpeta que contiene los gráficos.

Si la ruta ya estaba guardada y continúa existiendo, el programa la carga automáticamente al iniciar y realiza un escaneo inicial.

### 2. Carpeta de salida

Selecciona dónde quieres guardar los resultados. Si no existe una salida guardada, el programa propone una carpeta de salida junto a la carpeta de entrada.

### 3. Escanear carpeta

**Escanear carpeta** vuelve a analizar la carpeta de entrada y actualiza la lista de archivos encontrados.

También se ejecuta automáticamente al iniciar cuando existe una carpeta de entrada válida guardada.

### 4. Tamaño

Los presets permiten seleccionar rápidamente tamaños habituales:

- 16×16
- 32×32
- 48×48
- 64×64
- 128×128
- 256×256
- 512×512

En el modo **BMP 8-bit (AO)**, el tamaño final se calcula automáticamente según la mayor dimensión del BMP, siguiendo el comportamiento del conversor VB6 original.

### 5. Formato BMP 8-bit (AO)

Es el modo recomendado para los gráficos BMP de Argentum Online que utilizan 8 bits y paleta.

Cuando la entrada es un BMP 8-bit:

1. Se lee directamente la cabecera BMP.
2. Se lee la paleta.
3. Se leen los índices de píxel respetando el padding de cada fila.
4. Se calcula el nuevo tamaño cuadrado.
5. Se crea un fondo negro.
6. El gráfico original se copia en `(0,0)` sin escalar.
7. Se genera un nuevo BMP 8-bit con una paleta de 256 entradas.

Esto evita utilizar un `resize()` de Godot para el gráfico original y evita perder la información de la paleta durante esa conversión.

### 6. Redimensionado e interpolación

En los formatos normales (**PNG, JPG, WebP, EXR y DDS**) los campos **Ancho** y **Alto** están activos y permiten definir el tamaño de salida.

- **Mantener proporción** conserva la relación de aspecto original al calcular el nuevo tamaño.
- **Nearest (pixel-art)** mantiene los bordes duros y es recomendable para gráficos de estilo pixel-art.
- **Bilineal**, **Cúbica** y **Lanczos** aplican distintos métodos de interpolación durante el redimensionado.
- **Sin escalado (VB6/AO)** conserva las dimensiones originales y no redimensiona la imagen.

En **BMP 8-bit (AO)** estas opciones quedan desactivadas porque ese modo utiliza el comportamiento automático compatible con VB6: calcula el lienzo cuadrado, copia el gráfico original en `(0,0)` y no aplica resize ni interpolación.

### 7. Incluir subcarpetas

Si está activada, el escaneo entra en las carpetas inferiores y conserva la estructura relativa al generar la salida.

### 8. Sobreescribir existentes

- Activada: reemplaza archivos que ya existen en la salida.
- Desactivada: omite los archivos existentes.

### 9. Convertir todo

Procesa todos los archivos encontrados y muestra el progreso y el resultado de cada archivo.

### 10. Barra de estado

La barra inferior muestra:

- **Izquierda:** hora actual del sistema.
- **Derecha:** versión actual del programa.

La hora se actualiza cada segundo y la versión se obtiene directamente de `project.godot`.

## Estructura del proyecto

```text
ConversorGraficosGodot/
├── assets/          # Recursos e iconos
├── autoload/        # ThemeManager
├── scenes/          # Escena principal
├── scripts/         # Lógica del conversor
├── project.godot    # Configuración y versión del proyecto
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## Créditos

- **Desarrollado por:** Scorpio
- **Basado en:** Conversor de gráficos BMP original de Shackox (VB6)
- **Agradecimientos:** Gracias a Blizzard por liberar el código original.

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta [LICENSE](LICENSE) para más detalles.

## Changelog

Consulta [CHANGELOG.md](CHANGELOG.md) para conocer los cambios de cada versión.
