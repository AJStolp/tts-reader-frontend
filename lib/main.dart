import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'file_saver.dart'; // Import the conditional file saver
import 'package:audioplayers/audioplayers.dart';

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
  String? _audioSource; // Path or URL to the audio
  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> generateTts() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://127.0.0.1:3000/generate-tts');
    final body = json.encode({
      'text': _textController.text,
      'voice_id': _selectedVoice,
    });

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);

      if (response.statusCode == 200) {
        final audioBytes = response.bodyBytes;

        // Save audio for playback
        final savedAudio = await saveAudio(audioBytes);

        setState(() {
          _audioSource = savedAudio; // Set the source for playback
        });
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

  void playAudio() async {
    if (_audioSource != null) {
      if (_audioSource!.startsWith('http')) {
        await _audioPlayer.play(_audioSource!); // For web, play via URL
      } else {
        await _audioPlayer.play(_audioSource!,
            isLocal: true); // For mobile/desktop, play locally
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio file found.')),
      );
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
              onPressed: _isLoading ? null : generateTts,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Generate TTS'),
            ),
            const SizedBox(height: 16),
            if (_audioSource != null)
              ElevatedButton(
                onPressed: playAudio,
                child: const Text('Play Audio'),
              ),
          ],
        ),
      ),
    );
  }
}
