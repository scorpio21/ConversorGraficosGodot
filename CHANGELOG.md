# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-09-14

### Added
- Added EXR (HDR) format support for output
- Added DDS format support for output
- Updated format options to include EXR and DDS
- Improved format documentation in README

### Fixed
- Fixed format output options to match Godot 4 capabilities
- Removed incorrect BMP output format (not available in Godot 4)
- Updated save_image function to use correct save methods

## [1.0.0] - 2026-09-14

### Added
- Initial release of Conversor de Gráficos
- Multiple input format support (BMP, PNG, JPG, JPEG, TGA, WebP)
- Multiple output format support (PNG, JPG, WebP)
- Customizable resize dimensions (1-4096px)
- Multiple interpolation methods (Nearest, Bilinear, Cubic, Lanczos)
- Recursive folder scanning with subfolder option
- Quick size presets (16×16, 32×32, 48×48, 64×64, 128×128, 256×256, 512×512)
- Aspect ratio preservation option
- Real-time progress bar and file counter
- Modern dark theme interface
- Organized project structure (assets, autoload, scenes, scripts)
- MIT License

### Fixed
- Fixed FileDialog configuration for folder selection
- Fixed UI layout margins to prevent control clipping
- Fixed StyleBoxFlat anti_aliased property compatibility issue
- Fixed project file paths after reorganization

### Changed
- Reorganized project structure into standard Godot folders
- Increased default window size (1000×680) for better UI fit
- Updated project configuration for Godot 4.7
- Improved file scanning and conversion logic

### Technical
- Project built with Godot 4.7
- Uses GDScript for all logic
- Custom theme system via autoload ThemeManager
- Proper .gitignore for Godot projects
