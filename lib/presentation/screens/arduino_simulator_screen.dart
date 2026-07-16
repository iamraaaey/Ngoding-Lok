import 'package:flutter/material.dart';

import '../../core/curriculum/curriculum_module.dart';
import '../../core/curriculum/module_config.dart';
import '../theme/landing_tokens.dart';
import '../widgets/wokwi_embed.dart';

/// Hands-on Arduino lesson hosted by Wokwi. The provider's editor and circuit
/// simulator stay together so learners can change a sketch and immediately
/// see the hardware response.
class ArduinoSimulatorScreen extends StatelessWidget {
  final CurriculumModule module;
  final VoidCallback onBack;

  const ArduinoSimulatorScreen({
    super.key,
    required this.module,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final config = module.config as ArduinoSimulatorConfig;

    return Scaffold(
      backgroundColor: LandingTokens.voidBlack,
      body: SafeArea(
        child: Column(
          children: [
            _LabHeader(title: module.title, onBack: onBack),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: LandingTokens.carbon,
                  borderRadius: LandingTokens.mediumRadius,
                  border: Border.all(color: LandingTokens.hairline),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.tips_and_updates_outlined,
                      color: LandingTokens.ember,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.instruction,
                            style: const TextStyle(
                              color: LandingTokens.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No Wokwi account is needed to start this public lesson. Project saves, edited code, and completion do not yet sync to Ngoding Lok.',
                            style: LandingTokens.mono(
                              fontSize: 11,
                              color: LandingTokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: LandingTokens.mediumRadius,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: LandingTokens.carbon,
                      border: Border.all(color: LandingTokens.hairlineStrong),
                    ),
                    child: WokwiEmbed(projectUrl: config.projectUrl),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _LabHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: LandingTokens.hairline)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to home',
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: LandingTokens.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: LandingTokens.ember.withValues(alpha: 0.12),
              border: Border.all(
                color: LandingTokens.ember.withValues(alpha: 0.55),
              ),
              borderRadius: LandingTokens.smallRadius,
            ),
            child: const Icon(
              Icons.memory_rounded,
              color: LandingTokens.ember,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: LandingTokens.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: LandingTokens.signal.withValues(alpha: 0.1),
              border: Border.all(
                color: LandingTokens.signal.withValues(alpha: 0.45),
              ),
              borderRadius: LandingTokens.smallRadius,
            ),
            child: Text(
              'WOKWI LIVE',
              style: LandingTokens.label(
                fontSize: 9,
                color: LandingTokens.signal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
