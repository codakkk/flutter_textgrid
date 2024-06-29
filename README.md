<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

From Praat's [documentation](https://www.fon.hum.uva.nl/praat/manual/TextGrid.html), a TextGrid object consists of a number of tiers. There are two kinds of tiers: an interval tier is a connected sequence of labelled intervals, with boundaries in between. A point tier is a sequence of labelled points.

# Index

- [Index](#index)
- [Features](#features)
- [How to use](#how-to-use)
  - [Install](#install)
  - [Create and edit TextGrid](#create-and-edit-textgrid)
  - [Read TextGrid](#read-textgrid)
    - [From String](#from-string)
    - [From File](#from-file)

## Features

- Read and write TextGrid files
- Supports both Long & Short TextGrid [formats](https://www.fon.hum.uva.nl/praat/manual/TextGrid_file_formats.html)
- Manipulate TextGrid objects

# How to use
## Install
To use [flutter_textgrid], install [flutter_textgrid] by adding it to your `pubspec.yaml` file:"

For a Flutter project:

```console
flutter pub add flutter_textgrid
```

For a Dart project:

```console
dart pub add flutter_textgrid
```

## Create and edit TextGrid
```dart
final textGrid = TextGrid(
    startTime: Time.zero,
    endTime: Time(5), // 5 seconds
);

final intervalTier = IntervalTier(name: 'test');
final ia = IntervalAnnotation(
    startTime: Time.zero,
    endTime: const Time(0.5),
    text: 'worda',
);
intervalTier.addAnnotation(ia);

textGrid.addTier(intervalTier);
```
## Read TextGrid
First of all create a [TextGridSerializer](./lib/src/io/text_grid_serializer.dart). It can read both Long and Short format, without any configurations.
### From String
```dart
final tgs = TextGridSerializer();

final tgContent = "...TextGrid...";

final textGrid = tgs.fromString(tgContent);
```
### From file
```dart
final tgs = TextGridSerializer();

final textGrid = tgs.fromFile(File('../path/to/file'));

// Just use your TextGrid file
```

or you can read directly from a path:
```dart
final tgs = TextGridSerializer();

final textGrid = tgs.fromPath('../path/to/file');

// Just use your TextGrid file
```

or you can use the [fromString] method.

```dart
final tgs = TextGridSerializer();

final fileContent = File('../path/to/file').readAsStringSync();

final textGrid = tgs.fromString(fileContent);

// Just use your TextGrid file
```