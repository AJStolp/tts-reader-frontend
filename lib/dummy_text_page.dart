import 'package:flutter/material.dart';
import 'package:web_text_reader/web_text_reader.dart';

class DummyTextPage extends StatelessWidget {
  const DummyTextPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dummy Text Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This is a dummy text page for testing the WebTextReaderWidget.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Flutter is an open-source UI software development toolkit created by Google. It is used to develop cross-platform applications for Android, iOS, Linux, macOS, Windows, and the web from a single codebase.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const WebTextReaderWidget(), // Add the widget here
          ],
        ),
      ),
    );
  }
}
