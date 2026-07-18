/// Firebase Email Configuration and Templates
///
/// This file contains configuration for all Firebase email templates used in the app.
/// Email templates are managed in Firebase Console, but this serves as documentation.
///
/// Firebase Email Templates Location:
/// - Go to: Firebase Console → Authentication → Templates
/// - Project: ngoding-lok
/// - Available templates: Email Verification, Password Reset, Email Change, MFA Enrollment
library;

class FirebaseEmailConfig {
  /// Email verification template - sent when user signs up with email/password
  ///
  /// When: User signs up or requests email verification
  /// Recipient: User's registered email address
  /// CTA: Click link to verify email (required for MFA enrollment)
  static const String emailVerification = '''
Template: Email Address Verification

Subject: Verify your email for %APP_NAME%

Message:
Hello %DISPLAY_NAME%,

Follow this link to verify your email address.

%LINK%

If you didn't ask to verify this address, you can ignore this email.

Thanks,
Your %APP_NAME% team

Available Variables:
- %APP_NAME%: "Ngoding Lok" (from Firebase Console)
- %DISPLAY_NAME%: User's display name
- %LINK%: Auto-generated verification link
- %NEW_EMAIL%: New email (for email change)
''';

  /// Password reset template - sent when user requests password reset
  ///
  /// When: User clicks "Forgot Password" on sign-in screen
  /// Recipient: User's registered email address
  /// CTA: Click link to reset password
  static const String passwordReset = '''
Template: Password Reset

Subject: Reset your password for %APP_NAME%

Message:
Hello %DISPLAY_NAME%,

Follow this link to reset your password.

%LINK%

If you didn't ask to reset your password, you can ignore this email.

Thanks,
Your %APP_NAME% team
''';

  /// Email change confirmation - sent when user requests to change email
  ///
  /// When: User changes email in Settings screen
  /// Recipient: NEW email address (for confirmation)
  /// CTA: Click link to confirm email change
  static const String emailChange = '''
Template: Email Address Change

Subject: Confirm your new email for %APP_NAME%

Message:
Hello %DISPLAY_NAME%,

Follow this link to confirm your new email address.

%LINK%

If you didn't ask to change your email, you can ignore this email.

Thanks,
Your %APP_NAME% team
''';

  /// MFA enrollment notification - sent when user enrolls SMS MFA
  ///
  /// When: User successfully enrolls in SMS multi-factor authentication
  /// Recipient: User's verified email address
  /// Note: Purely informational; no action required
  static const String mfaEnrollment = '''
Template: Multi-Factor Authentication Enrollment

Subject: Multi-factor authentication enabled on %APP_NAME%

Message:
Hello %DISPLAY_NAME%,

Multi-factor authentication (MFA) has been successfully enabled on your account.

You will now be asked to enter a verification code from your phone when signing in.

If you did not make this change or believe your account has been compromised,
please contact our support team immediately.

Thanks,
Your %APP_NAME% team
''';

  /// Customization Guide for Firebase Email Templates
  ///
  /// To customize email templates in Firebase Console:
  /// 1. Go to Firebase Console → Project Settings → Authentication
  /// 2. Click "Templates" tab
  /// 3. Select language (currently English)
  /// 4. For each template, customize:
  ///    - Sender Name: "Ngoding Lok" (default: "noreply")
  ///    - From Address: "noreply@ngoding-lok.firebaseapp.com" (auto-set)
  ///    - Reply-To: "support@ngoding-lok.com" (optional, set custom support email)
  ///    - Subject: Customize for your brand
  ///    - Message: HTML or plain text with brand colors, logo, custom footer
  ///
  /// Recommended Customizations:
  /// - Add logo: Use %APP_LOGO% or embed <img src="...">
  /// - Add branding colors: Use terminal noir theme (#0A0500, #FF5C01)
  /// - Add support links: Include link to help/support
  /// - Add account settings link: Link to Settings screen
  /// - Customize CTA button color: Use accent orange (#FF5C01)
  ///
  /// Testing Email Templates:
  /// 1. Create test account in Firebase Console
  /// 2. In Authentication → Users, manually trigger email verification
  /// 3. Check email in test inbox
  /// 4. Verify links work and styling is correct
}

/// Configuration for email settings in the app
class EmailSettings {
  /// Whether to require email verification for signup
  /// If true, users cannot access the app until they verify their email
  static const bool requireEmailVerification = true;

  /// Whether to send MFA enrollment notification
  /// Sent after user successfully enables SMS MFA
  static const bool sendMfaNotification = true;

  /// Resend email verification link after this many minutes
  static const int resendVerificationMinutes = 1;

  /// Show "Resend Verification" button after this many minutes of inactivity
  static const int resendButtonDelayMinutes = 2;
}

/// Firebase Security Rules for Email
///
/// Add these rules to Firestore if tracking email verification state:
///
/// match /users/{userId} {
///   allow read, write: if request.auth.uid == userId;
///
///   // Only authenticated users can read email-related fields
///   match /emailVerification {
///     allow read: if request.auth.uid == userId;
///   }
/// }
///
/// Firebase Auth Custom Claims (optional):
/// You can set custom claims on backend to track email verification:
///
/// admin.auth().setCustomUserClaims(uid, {
///   'emailVerified': true,
///   'verifiedAt': new Date().toISOString(),
/// })
