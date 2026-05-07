import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../services/openai_service.dart';
import '../../services/auth_provider.dart';

// ─── Baymax Minimalist Eye Painter ──────────────────────────────────────
class BaymaxEyePainter extends CustomPainter {
  final double blinkProgress; // 0 = open, 1 = closed
  final double scale;
  
  BaymaxEyePainter({
    required this.blinkProgress,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    // Baymax proportions: small circle/oval eyes connected by a thin line.
    final eyeRadius = size.width * 0.12; 
    final eyeSpacing = size.width * 0.25;
    final centerX = size.width / 2;

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
      
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw the connecting line
    canvas.drawLine(
      Offset(centerX - eyeSpacing, centerY),
      Offset(centerX + eyeSpacing, centerY),
      linePaint,
    );

    // Apply scaling
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.scale(scale, scale);
    canvas.translate(-centerX, -centerY);

    // Draw eyes
    _drawEye(canvas, Offset(centerX - eyeSpacing, centerY), eyeRadius, paint);
    _drawEye(canvas, Offset(centerX + eyeSpacing, centerY), eyeRadius, paint);
    
    canvas.restore();
  }

  void _drawEye(Canvas canvas, Offset center, double radius, Paint paint) {
    final openHeight = radius * 1.1; // Slightly oval
    final currentHeight = openHeight * (1 - blinkProgress);

    if (currentHeight < 1.0) {
      // Just draw a line if fully closed
      canvas.drawLine(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        Paint()..color = Colors.black..strokeWidth = 3.0,
      );
      return;
    }

    final eyeRect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: currentHeight * 2,
    );

    canvas.drawOval(eyeRect, paint);
  }

