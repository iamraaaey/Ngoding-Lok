import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/module_certificate.dart';
import 'certificate_link.dart';

/// Builds the portable, printable version of a verified Ngoding Lok
/// credential. The document is created entirely from the persisted
/// certificate record, not from widget pixels, so downloaded copies retain
/// the same identity, issue date, score, and verification URL everywhere.
class CertificatePdf {
  CertificatePdf._();

  static const _ink = PdfColor.fromInt(0xFF263238);
  static const _muted = PdfColor.fromInt(0xFF667279);
  static const _teal = PdfColor.fromInt(0xFF087F9D);
  static const _paleBlue = PdfColor.fromInt(0xFFCDEDF5);
  static const _orange = PdfColor.fromInt(0xFFFF6B00);
  static const _red = PdfColor.fromInt(0xFFE5242A);
  static const _gold = PdfColor.fromInt(0xFFE9A93A);

  /// A consistent filename makes browser downloads easy to identify.
  static String filenameFor(ModuleCertificate certificate) {
    final date = certificate.issuedAt;
    final day =
        '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
    final module = certificate.moduleId
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '-')
        .replaceAll(RegExp(r'-+'), '-');
    return 'ngoding-lok-$module-$day-certificate.pdf';
  }

  /// Generates a landscape A4 PDF suitable for both browser download and
  /// native sharing/printing.
  static Future<Uint8List> build(ModuleCertificate certificate) async {
    final document = pw.Document(
      title: 'Ngoding Lok certificate - ${certificate.moduleTitle}',
      author: 'Ngoding Lok',
      subject: 'Verified completion credential',
      creator: 'Ngoding Lok',
    );
    final certificateUrl = CertificateLink.certificateUrl(
      certificate.certificateId,
    );

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: PdfColor.fromInt(0xFFD5DCE2)),
          ),
          child: pw.Column(
            children: [
              _header(certificate),
              pw.Container(
                width: double.infinity,
                color: _orange,
                padding: const pw.EdgeInsets.symmetric(vertical: 10),
                child: pw.Text(
                  'THIS CERTIFICATE IS PRESENTED TO',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              pw.Container(
                width: double.infinity,
                color: _teal,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                child: pw.FittedBox(
                  fit: pw.BoxFit.scaleDown,
                  child: pw.Text(
                    certificate.learnerName.toUpperCase(),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(36, 20, 36, 16),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'for completing ${certificate.moduleTitle}',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          color: _ink,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 7),
                      pw.Text(
                        certificate.moduleDescription,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          color: _muted,
                          fontSize: 10,
                          lineSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 14),
                      pw.Container(
                        color: _red,
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 8,
                        ),
                        child: pw.Text(
                          'NGODING LOK - ${certificate.trackLabel.toUpperCase()}',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      pw.Spacer(),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Expanded(
                            child: _meta('ISSUED', _date(certificate.issuedAt)),
                          ),
                          pw.Expanded(child: _verifiedSeal()),
                          pw.Expanded(
                            child: _meta(
                              'MODULE SCORE',
                              '${certificate.score} XP',
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        'Certificate ID: ${certificate.certificateId}',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(color: _muted, fontSize: 8),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        certificateUrl,
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(color: _teal, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return document.save();
  }

  /// On web this invokes a direct browser download; native platforms expose
  /// the platform's save/share destination for the generated PDF.
  static Future<bool> download(ModuleCertificate certificate) async {
    final bytes = await build(certificate);
    return Printing.sharePdf(bytes: bytes, filename: filenameFor(certificate));
  }

  static pw.Widget _header(ModuleCertificate certificate) {
    return pw.SizedBox(
      height: 154,
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Container(color: PdfColors.white)),
          pw.Container(
            width: 250,
            color: _paleBlue,
            padding: const pw.EdgeInsets.fromLTRB(18, 15, 18, 13),
            child: pw.Column(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(color: PdfColor.fromInt(0xFFB7DCE7)),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  child: pw.Text(
                    'NGODING LOK - LEARN BY BUILDING',
                    style: pw.TextStyle(
                      color: _teal,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  'CERTIFIED',
                  style: pw.TextStyle(
                    color: _teal,
                    fontSize: 28,
                    fontWeight: pw.FontWeight.normal,
                    letterSpacing: 3,
                  ),
                ),
                pw.Container(width: 135, height: 1.5, color: _orange),
                pw.SizedBox(height: 6),
                pw.Text(
                  certificate.trackLabel.toUpperCase(),
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(0xFF3F6875),
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.FittedBox(
                  fit: pw.BoxFit.scaleDown,
                  child: pw.Text(
                    certificate.moduleTitle,
                    style: pw.TextStyle(
                      color: PdfColor.fromInt(0xFF245766),
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.Expanded(child: pw.Container(color: PdfColors.white)),
        ],
      ),
    );
  }

  static pw.Widget _meta(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            color: _muted,
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            color: _ink,
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _verifiedSeal() {
    return pw.Column(
      children: [
        pw.Container(
          width: 48,
          height: 48,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFFFF3DF),
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: _gold, width: 3),
          ),
          child: pw.Text(
            'V',
            style: pw.TextStyle(
              color: _teal,
              fontSize: 23,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          'ONLINE VERIFIED',
          style: pw.TextStyle(
            color: _teal,
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static String _date(DateTime date) {
    const months = <String>[
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }
}
