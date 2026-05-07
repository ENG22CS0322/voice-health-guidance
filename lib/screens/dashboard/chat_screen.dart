import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../services/openai_service.dart';
import '../../services/theme_provider.dart';
import '../../services/auth_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> _messages = [];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  final OpenAIService _openAI = OpenAIService();
  bool _isListening = false;
  bool _voiceEnabled = true;

  bool get _isHindi {
    try {
      return Provider.of<AuthProvider>(context, listen: false).currentUser?.occupation?.toLowerCase() == 'farmer';
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _loadVoiceSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      _messages = [
        ChatMessage(
          text: _isHindi ? 'नमस्ते! मैं आपकी स्वास्थ्य सहायक हूँ। मैं आपकी कैसे मदद कर सकती हूँ?' : 'Hello! I am your Health Voice AI assistant. How can I help you today?',
          isUser: false,
          time: DateTime.now(),
        )
      ];
      _configureTts();
    }
  }

  void _configureTts() async {
    await _tts.setLanguage(_isHindi ? "hi-IN" : "en-US");
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(0.9);
  }

  void _loadVoiceSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _voiceEnabled = prefs.getBool('voice_enabled') ?? true;
    });
  }

  void _toggleVoice() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _voiceEnabled = !_voiceEnabled;
      prefs.setBool('voice_enabled', _voiceEnabled);
    });
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String userText = _controller.text;

    setState(() {
      _messages.add(ChatMessage(
        text: userText,
        isUser: true,
        time: DateTime.now(),
      ));
      _controller.clear();
    });

    _scrollToBottom();

    String botReply = await _openAI.getResponse(userText);

    setState(() {
      _messages.add(ChatMessage(
        text: botReply,
        isUser: false,
        time: DateTime.now(),
      ));
    });

    if (_voiceEnabled) {
      _tts.speak(botReply);
    }

    _scrollToBottom();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          localeId: _isHindi ? 'hi_IN' : 'en_US',
          onResult: (result) async {
            if (result.finalResult) {
              String text = result.recognizedWords;

              setState(() => _isListening = false);
              _speech.stop();

              _controller.text = text;

              String reply = await _openAI.getResponse(text);

              setState(() {
                _messages.add(ChatMessage(
                  text: text,
                  isUser: true,
                  time: DateTime.now(),
                ));

                _messages.add(ChatMessage(
                  text: reply,
                  isUser: false,
                  time: DateTime.now(),
                ));

                _controller.clear();
              });

              if (_voiceEnabled) {
                _tts.speak(reply);
              }

              _scrollToBottom();
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isColorful = themeProvider.themeMode == AppThemeMode.colorful;
    final isDark = themeProvider.themeMode == AppThemeMode.dark;

    final bgColor = isColorful ? const Color(0xFFECE5DD) : themeProvider.backgroundColor;
    final appBarColor = isColorful ? const Color(0xFF075E54) : themeProvider.appBarColor;
    final appBarTextColor = isColorful ? Colors.white : themeProvider.textColor;
    final botBubbleColor = isColorful ? Colors.white : themeProvider.cardColor;
    final userBubbleColor = isColorful ? const Color(0xFFDCF8C6) : (isDark ? const Color(0xFF004D40) : const Color(0xFFE0F2F1));
    final chatTextColor = isDark ? Colors.white : Colors.black87;
    final inputBgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF0F0F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: appBarTextColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: isColorful ? Colors.white : themeProvider.cardColor, 
              child: Icon(Icons.smart_toy, color: isColorful ? const Color(0xFF075E54) : themeProvider.iconColor)
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Voice AI', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: appBarTextColor)),
                Text('Online', style: TextStyle(fontSize: 12, color: appBarTextColor.withOpacity(0.7))),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  _voiceEnabled ? "Voice ON" : "Voice OFF",
                  style: TextStyle(fontSize: 10, color: appBarTextColor.withOpacity(0.7)),
                ),
                Switch(
                  value: _voiceEnabled,
                  onChanged: (_) => _toggleVoice(),
                  activeColor: isColorful ? Colors.white : themeProvider.iconColor,
                  activeTrackColor: isColorful ? Colors.white24 : themeProvider.iconColor.withOpacity(0.3),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: Align(
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: msg.isUser ? userBubbleColor : botBubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: msg.isUser ? const Radius.circular(12) : Radius.zero,
                          bottomRight: msg.isUser ? Radius.zero : const Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msg.text, style: TextStyle(fontSize: 16, color: chatTextColor)),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '${msg.time.hour}:${msg.time.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 10, color: chatTextColor.withOpacity(0.6)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: inputBgColor,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: themeProvider.cardColor, borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: chatTextColor),
                      decoration: InputDecoration(
                        hintText: 'Type a message', 
                        hintStyle: TextStyle(color: chatTextColor.withOpacity(0.5)),
                        border: InputBorder.none
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: themeProvider.iconColor),
                  onPressed: _listen,
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: isColorful ? const Color(0xFF075E54) : themeProvider.iconColor,
                  child: IconButton(
                    icon: Icon(Icons.send, color: isColorful ? Colors.white : themeProvider.cardColor),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
