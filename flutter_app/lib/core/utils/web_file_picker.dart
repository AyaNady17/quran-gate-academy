import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

/// Web-specific file picker that works on Flutter Web
class WebFilePicker {
  /// Pick a single file on web
  static Future<WebPickedFile?> pickFile() async {
    final completer = Completer<WebPickedFile?>();

    // Create file input element
    final input = web.document.createElement('input') as web.HTMLInputElement;
    input.type = 'file';

    // Listen for file selection
    input.addEventListener('change', (web.Event event) {
      final files = input.files;
      if (files == null || files.length == 0) {
        completer.complete(null);
        return;
      }

      final file = files.item(0)!;
      final reader = web.FileReader();

      reader.addEventListener('load', (web.Event e) {
        final result = reader.result;
        if (result != null) {
          final jsArrayBuffer = result as JSArrayBuffer;
          final bytes = jsArrayBuffer.toDart.asUint8List();

          completer.complete(WebPickedFile(
            bytes: bytes,
            name: file.name,
          ));
        } else {
          completer.complete(null);
        }
      }.toJS);

      reader.readAsArrayBuffer(file);
    }.toJS);

    // Trigger file picker
    input.click();

    return completer.future;
  }
}

/// Represents a picked file on web
class WebPickedFile {
  final Uint8List bytes;
  final String name;

  WebPickedFile({
    required this.bytes,
    required this.name,
  });

  String? get extension {
    final parts = name.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return null;
  }
}

