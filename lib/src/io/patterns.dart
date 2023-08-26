class Patterns {
  static const String defaultLineSeparator = "\n";

  static const String lineSeparatorPattern = "[\\n\\r]+";

  static final RegExp propertyPattern =
      RegExp(r'^[ \t]*([a-zA-Z0-9]+)[ \t]*=[ \t]*\"?([^"]*)\"?');

  static final RegExp tierPattern =
      RegExp("^[ \t]*item[ \t]*\\[[0-9]+\\][ \t]*:.*");

  static final RegExp intervalsPattern =
      RegExp("^[ \t]*intervals[ \t]*:[ \t]*size[ \t]*=[ \t]*([0-9]+)");

  static final RegExp intervalItemPattern =
      RegExp("^[ \t]*intervals[ \t]*\\[[0-9]+\\][ \t]*:.*");

  static final RegExp pointsPattern =
      RegExp("^[ \t]*points[ \t]*:[ \t]*size[ \t]*=[ \t]*([0-9]+)");

  static final RegExp pointItemPattern =
      RegExp("^[ \t]*points[ \t]*\\[[0-9]+\\][ \t]*:.*");
}
