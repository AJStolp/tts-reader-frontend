import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const TtsPage({super.key});

  @override
  TtsPageState createState() => TtsPageState();
}

class TtsPageState extends State<TtsPage> {
  final TextEditingController _textController = TextEditingController();
  String _selectedVoice = 'Joanna'; // Default voice
  String? _audioUrl; // URL of the audio file
  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Function to send a TTS request
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

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _audioUrl = data['audio_url'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate TTS')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to play the generated audio
  void playAudio() async {
    if (_audioUrl != null) {
      await _audioPlayer.play(_audioUrl!);
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
            if (_audioUrl != null)
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
