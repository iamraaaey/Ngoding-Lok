import 'package:flutter/material.dart';
import '../../core/session/user_session.dart';
import '../theme/doodle.dart';

class ProfileCard extends StatelessWidget {
  final UserSession user;
  final VoidCallback onLogout;

  const ProfileCard({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return DoodleCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const DoodleIconBadge(icon: Icons.person, color: DoodlePalette.blue, size: 48, iconSize: 24, borderRadius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    const DoodlePill(text: 'Enrolled Student', background: Color(0xFFEFEFEF)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: DoodlePalette.yellow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('PLATFORM XP', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text('${user.xp}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          DoodleButton(label: 'Safely Disconnect', color: DoodlePalette.white, onPressed: onLogout, icon: Icons.logout, dense: true),
        ],
      ),
    );
  }
}
