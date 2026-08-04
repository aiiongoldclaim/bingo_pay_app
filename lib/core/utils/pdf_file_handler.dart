import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

/// Opens or shares a downloaded PDF's raw [bytes].
///
/// Android's share sheet is a poor fit for "download the invoice" — save it
/// to app storage and open it directly in the user's PDF viewer instead.
/// Elsewhere (iOS, etc.) there's no equivalent "default PDF viewer" concept,
/// so the OS share sheet is used.
Future<void> openOrSharePdf(List<int> bytes, String filename) async {
  final pdfBytes = Uint8List.fromList(bytes);

  if (Platform.isAndroid) {
    final dir = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(pdfBytes, flush: true);
    await OpenFilex.open(file.path);
  } else {
    await Printing.sharePdf(bytes: pdfBytes, filename: filename);
  }
}
