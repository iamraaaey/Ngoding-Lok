import 'package:flutter/material.dart';
import '../../core/session/user_session.dart';
import '../theme/landing_tokens.dart';
import '../theme/noir_skin.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/landing/landing_button.dart';
import '../widgets/landing/landing_surface.dart';
import '../widgets/noir_dialog.dart';
import '../widgets/policy_dialog.dart';

/// Screen 11 — Settings & Legal, in the terminal noir style. Account
/// management (change password, linked OAuth accounts, sign out), app
/// settings (dark/light theme + sound effects), and the static legal links.
/// The theme and sound toggles are real, live session state owned by the app
/// root.
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

  Widget _buildBody(BuildContext context, NoirSkin skin) {
    final account = _SettingsGroup(
      title: 'Account',
      skin: skin,
      children: [
        _SettingRow(
          icon: Icons.key,
          label: 'Change Password',
          skin: skin,
          onTap: () => showNoirDialog<void>(
            context,
            builder: (_) => const ChangePasswordDialog(),
          ),
        ),
        _SettingRow(
          icon: Icons.link,
          label: 'Linked Accounts',
          subtitle: 'Google, GitHub, LinkedIn',
          skin: skin,
          onTap: () => showNoirDialog<void>(
            context,
            builder: (_) => LinkedAccountsDialog(user: user),
          ),
        ),
        _SettingRow(
          icon: Icons.logout,
          label: 'Sign Out',
          danger: true,
          skin: skin,
          onTap: onLogout,
        ),
      ],
    );

    final appSettings = _SettingsGroup(
      title: 'App Settings',
      skin: skin,
      children: [
        _SwitchRow(
          icon: Icons.dark_mode,
          label: 'Dark Mode',
          value: darkMode,
          skin: skin,
          onChanged: onSetDarkMode,
        ),
        _SwitchRow(
          icon: Icons.volume_up,
          label: 'Sound Effects',
          value: soundEnabled,
          skin: skin,
          onChanged: onSetSound,
        ),
      ],
    );

    final legal = _SettingsGroup(
      title: 'About & Legal',
      skin: skin,
      children: [
        _SettingRow(
          icon: Icons.info_outline,
          label: 'About Us',
          skin: skin,
          onTap: () => showInfoDialog(
            context,
            title: 'About Ngoding Lok',
            body:
                'Ngoding Lok is a gamified, AI-assisted platform for learning to code through '
                'interactive puzzles. Built as a Final Year Project for the UNIMAS Software '
                'Engineering programme by Raynold Anak Kabai.',
          ),
        ),
        _SettingRow(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy Policy',
          skin: skin,
          onTap: () => showPolicyDialog(context, title: 'Privacy Policy'),
        ),
        _SettingRow(
          icon: Icons.description_outlined,
          label: 'Terms of Service',
          skin: skin,
          onTap: () => showPolicyDialog(context, title: 'Terms of Service'),
        ),
      ],
    );

    final version = Center(
      child: Text(
        'NGODING LOK · V1.0.0 (PROTOTYPE)',
        style: LandingTokens.label(fontSize: 9.5, color: skin.faint),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NoirHeader(
            title: 'Settings',
            eyebrow: 'Preferences',
            skin: skin,
            onBack: onBack,
          ),
          const SizedBox(height: 16),
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
                        children: [
                          account,
                          const SizedBox(height: 20),
                          appSettings,
                        ],
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
    final skin = NoirSkin.of(context);

    return Scaffold(
      backgroundColor: skin.bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (skin.isDark) const CinematicBackdrop(),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1800),
                child: _buildBody(context, skin),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final NoirSkin skin;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.skin,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return NoirPanel(
      skin: skin,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '// ${title.toUpperCase()}',
            style: LandingTokens.label(
              fontSize: 10,
              color: LandingTokens.ember,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) HairlineDivider(color: skin.border),
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
  final NoirSkin skin;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.skin,
    this.subtitle,
    this.danger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFFF4D5E) : skin.text;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!.toUpperCase(),
                        style: LandingTokens.label(
                          fontSize: 9,
                          color: skin.faint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: danger ? const Color(0xFFFF4D5E) : skin.faint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final NoirSkin skin;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.skin,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: skin.text),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: skin.text,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF0A0500),
            activeTrackColor: LandingTokens.ember,
            inactiveThumbColor: skin.faint,
            inactiveTrackColor: skin.panelRaised,
            trackOutlineColor: WidgetStatePropertyAll<Color>(skin.borderStrong),
          ),
        ],
      ),
    );
  }
}

