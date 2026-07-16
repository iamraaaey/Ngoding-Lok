import 'package:flutter/material.dart';
import '../theme/landing_tokens.dart';
import 'noir_dialog.dart';

/// ─────────────────────────────────────────────────────────────
///  Legal document model
/// ─────────────────────────────────────────────────────────────

/// One numbered clause of a legal document: a bold heading plus one or
/// more paragraphs. A paragraph beginning with "• " is rendered as a
/// bullet, everything else as a normal block.
class LegalSection {
  final String heading;
  final List<String> body;
  const LegalSection(this.heading, this.body);
}

/// A full legal document: title, version line, plain-language summary, and
/// the numbered clauses.
class LegalDocument {
  final String title;
  final String version;
  final String effectiveDate;
  final String summary;
  final List<LegalSection> sections;

  const LegalDocument({
    required this.title,
    required this.version,
    required this.effectiveDate,
    required this.summary,
    required this.sections,
  });
}

// Shared identity used across the documents so the copy stays consistent.
const _appName = 'Ngoding Lok';
const _providerName =
    'Raynold Anak Kabai, Faculty of Computer Science and Information '
    'Technology, Universiti Malaysia Sarawak (UNIMAS)';
const _supportEmail = 'support@ngodinglok.app';
const _privacyEmail = 'privacy@ngodinglok.app';
const _effectiveDate = '6 July 2026';

/// ─────────────────────────────────────────────────────────────
///  Privacy Policy
/// ─────────────────────────────────────────────────────────────

