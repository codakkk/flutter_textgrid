import 'dart:io';

class TextGridIOException extends IOException {
  final String message;

  final String fileName;
  final int line;

  TextGridIOException({
    required String message,
    this.fileName = "",
    this.line = -1,
  })  : assert(
          fileName.isEmpty && line == -1 || fileName.isNotEmpty && line != -1,
          "Both fileName and line must be provided if one is used.",
        ),
        message = fileName.isNotEmpty ? "$fileName($line): $message" : message;
}
