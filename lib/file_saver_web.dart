import 'dart:typed_data';
import 'dart:html' as html;

Future<String> saveAudio(Uint8List audioBytes) async {
  final blob = html.Blob([audioBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  return url; // Return the blob URL for web playback
}
