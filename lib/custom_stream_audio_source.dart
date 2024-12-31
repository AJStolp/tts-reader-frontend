import 'dart:async';
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';

class CustomStreamAudioSource extends StreamAudioSource {
  final FutureOr<Stream<Uint8List>> Function() streamFactory;

  CustomStreamAudioSource(this.streamFactory);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final stream = await streamFactory();
    return StreamAudioResponse(
      sourceLength: null, // Unknown length
      contentLength: null, // Unknown content length
      offset: start ?? 0, // Start offset for the audio stream
      stream: stream,
      contentType: 'audio/mpeg',
    );
  }
}
