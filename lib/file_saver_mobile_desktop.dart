import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String> saveAudio(Uint8List audioBytes) async {
  final tempDir = await getTemporaryDirectory();
  final audioFilePath = '${tempDir.path}/generated_audio.mp3';

  final file = File(audioFilePath);
  await file.writeAsBytes(audioBytes);

  return audioFilePath; // Return file path for playback
}
