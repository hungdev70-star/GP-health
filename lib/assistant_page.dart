import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

const _navy = Color(0xFF17364D);
const _teal = Color(0xFF087E78);

const List<Map<String, String>> _languages = [
  {'name':'Assamese','locale':'as-IN'}, {'name':'Bengali','locale':'bn-IN'},
  {'name':'Bodo','locale':'brx-IN'}, {'name':'Dogri','locale':'doi-IN'},
  {'name':'Gujarati','locale':'gu-IN'}, {'name':'Hindi','locale':'hi-IN'},
  {'name':'Kannada','locale':'kn-IN'}, {'name':'Kashmiri','locale':'ks-IN'},
  {'name':'Konkani','locale':'kok-IN'}, {'name':'Maithili','locale':'mai-IN'},
  {'name':'Malayalam','locale':'ml-IN'}, {'name':'Manipuri (Meitei)','locale':'mni-IN'},
  {'name':'Marathi','locale':'mr-IN'}, {'name':'Nepali','locale':'ne-IN'},
  {'name':'Odia','locale':'or-IN'}, {'name':'Punjabi','locale':'pa-IN'},
  {'name':'Sanskrit','locale':'sa-IN'}, {'name':'Santali','locale':'sat-IN'},
  {'name':'Sindhi','locale':'sd-IN'}, {'name':'Tamil','locale':'ta-IN'},
  {'name':'Telugu','locale':'te-IN'}, {'name':'Urdu','locale':'ur-IN'},
  {'name':'English (India)','locale':'en-IN'}, {'name':'English (US)','locale':'en-US'},
  {'name':'English (UK)','locale':'en-GB'}, {'name':'Arabic','locale':'ar-SA'},
  {'name':'French','locale':'fr-FR'}, {'name':'Spanish','locale':'es-ES'},
  {'name':'Portuguese','locale':'pt-PT'}, {'name':'German','locale':'de-DE'},
  {'name':'Italian','locale':'it-IT'}, {'name':'Dutch','locale':'nl-NL'},
  {'name':'Russian','locale':'ru-RU'}, {'name':'Ukrainian','locale':'uk-UA'},
  {'name':'Polish','locale':'pl-PL'}, {'name':'Czech','locale':'cs-CZ'},
  {'name':'Slovak','locale':'sk-SK'}, {'name':'Hungarian','locale':'hu-HU'},
  {'name':'Romanian','locale':'ro-RO'}, {'name':'Bulgarian','locale':'bg-BG'},
  {'name':'Greek','locale':'el-GR'}, {'name':'Turkish','locale':'tr-TR'},
  {'name':'Persian','locale':'fa-IR'}, {'name':'Hebrew','locale':'he-IL'},
  {'name':'Swahili','locale':'sw-KE'}, {'name':'Amharic','locale':'am-ET'},
  {'name':'Somali','locale':'so-SO'}, {'name':'Yoruba','locale':'yo-NG'},
  {'name':'Igbo','locale':'ig-NG'}, {'name':'Hausa','locale':'ha-NG'},
  {'name':'Zulu','locale':'zu-ZA'}, {'name':'Afrikaans','locale':'af-ZA'},
  {'name':'Xhosa','locale':'xh-ZA'}, {'name':'Japanese','locale':'ja-JP'},
  {'name':'Korean','locale':'ko-KR'}, {'name':'Chinese (Mandarin)','locale':'zh-CN'},
  {'name':'Chinese (Taiwan)','locale':'zh-TW'}, {'name':'Cantonese','locale':'yue-HK'},
  {'name':'Thai','locale':'th-TH'}, {'name':'Vietnamese','locale':'vi-VN'},
  {'name':'Indonesian','locale':'id-ID'}, {'name':'Malay','locale':'ms-MY'},
  {'name':'Filipino','locale':'fil-PH'}, {'name':'Burmese','locale':'my-MM'},
  {'name':'Khmer','locale':'km-KH'}, {'name':'Lao','locale':'lo-LA'},
  {'name':'Mongolian','locale':'mn-MN'}, {'name':'Kazakh','locale':'kk-KZ'},
  {'name':'Uzbek','locale':'uz-UZ'}, {'name':'Azerbaijani','locale':'az-AZ'},
  {'name':'Armenian','locale':'hy-AM'}, {'name':'Georgian','locale':'ka-GE'},
  {'name':'Danish','locale':'da-DK'}, {'name':'Swedish','locale':'sv-SE'},
  {'name':'Norwegian','locale':'no-NO'}, {'name':'Finnish','locale':'fi-FI'},
  {'name':'Icelandic','locale':'is-IS'}, {'name':'Irish','locale':'ga-IE'},
  {'name':'Welsh','locale':'cy-GB'}, {'name':'Basque','locale':'eu-ES'},
  {'name':'Catalan','locale':'ca-ES'}, {'name':'Galician','locale':'gl-ES'},
  {'name':'Serbian','locale':'sr-RS'}, {'name':'Croatian','locale':'hr-HR'},
  {'name':'Slovenian','locale':'sl-SI'}, {'name':'Albanian','locale':'sq-AL'},
  {'name':'Macedonian','locale':'mk-MK'}, {'name':'Lithuanian','locale':'lt-LT'},
  {'name':'Latvian','locale':'lv-LV'}, {'name':'Estonian','locale':'et-EE'},
  {'name':'Belarusian','locale':'be-BY'}, {'name':'Bosnian','locale':'bs-BA'},
  {'name':'Pashto','locale':'ps-AF'}, {'name':'Kurdish','locale':'ku-TR'},
  {'name':'Tajik','locale':'tg-TJ'}, {'name':'Kyrgyz','locale':'ky-KG'},
  {'name':'Tatar','locale':'tt-RU'}, {'name':'Uyghur','locale':'ug-CN'},
  {'name':'Javanese','locale':'jv-ID'}, {'name':'Sundanese','locale':'su-ID'},
  {'name':'Maori','locale':'mi-NZ'}, {'name':'Hawaiian','locale':'haw-US'},
  {'name':'Samoan','locale':'sm-WS'}, {'name':'Tongan','locale':'to-TO'},
];


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
  final TextEditingController _apiKeyController = TextEditingController();
  static const _secureStorage = FlutterSecureStorage();
  String? _previousResponseId;
  bool _thinking = false;
  bool _available = false;
  bool _listening = false;
  bool _speaking = false;
  String _heard = '';
  String _selectedLocale = 'en-IN';
  String _reply = 'Namaste! Tap the microphone and tell me how I can help.';
  String _status = 'Checking microphone and speech support…';

  @override
  void initState() {
    super.initState();
    _initialise();
  }

  Future<void> _initialise() async {
    try {
      await _tts.setLanguage(_selectedLocale);
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
      listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(seconds: 25),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
        localeId: _selectedLocale.replaceAll('-', '_'),
      ),
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
    if (command.contains('hello') || command == 'hi' ||
        command.contains('namaste')) {
      await _say('Namaste! I am your GP Health helper. I can open your medicines or family contacts.');
      return;
    }
    if (command.contains('help')) {
      await _say('You can say: open my medicines, show my family, or help. You can also type below.');
      return;
    }
    await _askAi(raw);
  }


  Future<void> _chooseLanguage() async {
    String draft = _selectedLocale;
    final chosen = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Choose your language'),
          content: SizedBox(
            width: double.maxFinite,
            child: DropdownButtonFormField<String>(
              value: draft,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Language', border: OutlineInputBorder()),
              items: _languages.map((language) => DropdownMenuItem<String>(
                value: language['locale']!,
                child: Text(language['name']!),
              )).toList(),
              onChanged: (value) {
                if (value != null) setDialogState(() => draft = value);
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, draft), child: const Text('Use language')),
          ],
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    setState(() => _selectedLocale = chosen);
    try {
      await _tts.setLanguage(chosen);
      final selected = _languages.firstWhere((item) => item['locale'] == chosen);
      await _say('Language set to ${selected['name']}. Voice availability depends on the speech services installed on your phone.');
    } catch (_) {
      await _say('This phone may not have speech voices installed for the selected language. You can still type in that language.');
    }
  }

  Future<void> _configureApiKey() async {
    final saved = await _secureStorage.read(key: 'openai_api_key');
    _apiKeyController.text = saved ?? '';
    if (!mounted) return;
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        title: const Text('Connect GP Health AI'),
        content: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your OpenAI API key. It is stored in this phone’s secure storage and is not committed to GitHub. API usage may cost money.'),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'OpenAI API key',
                hintText: 'sk-…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text('For a public production app, use a protected backend instead of putting API keys on devices.',
              style: TextStyle(fontSize: 12, color: Color(0xFF526777))),
          ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () async {
            await _secureStorage.delete(key: 'openai_api_key');
            if (dialogContext.mounted) Navigator.pop(dialogContext, false);
            if (mounted) _say('The saved AI key has been removed.');
          }, child: const Text('Remove key')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save securely')),
        ],
      ),
    );
    if (shouldSave == true) {
      final key = _apiKeyController.text.trim();
      if (key.isEmpty) {
        await _say('Please enter an API key first.');
      } else {
        await _secureStorage.write(key: 'openai_api_key', value: key);
        await _say('Your AI connection key is saved on this device. You can now chat with me.');
      }
    }
  }

  Future<void> _askAi(String prompt) async {
    final apiKey = await _secureStorage.read(key: 'openai_api_key');
    if (apiKey == null || apiKey.trim().isEmpty) {
      await _say('To turn on real AI conversations, tap the settings button and add your OpenAI API key. You can still use the built-in medicine and family commands.');
      return;
    }
    if (!mounted) return;
    setState(() {
      _thinking = true;
      _status = 'Thinking…';
      _reply = 'Let me think about that.';
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/responses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-5.5',
          'instructions': 'You are GP Health Saathi, a warm, patient, elderly-friendly voice companion. Reply in the language selected by the user (locale: $_selectedLocale). Use simple, short sentences. Help with everyday questions and explain app features. You are not a doctor: never diagnose, prescribe, recommend changing medicine doses, or replace emergency services. For urgent symptoms, advise contacting local emergency services or a qualified clinician. Never claim to have called anyone, changed reminders, or accessed health records. Do not ask for passwords, OTPs, or payment details.',
          'input': prompt,
          if (_previousResponseId != null) 'previous_response_id': _previousResponseId,
          'max_output_tokens': 350,
        }),
      ).timeout(const Duration(seconds: 45));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = data['error'] is Map ? (data['error']['message'] ?? 'The AI service returned an error.') : 'The AI service returned an error.';
        throw Exception(message.toString());
      }
      _previousResponseId = data['id']?.toString();
      final output = data['output'] as List? ?? [];
      final textParts = <String>[];
      for (final item in output) {
        if (item is Map && item['type'] == 'message') {
          final content = item['content'] as List? ?? [];
          for (final part in content) {
            if (part is Map && part['type'] == 'output_text' && part['text'] is String) {
              textParts.add(part['text'] as String);
            }
          }
        }
      }
      final answer = textParts.join('\n').trim();
      if (answer.isEmpty) throw Exception('The AI did not return a text reply.');
      await _say(answer);
    } catch (error) {
      final message = error.toString().replaceFirst('Exception: ', '');
      await _say('I could not connect to the AI service. $message Please check your internet connection and API key.');
    } finally {
      if (mounted) setState(() => _thinking = false);
    }
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
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk to GP Health', style: TextStyle(fontWeight: FontWeight.bold, color: _navy)),
        actions: [
          IconButton(tooltip: 'Choose language', onPressed: _chooseLanguage, icon: const Icon(Icons.language)),
          IconButton(tooltip: 'AI settings', onPressed: _configureApiKey, icon: const Icon(Icons.settings)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Namaste! 👋', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _navy)),
            const SizedBox(height: 8),
            const Text('I am here to help. Speak or type below.', style: TextStyle(fontSize: 18)),
            Text('Language: ${_languages.firstWhere((item) => item['locale'] == _selectedLocale)['name']}', style: const TextStyle(color: _teal, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(24)),
              child: Column(children: [
                Icon(_listening ? Icons.graphic_eq : Icons.mic, color: Colors.white, size: 42),
                const SizedBox(height: 12),
                Text(_listening ? 'I am listening…' : (_thinking ? 'Thinking…' : 'Tap to speak'), style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
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
            const Text('Voice recognition depends on your phone’s speech service. AI chat needs internet and your own OpenAI API key. This prototype stores the key securely on this device; a production release should use a protected backend. The AI is not a medical professional. Background wake-word listening is not enabled yet.', style: TextStyle(color: Color(0xFF526777), height: 1.45)),
          ],
        ),
      ),
    );
  }
}
