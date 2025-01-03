import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart'; // Import just_audio package
import 'custom_stream_audio_source.dart'; // Import the custom audio source

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTS App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TtsPage(),
    );
  }
}

class TtsPage extends StatefulWidget {
  const TtsPage({Key? key}) : super(key: key);

  @override
  _TtsPageState createState() => _TtsPageState();
}

class _TtsPageState extends State<TtsPage> {
  final TextEditingController _textController = TextEditingController();
  String _selectedVoice = 'Joanna'; // Default voice
  final AudioPlayer _audioPlayer = AudioPlayer(); // JustAudio player
  bool _isLoading = false;

  Future<void> generateAndPlayTts() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://127.0.0.1:3000/audio-stream');
    final body = json.encode({
      'text': _textController.text,
      'voice_id': _selectedVoice,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        // Create a Stream from the response body bytes
        final audioStream = Stream<Uint8List>.value(response.bodyBytes);

        // Use the custom StreamAudioSource
        final audioSource = CustomStreamAudioSource(() async => audioStream);

        await _audioPlayer.setAudioSource(audioSource);
        _audioPlayer.play();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate TTS')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text-to-Speech')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedVoice,
              items: const [
                DropdownMenuItem(value: 'Joanna', child: Text('Joanna')),
                DropdownMenuItem(value: 'Matthew', child: Text('Matthew')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedVoice = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : generateAndPlayTts,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Generate and Play TTS'),
            ),
          ],
        ),
      ),
    );
  }
}