  @override
  bool shouldRepaint(covariant BaymaxEyePainter oldDelegate) {
    return oldDelegate.blinkProgress != blinkProgress || oldDelegate.scale != scale;
  }
}

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  final OpenAIService _openAI = OpenAIService();

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isProcessing = false;
  bool _voiceEnabled = true;
  
  String _userText = '';
  String _aiReply = '';
  String _statusText = '';

  bool get _isHindi => Provider.of<AuthProvider>(context, listen: false).currentUser?.occupation?.toLowerCase() == 'farmer';

  // Animation controllers
  late AnimationController _blinkController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  
  // Blink timer
  Timer? _blinkTimer;
  final Random _random = Random();

  // Animations
  late Animation<double> _blinkAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  final TextEditingController _userTextController = TextEditingController();
  bool _isEditingUserText = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _setupAnimations();
    _startBlinkTimer();
    _loadVoiceSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_statusText.isEmpty) {
      _statusText = _isHindi ? 'मैं आपकी स्वास्थ्य सहायक हूँ।' : 'I am your personal healthcare companion.';
      _configureTts();
    }
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

  void _configureTts() async {
    await _tts.setLanguage(_isHindi ? "hi-IN" : "en-US");
    await _tts.setSpeechRate(0.4); // Slower
    await _tts.setPitch(0.9); // Calm 
    await _tts.setVolume(1.0);

    List<dynamic> voices = await _tts.getVoices;
    for (var voice in voices) {
      if (voice is Map) {
        String name = (voice['name'] ?? '').toString().toLowerCase();
        String locale = (voice['locale'] ?? '').toString().toLowerCase();
        if (_isHindi) {
          if (locale.contains('hi') && name.contains('male')) {
             await _tts.setVoice({"name": voice['name'], "locale": voice['locale']});
             break;
          }
        } else {
          if (locale.contains('en') &&
              (name.contains('male') ||
                  name.contains('david') ||
                  name.contains('james') ||
                  name.contains('mark') ||
                  name.contains('daniel') ||
                  name.contains('guy'))) {
            await _tts.setVoice({"name": voice['name'], "locale": voice['locale']});
            break;
          }
        }
      }
    }

    _tts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });
  }

  void _setupAnimations() {
    // Blink
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _blinkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Pulse / Scale when listening or speaking
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Floating effect
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _startBlinkTimer() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(
      Duration(milliseconds: 3000 + _random.nextInt(3000)),
      (_) => _blink(),
    );
  }

  void _blink() {
    if (!mounted || _blinkController.isAnimating) return;
    _blinkController.forward().then((_) {
      if (mounted) _blinkController.reverse();
    });
  }

  void _startListening() async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    }

    bool available = await _speech.initialize(
      onError: (error) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _statusText = 'Could not hear you. Please try again.';
          });
          _pulseController.stop();
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _isEditingUserText = false;
        _statusText = _isHindi ? 'सुन रही हूँ...' : 'Listening...';
        _userText = '';
        _aiReply = '';
      });
      _pulseController.repeat(reverse: true);

      _speech.listen(
        localeId: _isHindi ? 'hi_IN' : 'en_US',
        onResult: (result) {
          if (mounted) {
            setState(() {
              _userText = result.recognizedWords;
              _userTextController.text = _userText;
            });

            if (result.finalResult) {
              _onSpeechDone(result.recognizedWords);
            }
          }
        },
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
      );
    } else {
      setState(() => _statusText = 'Speech recognition not available.');
    }
  }

  void _onSpeechDone(String text) async {
    _speech.stop();
    _pulseController.stop();
    _pulseController.animateTo(1.0);

    setState(() {
      _isListening = false;
      _isProcessing = true;
      _statusText = _isHindi ? 'प्रतीक्षा करें...' : 'Processing...';
    });

    if (text.trim().isEmpty) {
      setState(() {
        _statusText = _isHindi ? "मैं कुछ सुन नहीं पाई।" : "I didn't catch that.";
        _isProcessing = false;
      });
      return;
    }

    await _fetchReply(text);
  }

  Future<void> _fetchReply(String text) async {
    String reply = await _openAI.getResponse(text);

    if (!mounted) return;

    setState(() {
      _aiReply = reply;
      _statusText = '';
      _isProcessing = false;
    });

    _pulseController.repeat(reverse: true); // animate while speaking
    if (_voiceEnabled) {
      await _tts.speak(reply);
    }
    _pulseController.stop();
    _pulseController.animateTo(1.0);
  }

  void _submitEditedText() {
    setState(() {
      _isEditingUserText = false;
      _userText = _userTextController.text.trim();
      _isProcessing = true;
      _aiReply = '';
      _statusText = _isHindi ? 'प्रतीक्षा करें...' : 'Processing...';
    });
    if (_userText.isNotEmpty) {
      _fetchReply(_userText);
    } else {
      setState(() {
        _isProcessing = false;
        _statusText = _isHindi ? 'बोलने के लिए माइक दबाएं।' : 'Tap the microphone to speak.';
      });
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _blinkController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _speech.stop();
    _tts.stop();
    _userTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Row(
            children: [
              Text(
                _voiceEnabled ? "Voice ON" : "Voice OFF",
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54),
              ),
              Switch(
                value: _voiceEnabled,
                onChanged: (_) => _toggleVoice(),
                activeColor: Colors.black,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              _openAI.clearHistory();
              setState(() {
                _userText = '';
                _aiReply = '';
                _statusText = _isHindi ? 'मैं आपकी स्वास्थ्य सहायक हूँ।' : 'I am your personal healthcare companion.';
                _isEditingUserText = false;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Center(
                      child: _buildBaymaxFace(),
                    ),
                  );
                },
              ),
            ),
            _buildConversationArea(),
            const SizedBox(height: 20),
            _buildMicButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBaymaxFace() {
    return AnimatedBuilder(
      animation: Listenable.merge([_blinkAnimation, _pulseAnimation]),
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 100,
          child: CustomPaint(
            painter: BaymaxEyePainter(
              blinkProgress: _blinkAnimation.value,
              scale: _pulseAnimation.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildConversationArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_userText.isNotEmpty || _isEditingUserText)
            _buildUserBubble(),
          if (_isProcessing)
            _buildProcessingIndicator(),
          if (_aiReply.isNotEmpty && !_isProcessing)
            _buildAIBubble(),
          if (_userText.isEmpty && _aiReply.isEmpty && !_isListening && !_isEditingUserText)
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserBubble() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isEditingUserText
          ? Container(
              key: const ValueKey('edit'),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _userTextController,
                      style: GoogleFonts.outfit(fontSize: 16, color: Colors.black87),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitEditedText(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.black87),
                    onPressed: _submitEditedText,
                  ),
                ],
              ),
            )
          : GestureDetector(
              key: const ValueKey('view'),
              onTap: () {
                setState(() {
                  _isEditingUserText = true;
                  _userTextController.text = _userText;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black12, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        _userText,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.edit, size: 14, color: Colors.black38),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAIBubble() {
    return AnimatedOpacity(
      opacity: _aiReply.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12, width: 1),
        ),
        child: Text(
          _aiReply,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: Colors.black87,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.3, end: 1.0),
            duration: Duration(milliseconds: 600 + i * 200),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: _isProcessing ? value : 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _isProcessing || _isSpeaking ? null : _startListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: _isListening ? Colors.black54 : Colors.black,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _isListening 
                  ? Colors.black.withValues(alpha: 0.3) 
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: _isListening ? 20 : 10,
              spreadRadius: _isListening ? 4 : 0,
            ),
          ],
        ),
        child: const Icon(
          Icons.mic,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
