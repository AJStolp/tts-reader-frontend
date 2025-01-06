import 'package:flutter/material.dart';
import 'dart:html' as html; // For DOM and accessibility traversal
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'custom_stream_audio_source.dart'; // Custom audio source for streaming

class WebTextReaderWidget extends StatefulWidget {
  const WebTextReaderWidget({Key? key}) : super(key: key);

  @override
  _WebTextReaderWidgetState createState() => _WebTextReaderWidgetState();
}

class _WebTextReaderWidgetState extends State<WebTextReaderWidget> {
  String extractedText = '';
  bool isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> words = [];
  int currentWordIndex = 0;

  Future<void> extractAndPlay() async {
    setState(() {
      isPlaying = true;
    });

    try {
      // Step 1: Extract text from the DOM
      final bodyElement = html.document.body;
      if (bodyElement != null) {
        extractedText = extractAccessibleText(bodyElement);
        if (extractedText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No readable content found.')),
          );
          setState(() {
            isPlaying = false;
          });
          return;
        }

        // Step 2: Split text into words for highlighting
        words = extractedText.split(' ');

        // Step 3: Call TTS API
        final url = Uri.parse('http://127.0.0.1:3000/audio-stream');
        final body = json.encode({'text': extractedText, 'voice_id': 'Joanna'});

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          final audioBytes = response.bodyBytes;
          if (audioBytes.isEmpty) {
            throw Exception('TTS API returned an empty audio stream.');
          }

          // Create a CustomStreamAudioSource
          final audioSource = CustomStreamAudioSource(() async {
            // Wrap the audioBytes in a Stream<Uint8List>
            return Stream.value(audioBytes);
          });

          // Set the audio source and play
          await _audioPlayer.setAudioSource(audioSource);
          _audioPlayer.play();

          // Highlight text during playback
          _highlightTextDuringPlayback();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to generate TTS: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isPlaying = false;
      });
    }
  }

  void _highlightTextDuringPlayback() {
    _audioPlayer.positionStream.listen((position) {
      final wordIndex = (position.inMilliseconds / 300).floor();
      if (wordIndex < words.length && wordIndex != currentWordIndex) {
        setState(() {
          currentWordIndex = wordIndex;
        });
      }
    });
  }

  String extractAccessibleText(html.Element element) {
    if (element.getAttribute('aria-hidden') == 'true') {
      return '';
    }

    String text = element.text?.trim() ?? '';
    for (final child in element.children) {
      text += ' ' + extractAccessibleText(child);
    }

    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: isPlaying ? null : extractAndPlay,
          child: isPlaying
              ? const CircularProgressIndicator()
              : const Text('Widget Play'),
        ),
        const SizedBox(height: 16),
        if (words.isNotEmpty)
          Wrap(
            children: List.generate(
              words.length,
              (index) => Text(
                words[index] + ' ',
                style: TextStyle(
                  backgroundColor:
                      index == currentWordIndex ? Colors.yellow : null,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
