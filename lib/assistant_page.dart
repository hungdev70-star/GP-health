import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

const _navy = Color(0xFF17364D);
const _teal = Color(0xFF087E78);

class AssistantPage extends StatefulWidget {
  const AssistantPage({
    super.key,
    required this.onOpenMedicines,
    required this.onOpenFamily,
  });

  final VoidCallback onOpenMedicines;
  final VoidCallback onOpenFamily;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  bool _available = false;
  bool _listening = false;
  bool _speaking = false;
  String _heard = '';
  String _reply = 'Namaste! Tap the microphone and tell me how I can help.';
  String _status = 'Checking microphone and speech support…';

  @override
  void initState() {
    super.initState();
    _initialise();
  }

  Future<void> _initialise() async {
    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      final ready = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          setState(() {
            _listening = status == 'listening';
            if (status == 'done' || status == 'notListening') {
              _listening = false;
              _status = _available
                  ? 'Tap the microphone to speak again.'
                  : 'Speech recognition is unavailable on this device.';
            }
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _listening = false;
            _status = 'Speech error: ${error.errorMsg}. You can type instead.';
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _available = ready;
        _status = ready
            ? 'Ready. Tap the microphone and speak.'
            : 'Speech recognition is unavailable. You can type instead.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = 'Voice setup failed. You can type instead.');
    }
  }

  Future<void> _startListening() async {
    if (!_available || _listening) return;
    await _tts.stop();
    setState(() {
      _heard = '';
      _status = 'Listening…';
    });
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _heard = result.recognizedWords);
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          _handleCommand(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      localeId: 'en_IN',
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (mounted) setState(() => _listening = false);
  }

  Future<void> _say(String message) async {
    if (!mounted) return;
    setState(() {
      _reply = message;
      _status = 'Speaking…';
      _speaking = true;
    });
    try {
      await _tts.stop();
      await _tts.speak(message);
    } catch (_) {
      // The written reply remains available if this device has no TTS voice.
    }
    if (mounted) {
      setState(() {
        _speaking = false;
        _status = 'Ready. Tap the microphone to speak again.';
      });
    }
  }

  Future<void> _handleCommand(String raw) async {
    final command = raw.toLowerCase().trim();
    if (command.isEmpty) return;

    if (command.contains('medicine') || command.contains('medication') ||
        command.contains('tablet') || command.contains('pills')) {
      await _say('Opening your medicines. You can review your list and record a dose.');
      if (mounted) widget.onOpenMedicines();
      return;
    }
    if (command.contains('family') || command.contains('contact') ||
        command.contains('emergency') || command.contains('sos') ||
        command.contains('call')) {
      await _say('Opening your family contacts. I will never place a call without your confirmation.');
      if (mounted) widget.onOpenFamily();
      return;
    }
    if (command.contains('hello') || command.contains('hi') ||
        command.contains('namaste')) {
      await _say('Namaste! I am your GP Health helper. I can open your medicines or family contacts.');
      return;
    }
    if (command.contains('help')) {
      await _say('You can say: open my medicines, show my family, or help. You can also type below.');
      return;
    }
    await _say('I heard: $raw. I am still learning. For now, ask me to open your medicines, show your family, or say help.');
  }

  Future<void> _submitTyped() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    await _handleCommand(text);
  }

  @override
  void dispose() {
    _speech.cancel();
    _tts.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk to GP Health', style: TextStyle(fontWeight: FontWeight.bold, color: _navy)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Namaste! 👋', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _navy)),
            const SizedBox(height: 8),
            const Text('I am here to help. Speak or type below.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(24)),
              child: Column(children: [
                Icon(_listening ? Icons.graphic_eq : Icons.mic, color: Colors.white, size: 42),
                const SizedBox(height: 12),
                Text(_listening ? 'I am listening…' : 'Tap to speak', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  width: 150,
                  height: 150,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _listening ? const Color(0xFFB3261E) : Colors.white,
                      foregroundColor: _listening ? Colors.white : _teal,
                      shape: const CircleBorder(),
                    ),
                    onPressed: _available ? (_listening ? _stopListening : _startListening) : _initialise,
                    child: Icon(_listening ? Icons.stop : Icons.mic, size: 66),
                  ),
                ),
                const SizedBox(height: 14),
                Text(_status, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              ]),
            ),
            const SizedBox(height: 18),
            if (_heard.isNotEmpty)
              Card(color: Colors.white, child: ListTile(
                leading: const Icon(Icons.hearing, color: _teal),
                title: const Text('I heard'),
                subtitle: Text(_heard, style: const TextStyle(fontSize: 17)),
              )),
            Card(color: Colors.white, child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('GP Health says', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _teal)),
                const SizedBox(height: 8),
                Text(_reply, style: const TextStyle(fontSize: 19, color: _navy)),
                if (_speaking)
                  const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
              ]),
            )),
            const SizedBox(height: 18),
            TextField(
              controller: _textController,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitTyped(),
              decoration: InputDecoration(
                hintText: 'Type a message',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                suffixIcon: IconButton(
                  tooltip: 'Send',
                  onPressed: _submitTyped,
                  icon: const Icon(Icons.send),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Try saying:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const Text('“Open my medicines”  •  “Show my family”  •  “Help”', style: TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 12),
            const Text('First prototype: speech recognition depends on the phone’s speech service and internet may be required. Replies are currently limited to built-in commands; connected generative AI and offline wake-word listening are not enabled yet.', style: TextStyle(color: Color(0xFF526777), height: 1.45)),
          ],
        ),
      ),
    );
  }
}