const _privacyPolicy = LegalDocument(
  title: 'Privacy Policy',
  version: 'Version 1.0',
  effectiveDate: _effectiveDate,
  summary:
      'We collect only what we need to save your learning progress and run '
      'the app: your account email, your game stats, and, when you ask for a '
      'hint, the code you are working on. We do not sell your data.',
  sections: [
    LegalSection('1. Who we are', [
      '$_appName ("the App", "we", "us") is a gamified, AI-assisted platform '
          'for learning to code. It is developed and operated by $_providerName.',
      'This policy explains what personal data we process when you use the '
          'App, why we process it, and the rights you have. It is written to '
          'align with the Malaysian Personal Data Protection Act 2010 (PDPA) '
          'and, where it applies to you, the EU/UK General Data Protection '
          'Regulation (GDPR).',
    ]),
    LegalSection('2. Information we collect', [
      'Account identity. When you create an account we store your email '
          'address. If you sign in with Google, GitHub or LinkedIn, we also '
          'receive your display name and profile picture URL from that '
          'provider so we can personalise your profile.',
      'Learning progress. We store the data that makes the game work: your '
          'total XP, which modules you have completed, your best efficiency '
          'score per module, your current day streak, and any Streak Freeze '
          'tokens you own.',
      'Hint interactions. When you tap "Get a hint", the code you have '
          'written for that level, the level objective, and the module type '
          'are sent to our hint service so an AI model can generate Socratic '
          'guidance. See section 5.',
      'Device preferences. Your theme (dark/light) and sound settings are '
          'stored locally on your device and are not sent to us.',
      'Technical data. Like most online services, our servers automatically '
          'log basic technical information such as app version, approximate '
          'request time, and error diagnostics, which we use to keep the App '
          'secure and working.',
    ]),
    LegalSection('3. How we use your information', [
      '• To create your account and authenticate you at sign-in.',
      '• To save and restore your progress, XP, streak and leaderboard '
          'standing across sessions and devices.',
      '• To generate personalised, AI-assisted hints when you request them.',
      '• To operate, secure, debug and improve the App.',
      '• To contact you about your account or important service changes.',
      'We do not use your data for third-party advertising, and we do not '
          'sell your personal data.',
    ]),
    LegalSection('4. Legal basis for processing', [
      'Where the PDPA or GDPR applies, we rely on: your consent (given when '
          'you register and accept this policy); the necessity of processing '
          'to perform our service to you (saving progress, authenticating '
          'you); and our legitimate interest in keeping the App secure and '
          'improving it. You may withdraw consent at any time (see section 9).',
    ]),
    LegalSection('5. AI-assisted hints and third parties', [
      'To produce a hint, our hint service (a Firebase Cloud Function) sends '
          'the code and level context described in section 2 to a third-party '
          'large language model provider, which returns suggested guidance. '
          'We ask you to avoid entering real personal or sensitive information '
          'into the code editor, as anything you submit for a hint is processed '
          'for that purpose.',
      'We rely on the following categories of processors to run the App: '
          'Google (Firebase hosting and Cloud Functions), the identity '
          'providers you choose to sign in with (Google, GitHub, LinkedIn), '
          'and our AI hint provider. Each processes data only to deliver its '
          'part of the service.',
    ]),
    LegalSection('6. Sharing and disclosure', [
      'We share personal data only with the processors listed in section 5, '
          'and only where required by law or to protect the rights, safety '
          'and security of our users and the App. We never sell your data.',
    ]),
    LegalSection('7. Data retention', [
      'We keep your account and progress data for as long as your account is '
          'active. If you delete your account, we delete or irreversibly '
          'anonymise your personal data within 30 days, except where we are '
          'legally required to retain it for longer.',
    ]),
    LegalSection('8. Security', [
      'Access to accounts is protected by your identity provider and by '
          'transport encryption (HTTPS) for data in transit. No system is '
          'perfectly secure, but we take reasonable technical and '
          'organisational measures appropriate to the data we hold.',
    ]),
    LegalSection('9. Your rights', [
      'Subject to applicable law, you may: access the personal data we hold '
          'about you; correct inaccurate data; request deletion of your data; '
          'withdraw consent; and request a portable copy of your data.',
      'To exercise any of these rights, contact us at $_privacyEmail. You '
          'also have the right to lodge a complaint with the Malaysian '
          'Personal Data Protection Commissioner, or your local supervisory '
          'authority.',
    ]),
    LegalSection('10. Children', [
      'The App is not directed at children under 13. If you are under the age '
          'of majority in your country, please use the App only with the '
          'consent and supervision of a parent, guardian or teacher.',
    ]),
    LegalSection('11. International transfers', [
      'Our processors may store and process data on servers located outside '
          'your country. Where data is transferred internationally, we rely '
          'on the safeguards those providers offer under applicable data '
          'protection law.',
    ]),
    LegalSection('12. Changes to this policy', [
      'We may update this policy from time to time. When we make material '
          'changes we will update the effective date and, where appropriate, '
          'notify you in the App. Continued use after an update means you '
          'accept the revised policy.',
    ]),
    LegalSection('13. Contact us', [
      'For any privacy question or request, contact us at $_privacyEmail '
          '(privacy matters) or $_supportEmail (general support).',
    ]),
  ],
);

/// ─────────────────────────────────────────────────────────────
///  Terms of Service
/// ─────────────────────────────────────────────────────────────

