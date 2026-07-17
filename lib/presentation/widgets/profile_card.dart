import 'package:flutter/material.dart';
import '../../core/session/user_session.dart';
import '../theme/landing_tokens.dart';
import 'landing/landing_button.dart';

/// Player identity panel in the terminal noir style: carbon card, hairline
/// avatar box, mono status labels, and the XP readout as a terminal chip.
class ProfileCard extends StatelessWidget {
  final UserSession user;
  final VoidCallback onLogout;

  const ProfileCard({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LandingTokens.carbon,
        borderRadius: LandingTokens.mediumRadius,
        border: Border.all(color: LandingTokens.hairline),
        boxShadow: LandingTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (user.photoUrl != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: LandingTokens.smallRadius,
                    border: Border.all(color: LandingTokens.hairlineStrong),
                    image: DecorationImage(
                      image: NetworkImage(user.photoUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: LandingTokens.circuit.withValues(alpha: 0.10),
                    borderRadius: LandingTokens.smallRadius,
                    border: Border.all(
                      color: LandingTokens.circuit.withValues(alpha: 0.55),
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: LandingTokens.circuit,
                    size: 20,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: LandingTokens.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ENROLLED STUDENT',
                      style: LandingTokens.label(
                        fontSize: 9,
                        color: LandingTokens.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: LandingTokens.voidBlack,
              borderRadius: LandingTokens.smallRadius,
              border: Border.all(color: LandingTokens.hairlineStrong),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PLATFORM XP',
                  style: LandingTokens.label(
                    fontSize: 10,
                    color: LandingTokens.textMuted,
                  ),
                ),
                Text(
                  '${user.xp}',
                  style: LandingTokens.mono(
                    fontSize: 14,
                    color: LandingTokens.ember,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CinematicOutlineButton(
            label: 'Disconnect',
            icon: Icons.logout,
            compact: true,
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}
