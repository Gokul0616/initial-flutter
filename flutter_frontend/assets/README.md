# Assets Directory

This directory contains static assets for the Flutter app:

## Structure

```
assets/
├── images/          # App images and illustrations
├── icons/           # Custom icons and graphics
├── animations/      # Lottie animation files
└── fonts/           # Custom fonts (Proxima Nova)
```

## Usage

Assets are defined in `pubspec.yaml` and can be used throughout the app:

```dart
// Images
Image.asset('assets/images/logo.png')

// Animations
Lottie.asset('assets/animations/loading.json')

// Icons
SvgPicture.asset('assets/icons/custom_icon.svg')
```

## Font Loading

Custom fonts are loaded automatically from the fonts directory as defined in pubspec.yaml.