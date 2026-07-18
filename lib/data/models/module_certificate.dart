import 'package:cloud_firestore/cloud_firestore.dart';

/// Public proof that one curriculum module was completed. The record is
/// intentionally self-contained so a LinkedIn visitor can verify it without
/// signing in or reading the student's private user document.
class ModuleCertificate {
  final String certificateId;
  final String uid;
  final String moduleId;
  final String moduleTitle;
  final String moduleDescription;
  final String trackLabel;
  final String learnerName;
  final int score;
  final DateTime issuedAt;

  const ModuleCertificate({
    required this.certificateId,
    required this.uid,
    required this.moduleId,
    required this.moduleTitle,
    required this.moduleDescription,
    required this.trackLabel,
    required this.learnerName,
    required this.score,
    required this.issuedAt,
  });

  factory ModuleCertificate.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return ModuleCertificate(
      certificateId: doc.id,
      uid: data['uid'] as String? ?? '',
      moduleId: data['moduleId'] as String? ?? '',
      moduleTitle: data['moduleTitle'] as String? ?? 'Ngoding Lok Module',
      moduleDescription: data['moduleDescription'] as String? ?? '',
      trackLabel: data['trackLabel'] as String? ?? 'Learning Track',
      learnerName: data['learnerName'] as String? ?? 'Ngoding Lok learner',
      score: (data['score'] as num?)?.toInt() ?? 0,
      issuedAt: (data['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'moduleId': moduleId,
    'moduleTitle': moduleTitle,
    'moduleDescription': moduleDescription,
    'trackLabel': trackLabel,
    'learnerName': learnerName,
    'score': score,
    'issuedAt': FieldValue.serverTimestamp(),
    'verifiedBy': 'Ngoding Lok / Firebase',
  };
}
