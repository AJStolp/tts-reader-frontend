import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';

/// A custom StreamAudioSource implementation for streaming raw audio bytes
class CustomStreamAudioSource extends StreamAudioSource {
  final Future<Stream<Uint8List>> Function() streamBuilder;

  CustomStreamAudioSource(this.streamBuilder);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final audioStream = await streamBuilder();
    return StreamAudioResponse(
      sourceLength: null, // Unknown total length for stream
      offset: start ?? 0,
      contentLength: end != null ? end - (start ?? 0) : null,
      stream: audioStream,
      contentType: 'audio/mpeg',
    );
  }
}
