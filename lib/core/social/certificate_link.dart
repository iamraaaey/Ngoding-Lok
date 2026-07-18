import 'referral_link.dart';

/// Creates real public certificate URLs and LinkedIn share URLs.
///
/// The public URL is a normal Firebase Hosting URL. Hosting rewrites it to
/// the Flutter app, which loads the certificate record from Firestore using
/// its public certificate ID.
class CertificateLink {
  CertificateLink._();

  static String certificateIdFor(String uid, String moduleId) =>
      '${uid}_$moduleId';

  static String certificateUrl(String certificateId) =>
      '${ReferralLink.appOrigin}/?certificate=${Uri.encodeQueryComponent(certificateId)}';

  static Uri linkedinShareUrl(String certificateId) => Uri.https(
    'www.linkedin.com',
    '/sharing/share-offsite/',
    {'url': certificateUrl(certificateId)},
  );

  static String? certificateIdFromLaunchUrl() {
    try {
      final raw = Uri.base.queryParameters['certificate']?.trim();
      if (raw == null || raw.isEmpty || raw.contains('/')) return null;
      return raw;
    } catch (_) {
      return null;
    }
  }
}
