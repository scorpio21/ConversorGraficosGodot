# Conversor de Gráficos

Conversor de imágenes masivo desarrollado en Godot 4.7. Permite redimensionar y convertir archivos de gráficos entre diferentes formatos de manera eficiente.

![Godot](https://img.shields.io/badge/Godot-4.7-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Características

- 🎨 **Múltiples formatos de entrada**: BMP, PNG, JPG, JPEG, TGA, WebP
- 📦 **Formatos de salida**: PNG, BMP, JPG, WebP
- 📐 **Redimensionamiento personalizado**: Ancho y alto configurables (1-4096px)
- 🔄 **Métodos de interpolación**: Nearest, Bilineal, Cúbica, Lanczos
- 📁 **Escaneo recursivo**: Incluir subcarpetas automáticamente
- 🎯 **Presets rápidos**: 16×16, 32×32, 48×48, 64×64, 128×128, 256×256, 512×512
- ⚖️ **Mantener proporción**: Opción para preservar el aspect ratio
- 📊 **Progreso en tiempo real**: Barra de progreso y contador de archivos
- 🎨 **Interfaz moderna**: Tema oscuro elegante

## Requisitos

- Godot 4.7 o superior
- Windows, Linux o macOS

## Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/scorpio21/ConversorGraficosGodot.git
cd ConversorGraficosGodot
```

2. Abre el proyecto en Godot 4.7:
- File → Open → Selecciona la carpeta del proyecto

3. Ejecuta el proyecto:
- Presiona F5 o clic en el botón "Play"

## Uso

1. **Seleccionar carpeta de entrada**: Clic en "📂 Seleccionar..." para elegir la carpeta con los gráficos
2. **Seleccionar carpeta de salida**: Clic en "📂 Seleccionar..." para elegir dónde guardar los archivos convertidos
3. **Configurar opciones**:
   - Tamaño de destino (ancho × alto)
   - Formato de salida
   - Método de interpolación
   - Presets rápidos
   - Incluir subcarpetas
   - Sobrescribir existentes
4. **Escanear archivos**: Clic en "🔍 Escanear carpeta" para buscar archivos compatibles
5. **Convertir**: Clic en "▶ Convertir todo" para iniciar el proceso

## Proyecto Organizado

El proyecto sigue una estructura organizada:

```
ConversorGraficosGodot/
├── assets/          # Recursos del proyecto
├── autoload/        # Scripts globales (ThemeManager)
├── scenes/          # Escenas de la interfaz
├── scripts/         # Lógica del proyecto
└── project.godot    # Configuración del proyecto
```

## Créditos

- **Desarrollado por**: Scorpio
- **Basado en**: Conversor de gráficos BMP original de Shackox (VB6)
- **Agradecimientos**: Gracias a Blizzard por liberar el código original

## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Changelog

Ver [CHANGELOG.md](CHANGELOG.md) para el historial de cambios.