const _termsOfService = LegalDocument(
  title: 'Terms of Service',
  version: 'Version 1.0',
  effectiveDate: _effectiveDate,
  summary:
      'Use $_appName fairly and lawfully, keep your account secure, and '
      'remember that XP and in-game items have no cash value. The App is '
      'provided as-is, and hints are learning aids, not guaranteed answers.',
  sections: [
    LegalSection('1. Acceptance of these terms', [
      'These Terms of Service ("Terms") govern your use of $_appName. By '
          'creating an account or using the App, you agree to these Terms and '
          'to our Privacy Policy. If you do not agree, please do not use the '
          'App.',
    ]),
    LegalSection('2. Eligibility and your account', [
      'You must be at least 13 years old to create an account. You are '
          'responsible for the activity under your account and for keeping '
          'your sign-in credentials secure. Notify us promptly of any '
          'unauthorised use.',
    ]),
    LegalSection('3. The service', [
      '$_appName provides interactive coding puzzles, progress tracking, '
          'leaderboards and AI-assisted hints for educational purposes. We '
          'may add, change or remove features as the App evolves.',
    ]),
    LegalSection('4. Acceptable use', [
      'You agree not to: use the App for any unlawful purpose; attempt to '
          'gain unauthorised access to our systems or other users\' accounts; '
          'submit malicious code, exploits or content intended to disrupt the '
          'service; scrape, overload or interfere with the App; or abuse the '
          'hint service through automated or excessive requests.',
    ]),
    LegalSection('5. Your content', [
      'You retain ownership of the code you write in the App. By submitting '
          'code to the hint service, you grant us a limited licence to process '
          'it solely to generate your hint and operate the feature, as '
          'described in the Privacy Policy.',
    ]),
    LegalSection('6. Intellectual property', [
      'The App, including its curriculum, puzzle designs, artwork, branding '
          'and code, is owned by us or our licensors and is protected by '
          'intellectual property law. You may not copy, redistribute or '
          'create derivative works from it except as permitted by these Terms '
          'or applicable law.',
    ]),
    LegalSection('7. Virtual items and progression', [
      'XP, streaks, efficiency scores, Streak Freeze tokens and similar '
          'in-game items are provided for gameplay only. They have no monetary '
          'value, cannot be exchanged for cash, and may be adjusted or reset '
          'where necessary to maintain fair play or fix errors.',
    ]),
    LegalSection('8. AI-assisted hints', [
      'Hints are generated by an AI model to support your learning. They are '
          'suggestions, may contain mistakes, and are not guaranteed to be '
          'correct or complete. Always review and verify guidance before '
          'relying on it.',
    ]),
    LegalSection('9. Availability', [
      'We aim to keep the App available and reliable, but it is offered on an '
          '"as available" basis and may experience downtime, changes or '
          'discontinuation. Some features depend on third-party services '
          'outside our control.',
    ]),
    LegalSection('10. Disclaimer of warranties', [
      'To the fullest extent permitted by law, the App is provided "as is" '
          'and "as available" without warranties of any kind, whether express '
          'or implied, including fitness for a particular purpose and '
          'uninterrupted or error-free operation.',
    ]),
    LegalSection('11. Limitation of liability', [
      'To the fullest extent permitted by law, we are not liable for any '
          'indirect, incidental or consequential loss, or for loss of data, '
          'progress or profits, arising from your use of or inability to use '
          'the App.',
    ]),
    LegalSection('12. Suspension and termination', [
      'You may stop using the App and delete your account at any time. We may '
          'suspend or terminate access if you breach these Terms or use the '
          'App in a way that harms other users or the service.',
    ]),
    LegalSection('13. Governing law', [
      'These Terms are governed by the laws of Malaysia, and any disputes are '
          'subject to the exclusive jurisdiction of the Malaysian courts, '
          'without prejudice to any mandatory consumer protections in your '
          'country of residence.',
    ]),
    LegalSection('14. Changes to these terms', [
      'We may revise these Terms from time to time. Material changes will be '
          'reflected in the effective date and, where appropriate, notified '
          'in the App. Continued use after a change constitutes acceptance.',
    ]),
    LegalSection('15. Contact us', [
      'Questions about these Terms? Reach us at $_supportEmail.',
    ]),
  ],
);

/// ─────────────────────────────────────────────────────────────
///  Cookies Policy
/// ─────────────────────────────────────────────────────────────

const _cookiesPolicy = LegalDocument(
  title: 'Cookies Policy',
  version: 'Version 1.0',
  effectiveDate: _effectiveDate,
  summary:
      'We use only the storage strictly needed to keep you signed in and '
      'remember your settings. No advertising or cross-site tracking cookies.',
  sections: [
    LegalSection('1. About this policy', [
      'This policy explains how $_appName uses cookies and similar local '
          'storage technologies. It should be read together with our Privacy '
          'Policy.',
    ]),
    LegalSection('2. What cookies and local storage are', [
      'Cookies and local storage are small pieces of data saved on your '
          'device by an app or website. They let the App remember information '
          'between sessions, such as whether you are signed in.',
    ]),
    LegalSection('3. How we use them', [
      'Essential authentication. We store a secure session token so you stay '
          'signed in and do not have to log in on every screen.',
      'Preferences. We remember your theme (dark/light) and sound settings '
          'on your device so the App looks and behaves the way you left it.',
      'Diagnostics. We may store minimal data to keep the App stable and '
          'help us fix errors.',
    ]),
    LegalSection('4. What we do not use', [
      'We do not use advertising cookies, third-party tracking pixels, or '
          'cross-site profiling. We do not sell information collected through '
          'cookies.',
    ]),
    LegalSection('5. Managing cookies', [
      'Because our authentication and preference storage are essential to the '
          'App, disabling them may prevent you from staying signed in. You can '
          'clear stored data at any time through your browser or device '
          'settings, or by signing out and deleting the App.',
    ]),
    LegalSection('6. Contact us', [
      'Questions about this policy? Contact us at $_privacyEmail.',
    ]),
  ],
);

