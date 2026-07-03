import 'package:flutter/material.dart';
import '../theme/doodle.dart';

/// Placeholder legal copy shown when a user taps a policy link on sign-up.
/// The project has no real Privacy/Cookies policy yet, so this exists only
/// to make the consent checkbox's links resolve to something rather than
/// nothing — swap in real copy before shipping.
void showPolicyDialog(BuildContext context, {required String title}) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 480),
        child: DoodleCard(
          borderRadius: 24,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    'This is placeholder text — NgeCode Juh! is a Final Year Project prototype and '
                    'does not yet have a real $title. In a production release this dialog would '
                    'contain the actual terms covering what data is collected, how it is used, and '
                    'the choices available to you as a user.',
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: DoodleButton(
                  label: 'Close',
                  color: DoodlePalette.yellow,
                  onPressed: () => Navigator.of(context).pop(),
                  dense: true,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
