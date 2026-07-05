import 'package:flutter/material.dart';
import '../../core/session/user_session.dart';
import '../theme/doodle.dart';
import '../widgets/policy_dialog.dart';

/// Screen 11 — Settings & Legal. Account management (change password, linked
/// OAuth accounts, sign out), app settings (dark/light theme + sound effects),
/// and the static legal links. The theme and sound toggles are real, live
/// session state owned by the app root.
class SettingsScreen extends StatelessWidget {
  final UserSession user;
  final bool darkMode;
  final bool soundEnabled;
  final ValueChanged<bool> onSetDarkMode;
  final ValueChanged<bool> onSetSound;
  final VoidCallback onLogout;
  final VoidCallback onBack;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.darkMode,
    required this.soundEnabled,
    required this.onSetDarkMode,
    required this.onSetSound,
    required this.onLogout,
    required this.onBack,
  });

  void _todo(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$what isn't wired up in this prototype yet.")),
    );
  }

  Widget _buildBody(BuildContext context, bool dark) {
    final account = _SettingsGroup(
      title: 'Account',
      children: [
        _SettingRow(icon: Icons.key, label: 'Change Password', onTap: () => _todo(context, 'Changing your password')),
        _SettingRow(
          icon: Icons.link,
          label: 'Linked Accounts',
          subtitle: 'Google, GitHub, LinkedIn',
          onTap: () => _todo(context, 'Managing linked accounts'),
        ),
        _SettingRow(icon: Icons.logout, label: 'Sign Out', danger: true, onTap: onLogout),
      ],
    );

    final appSettings = _SettingsGroup(
      title: 'App Settings',
      children: [
        _SwitchRow(icon: Icons.dark_mode, label: 'Dark Mode', value: darkMode, onChanged: onSetDarkMode),
        _SwitchRow(icon: Icons.volume_up, label: 'Sound Effects', value: soundEnabled, onChanged: onSetSound),
      ],
    );

    final legal = _SettingsGroup(
      title: 'About & Legal',
      children: [
        _SettingRow(
          icon: Icons.info_outline,
          label: 'About Us',
          onTap: () => showInfoDialog(
            context,
            title: 'About NgeCode Juh!',
            body: 'NgeCode Juh! is a gamified, AI-assisted platform for learning to code through '
                'interactive puzzles. Built as a Final Year Project for the UNIMAS Software '
                'Engineering programme by Raynold Anak Kabai.',
          ),
        ),
        _SettingRow(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy Policy',
          onTap: () => showPolicyDialog(context, title: 'Privacy Policy'),
        ),
        _SettingRow(
          icon: Icons.description_outlined,
          label: 'Terms of Service',
          onTap: () => showPolicyDialog(context, title: 'Terms of Service'),
        ),
      ],
    );

    final version = Center(
      child: Text('NgeCode Juh! · v1.0.0 (prototype)',
          style: TextStyle(
              color: (dark ? Colors.white : Colors.black).withValues(alpha: 0.4),
              fontWeight: FontWeight.w700,
              fontSize: 12)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(title: 'Settings', onBack: onBack),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              // Wide: account + app settings on the left, legal on the right.
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [account, const SizedBox(height: 20), appSettings],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [legal, const SizedBox(height: 16), version],
                      ),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  account,
                  const SizedBox(height: 16),
                  appSettings,
                  const SizedBox(height: 16),
                  legal,
                  const SizedBox(height: 12),
                  version,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? DoodlePalette.dark : DoodlePalette.cream;

    return Scaffold(
      backgroundColor: bg,
      body: DoodleDotBackground(
        backgroundColor: bg,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: _buildBody(context, dark),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return DoodleCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const DoodleIconBadge(
              icon: Icons.arrow_back,
              color: DoodlePalette.white,
              iconColor: Colors.black,
              size: 40,
              iconSize: 20,
              borderRadius: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 20)),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return DoodleCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 8),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(color: Colors.black12, height: 1, thickness: 1),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool danger;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.danger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? DoodlePalette.red : Colors.black;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 11)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: danger ? DoodlePalette.red : Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.black,
            activeTrackColor: DoodlePalette.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFCCCCCC),
          ),
        ],
      ),
    );
  }
}
