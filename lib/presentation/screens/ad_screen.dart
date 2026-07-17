import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../theme/doodle.dart';

/// Shared simulated ad screen. Knows nothing about hints, XP, or navigation
/// targets — [onComplete] decides what happens next. [isRewarded] controls
/// the countdown length and button copy (5s "Unlock Hint" vs 3s "Skip Ad"),
/// mirroring the prototype's single shared `AdScreen` component.
class AdScreen extends StatefulWidget {
  final bool isRewarded;
  final VoidCallback onComplete;
  final VoidCallback? onCancel;

  const AdScreen({
    super.key,
    required this.isRewarded,
    required this.onComplete,
    this.onCancel,
  });

  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
  late int _secondsLeft = widget.isRewarded ? 5 : 3;
  Timer? _timer;

  String _jokeSetup = "Loading sponsor message...";
  String _jokePunchline = "";
  bool _isLoadingJoke = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    _fetchJoke();
  }

  Future<void> _fetchJoke() async {
    try {
      final response = await http
          .get(Uri.parse('https://official-joke-api.appspot.com/random_joke'))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> &&
            data.containsKey('setup') &&
            data.containsKey('punchline')) {
          if (mounted) {
            setState(() {
              _jokeSetup = data['setup'];
              _jokePunchline = data['punchline'];
              _isLoadingJoke = false;
            });
          }
          return;
        }
      }
    } catch (_) {
      // ignore
    }
    // Fallback joke if network fails
    if (mounted) {
      setState(() {
        _jokeSetup = "Why do programmers wear glasses?";
        _jokePunchline = "Because they can't C#!";
        _isLoadingJoke = false;
      });
    }
  }

  void _tick(Timer timer) {
    if (_secondsLeft <= 1) {
      timer.cancel();
      setState(() => _secondsLeft = 0);
    } else {
      setState(() => _secondsLeft -= 1);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _secondsLeft == 0;
    return Scaffold(
      backgroundColor: DoodlePalette.dark,
      body: DoodleDotBackground(
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DoodleCard(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                borderRadius: 18,
                color: DoodlePalette.yellow,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const DoodleIconBadge(
                        icon: Icons.play_circle_fill,
                        color: DoodlePalette.purple,
                        size: 52,
                        iconSize: 26,
                        borderRadius: 15,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.isRewarded
                            ? 'Sponsored Hint Unlocking...'
                            : 'Advertisement',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _jokeSetup,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_isLoadingJoke)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.black,
                          ),
                        )
                      else if (canContinue && _jokePunchline.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: DoodlePalette.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _jokePunchline,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: DoodlePalette.purple,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const DoodlePill(
                                text: 'Reward granted!',
                                background: DoodlePalette.green,
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Text(
                            'Punchline unlocks in $_secondsLeft...',
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      DoodleButton(
                        onPressed: canContinue ? widget.onComplete : null,
                        color: DoodlePalette.green,
                        icon: Icons.skip_next,
                        dense: true,
                        label: canContinue
                            ? (widget.isRewarded ? 'Unlock Hint' : 'Skip Ad')
                            : 'Please wait...',
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.onCancel != null)
                Positioned(
                  top: -14,
                  right: -14,
                  child: GestureDetector(
                    onTap: widget.onCancel,
                    child: const DoodleIconBadge(
                      icon: Icons.close,
                      color: DoodlePalette.red,
                      size: 40,
                      iconSize: 20,
                      borderRadius: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
