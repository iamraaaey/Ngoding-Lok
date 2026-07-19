import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<bool> downloadPdfBytes({
  required Uint8List bytes,
  required String filename,
}) async {
  final pdfFile = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final pdfUrl = web.URL.createObjectURL(pdfFile);
  final document = web.window.document;
  final link = web.HTMLAnchorElement()
    ..href = pdfUrl
    ..download = filename
    ..style.display = 'none';

  try {
    document.body?.append(link);
    link.click();
    return true;
  } finally {
    link.remove();
    web.URL.revokeObjectURL(pdfUrl);
  }
}