/// Maps a policy link's label to its document. Matching is done on
/// lowercase keywords so both the Settings screen and the sign-up consent
/// checkbox resolve to the same source of truth.
LegalDocument? _documentFor(String title) {
  final t = title.toLowerCase();
  if (t.contains('privacy')) return _privacyPolicy;
  if (t.contains('cookie')) return _cookiesPolicy;
  if (t.contains('term')) return _termsOfService;
  return null;
}

/// Opens the real legal document matching [title] (Privacy Policy, Terms of
/// Service, or Cookies Policy). Falls back to the generic info dialog if the
/// title doesn't match a known document.
void showPolicyDialog(BuildContext context, {required String title}) {
  final doc = _documentFor(title);
  if (doc == null) {
    showInfoDialog(context, title: title, body: 'Document not available.');
    return;
  }
  showNoirDialog<void>(
    context,
    builder: (context) => NoirDialogShell(
      title: doc.title,
      eyebrow: 'Legal',
      meta: '${doc.version} · Effective ${doc.effectiveDate}',
      actions: const [NoirCloseButton()],
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(right: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SummaryCallout(text: doc.summary),
              const SizedBox(height: 16),
              for (final section in doc.sections)
                _SectionView(section: section),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SummaryCallout extends StatelessWidget {
  final String text;
  const _SummaryCallout({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: LandingTokens.signal.withValues(alpha: 0.07),
        borderRadius: LandingTokens.smallRadius,
        border: Border.all(color: LandingTokens.signal.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IN SHORT',
            style: LandingTokens.label(fontSize: 9, color: LandingTokens.signal),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: LandingTokens.body(
              fontSize: 12.5,
              color: LandingTokens.textPrimary,
            ).copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _SectionView extends StatelessWidget {
  final LegalSection section;
  const _SectionView({required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading.toUpperCase(),
            style: LandingTokens.label(
              fontSize: 11,
              color: LandingTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (final para in section.body) _Paragraph(text: para),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph({required this.text});

  @override
  Widget build(BuildContext context) {
    final isBullet = text.startsWith('• ');
    final content = isBullet ? text.substring(2) : text;
    final style = LandingTokens.body(fontSize: 13, color: LandingTokens.textMuted)
        .copyWith(height: 1.5);

    if (!isBullet) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(content, style: style),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 8),
            child: Text(
              '+',
              style: LandingTokens.mono(fontSize: 13, color: LandingTokens.ember),
            ),
          ),
          Expanded(child: Text(content, style: style)),
        ],
      ),
    );
  }
}

/// Generic noir info dialog with a title, scrollable body, and a Close
/// button. Used for the Settings "About Us" link and any simple single-body
/// message.
void showInfoDialog(
  BuildContext context, {
  required String title,
  required String body,
}) {
  showNoirDialog<void>(
    context,
    builder: (context) => NoirDialogShell(
      title: title,
      eyebrow: 'About',
      maxWidth: 440,
      maxHeight: 480,
      actions: const [NoirCloseButton()],
      child: SingleChildScrollView(
        child: Text(
          body,
          style: LandingTokens.body(
            fontSize: 14,
            color: LandingTokens.textMuted,
          ).copyWith(height: 1.55),
        ),
      ),
    ),
  );
}
