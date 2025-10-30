# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application for event management. The project is currently in its initial state with the default Flutter template.

**Project Name:** event_management
**Flutter SDK:** 3.9.4+
**Working Directory:** `event_management/` (all Flutter commands must be run from this subdirectory)

## Common Commands

All commands must be run from the `event_management/` directory:

```bash
cd event_management
```

### Development Commands

- **Run the app:** `flutter run`
- **Run on specific device:** `flutter run -d <device_id>`
- **List devices:** `flutter devices`
- **Hot reload:** Press `r` in the terminal while app is running
- **Hot restart:** Press `R` in the terminal while app is running

### Build Commands

- **Build for Android:** `flutter build apk`
- **Build for iOS:** `flutter build ios`
- **Build for web:** `flutter build web`
- **Build for Linux:** `flutter build linux`
- **Build for macOS:** `flutter build macos`
- **Build for Windows:** `flutter build windows`

### Testing and Analysis

- **Run all tests:** `flutter test`
- **Run specific test file:** `flutter test test/widget_test.dart`
- **Analyze code:** `flutter analyze`
- **Check for outdated dependencies:** `flutter pub outdated`

### Dependency Management

- **Install dependencies:** `flutter pub get`
- **Upgrade dependencies:** `flutter pub upgrade`
- **Add a package:** `flutter pub add <package_name>`
- **Remove a package:** `flutter pub remove <package_name>`

### Clean and Reset

- **Clean build files:** `flutter clean`
- **Full reset:** `flutter clean && flutter pub get`

## Architecture

This is a standard Flutter project with the following structure:

- **lib/main.dart** - Entry point and main application widget
- **test/** - Widget and unit tests
- **android/** - Android-specific native code
- **ios/** - iOS-specific native code
- **web/** - Web-specific configuration
- **linux/**, **macos/**, **windows/** - Desktop platform configurations

### Code Quality

The project uses `flutter_lints` (v5.0.0) for static analysis with the recommended Flutter lint rules enabled via `analysis_options.yaml`.