/// Functional "Change Password" dialog. There is no auth backend in this
/// prototype, so a valid form updates the in-memory session by confirming
/// success; it never transmits credentials anywhere.
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  String? _currentError;
  String? _nextError;
  String? _confirmError;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final current = _current.text;
    final next = _next.text;
    final confirm = _confirm.text;

    setState(() {
      _currentError = current.isEmpty ? 'Enter your current password.' : null;
      _nextError = next.length >= 6
          ? (next == current
                ? 'Choose a password different from the current one.'
                : null)
          : 'New password must be at least 6 characters.';
      _confirmError = confirm == next ? null : 'Passwords do not match.';
    });

    if (_currentError == null && _nextError == null && _confirmError == null) {
      Navigator.of(context).pop();
      showNoirSnack(context, 'Password updated.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NoirDialogShell(
      title: 'CHANGE\nPASSWORD',
      eyebrow: 'Account security',
      maxWidth: 440,
      maxHeight: 560,
      actions: [
        CinematicOutlineButton(
          label: 'Cancel',
          compact: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        GradientButton(label: 'Update', compact: true, onPressed: _submit),
      ],
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabeledTextField(
              label: 'Current Password',
              controller: _current,
              hint: '........',
              obscure: true,
              errorText: _currentError,
            ),
            const SizedBox(height: 16),
            LabeledTextField(
              label: 'New Password',
              controller: _next,
              hint: 'At least 6 characters',
              obscure: true,
              errorText: _nextError,
            ),
            const SizedBox(height: 16),
            LabeledTextField(
              label: 'Confirm New Password',
              controller: _confirm,
              hint: 'Repeat the new password',
              obscure: true,
              errorText: _confirmError,
            ),
          ],
        ),
      ),
    );
  }
}

/// Functional "Linked Accounts" dialog. Connection state is held in-memory
/// for the prototype: connecting or disconnecting a provider updates the row
/// immediately and confirms with a snackbar.
class LinkedAccountsDialog extends StatefulWidget {
  final UserSession user;

  const LinkedAccountsDialog({super.key, required this.user});

  @override
  State<LinkedAccountsDialog> createState() => _LinkedAccountsDialogState();
}

class _LinkedAccountsDialogState extends State<LinkedAccountsDialog> {
  late final Map<String, bool> _linked = {
    'Google': widget.user.photoUrl != null,
    'GitHub': false,
    'LinkedIn': false,
  };

  static const Map<String, IconData> _icons = {
    'Google': Icons.g_mobiledata_rounded,
    'GitHub': Icons.code_rounded,
    'LinkedIn': Icons.business_center_rounded,
  };

  void _toggle(String provider) {
    final nowLinked = !(_linked[provider] ?? false);
    setState(() => _linked[provider] = nowLinked);
    showNoirSnack(
      context,
      nowLinked ? '$provider connected.' : '$provider disconnected.',
      success: nowLinked,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NoirDialogShell(
      title: 'LINKED\nACCOUNTS',
      eyebrow: 'Sign-in providers',
      maxWidth: 440,
      maxHeight: 460,
      actions: const [NoirCloseButton()],
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final provider in _linked.keys)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProviderRow(
                  name: provider,
                  icon: _icons[provider]!,
                  linked: _linked[provider] ?? false,
                  onToggle: () => _toggle(provider),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool linked;
  final VoidCallback onToggle;

  const _ProviderRow({
    required this.name,
    required this.icon,
    required this.linked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: LandingTokens.panel,
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.hairline),
      ),
      child: Row(
        children: [
          Icon(icon, color: LandingTokens.textPrimary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: LandingTokens.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: linked
                            ? LandingTokens.signal
                            : LandingTokens.textFaint,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      linked ? 'CONNECTED' : 'NOT CONNECTED',
                      style: LandingTokens.label(
                        fontSize: 9,
                        color: linked
                            ? LandingTokens.signal
                            : LandingTokens.textFaint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          linked
              ? CinematicOutlineButton(
                  label: 'Disconnect',
                  compact: true,
                  onPressed: onToggle,
                )
              : GradientButton(
                  label: 'Connect',
                  compact: true,
                  onPressed: onToggle,
                ),
        ],
      ),
    );
  }
}
