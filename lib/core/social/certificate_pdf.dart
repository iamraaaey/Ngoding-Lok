import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/models/module_certificate.dart';
import 'certificate_link.dart';
import 'pdf_downloader.dart';

/// Builds the portable version of a verified Ngoding Lok credential.
///
/// The download mirrors the live certificate rather than using a separate
/// template: a narrow dark identity rail, an ivory paper field, the award
/// seal on their seam, and a large rounded paper edge in the upper-right.
/// Learner data and the QR payload are always derived from the certificate
/// record so the exported copy remains independently verifiable.
class CertificatePdf {
  CertificatePdf._();

  static const _voidBlack = PdfColor.fromInt(0xFF070707);
  static const _carbon = PdfColor.fromInt(0xFF0C0C0C);
  static const _paper = PdfColor.fromInt(0xFFF7F5EF);
  static const _ink = PdfColor.fromInt(0xFF101112);
  static const _slate = PdfColor.fromInt(0xFF5C5B55);
  static const _faint = PdfColor.fromInt(0xFFA1A19A);
  static const _railDivider = PdfColor.fromInt(0xFF30302E);
  static const _ember = PdfColor.fromInt(0xFFFF5C01);
  static const _signal = PdfColor.fromInt(0xFF43FFA4);
  static const _signalInk = PdfColor.fromInt(0xFF087A54);
  static const _circuit = PdfColor.fromInt(0xFF00E5FF);
  // Pdf viewers do not consistently preserve low-alpha vector fills. Use a
  // print-safe warm paper tint so the upper-corner wash stays subtle.
  static const _emberWash = PdfColor.fromInt(0xFFFFF1E7);

  static const _railWidth = 128.0;
  static const _paperInsetLeft = 78.0;
  static const _paperInsetRight = 30.0;

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

  /// Generates a landscape A4 certificate with its real public verification
  /// URL embedded in a scanner-ready QR code.
  static Future<Uint8List> build(ModuleCertificate certificate) async {
    final document = pw.Document(
      title: 'Ngoding Lok certificate - ${certificate.moduleTitle}',
      author: 'Ngoding Lok',
      subject: 'Verified completion credential',
      creator: 'Ngoding Lok',
    );
    final verificationUrl = CertificateLink.certificateUrl(
      certificate.certificateId,
    );

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(18),
        build: (_) => pw.SizedBox.expand(
          child: pw.Container(
            decoration: pw.BoxDecoration(
              color: _voidBlack,
              border: pw.Border.all(color: _ember, width: 1),
            ),
            child: pw.Stack(
              fit: pw.StackFit.expand,
              children: [
                pw.Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: pw.SizedBox(
                    width: _railWidth,
                    child: _brandRail(certificate),
                  ),
                ),
                // This is deliberately a shaped paper panel, not a corner
                // wash. The exposed carbon behind it makes the large upper
                // curve match the live certificate at a glance.
                pw.Positioned(
                  left: _railWidth,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: pw.Container(
                    decoration: const pw.BoxDecoration(
                      color: _paper,
                      borderRadius: pw.BorderRadius.only(
                        topRight: pw.Radius.circular(128),
                      ),
                    ),
                  ),
                ),
                pw.Positioned(
                  left: _railWidth,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: pw.Stack(
                    fit: pw.StackFit.expand,
                    children: [
                      pw.Positioned(
                        right: 36,
                        top: 22,
                        child: pw.Container(
                          width: 92,
                          height: 92,
                          decoration: const pw.BoxDecoration(
                            color: _emberWash,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                      ),
                      pw.Positioned(
                        right: 29,
                        top: 28,
                        child: _paperCircuitMark(),
                      ),
                      pw.Positioned(
                        left: _paperInsetLeft,
                        top: 32,
                        right: _paperInsetRight,
                        bottom: 25,
                        child: _credentialContent(certificate, verificationUrl),
                      ),
                    ],
                  ),
                ),
                // The physical-looking seal bridges the two materials just
                // as it does in the responsive on-screen certificate.
                pw.Positioned(
                  left: _railWidth - 43,
                  top: 150,
                  child: _AwardSeal(),
                ),
              ],
            ),
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
    return downloadPdfBytes(bytes: bytes, filename: filenameFor(certificate));
  }

  static pw.Widget _brandRail(ModuleCertificate certificate) {
    return pw.Container(
      color: _carbon,
      padding: const pw.EdgeInsets.fromLTRB(20, 25, 17, 22),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _railBrand(),
          pw.Spacer(),
          _railCredentialCopy(),
          pw.Spacer(),
          pw.Container(
            width: double.infinity,
            height: 0.8,
            color: _railDivider,
          ),
          pw.SizedBox(height: 13),
          pw.Text(
            certificate.trackLabel.toUpperCase(),
            maxLines: 2,
            overflow: pw.TextOverflow.clip,
            style: pw.TextStyle(
              color: _circuit,
              fontSize: 7.2,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.45,
              lineSpacing: 1.15,
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            'PUBLIC CREDENTIAL // 01',
            style: pw.TextStyle(
              color: _faint,
              fontSize: 5.7,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.35,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _railBrand() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 31,
          height: 31,
          alignment: pw.Alignment.center,
          decoration: pw.BoxDecoration(
            color: _ember,
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: pw.Text(
            '>_',
            style: pw.TextStyle(
              color: _ink,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'NGODING',
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        pw.Text(
          'LOK',
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        pw.SizedBox(height: 7),
        pw.Text(
          'LEARN // BUILD // SHIP',
          style: pw.TextStyle(
            color: _signal,
            fontSize: 5.3,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.55,
          ),
        ),
      ],
    );
  }

  static pw.Widget _railCredentialCopy() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(width: 36, height: 2.4, color: _ember),
        pw.SizedBox(height: 13),
        pw.Text(
          'COMPLETION',
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 6.6,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.55,
          ),
        ),
        pw.Text(
          'CREDENTIAL',
          style: pw.TextStyle(
            color: _signal,
            fontSize: 6.6,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.55,
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Text(
          'A verifiable record of focused practice, issued from the Ngoding Lok learning floor.',
          maxLines: 4,
          overflow: pw.TextOverflow.clip,
          style: pw.TextStyle(color: _faint, fontSize: 6.8, lineSpacing: 1.45),
        ),
      ],
    );
  }

  static pw.Widget _paperCircuitMark() {
    return pw.SizedBox(
      width: 72,
      height: 38,
      child: pw.Stack(
        children: [
          pw.Positioned(
            left: 0,
            top: 0,
            child: pw.SizedBox(
              width: 61,
              height: 0.9,
              child: pw.Container(color: _circuit),
            ),
          ),
          pw.Positioned(
            right: 0,
            top: 0,
            child: pw.SizedBox(
              width: 0.9,
              height: 28,
              child: pw.Container(color: _ember),
            ),
          ),
          pw.Positioned(
            right: -1.1,
            top: 26.2,
            child: pw.Container(
              width: 3.2,
              height: 3.2,
              decoration: const pw.BoxDecoration(
                color: _ember,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _credentialContent(
    ModuleCertificate certificate,
    String verificationUrl,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _canvasHeader(),
        pw.SizedBox(height: 26),
        _heading(certificate),
        pw.SizedBox(height: 21),
        pw.Container(width: double.infinity, height: 0.9, color: _faint),
        pw.SizedBox(height: 19),
        _recipient(certificate),
        pw.SizedBox(height: 19),
        _completionCopy(certificate),
        pw.Spacer(),
        _credentialFooter(certificate, verificationUrl),
      ],
    );
  }

  static pw.Widget _canvasHeader() {
    return pw.Row(
      children: [
        pw.Container(width: 32, height: 2.3, color: _ember),
        pw.SizedBox(width: 9),
        pw.Expanded(
          child: pw.Text(
            'VERIFIED COMPLETION CREDENTIAL',
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
            style: pw.TextStyle(
              color: _slate,
              fontSize: 6.6,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.85,
            ),
          ),
        ),
        pw.SizedBox(width: 7),
        _verificationMark(),
      ],
    );
  }

  static pw.Widget _verificationMark() {
    return pw.Container(
      width: 14,
      height: 14,
      alignment: pw.Alignment.center,
      decoration: const pw.BoxDecoration(
        color: _signal,
        shape: pw.BoxShape.circle,
      ),
      child: pw.Text(
        '+',
        style: pw.TextStyle(
          color: _paper,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _heading(ModuleCertificate certificate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Certificate',
          style: pw.TextStyle(
            color: _ember,
            fontSize: 29,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: -0.75,
          ),
        ),
        pw.Text(
          'of achievement',
          style: pw.TextStyle(
            color: _ink,
            fontSize: 29,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: -0.85,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.FittedBox(
          fit: pw.BoxFit.scaleDown,
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            certificate.trackLabel,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 13.2,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _recipient(ModuleCertificate certificate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'THIS CREDENTIAL IS AWARDED TO',
          style: pw.TextStyle(
            color: _slate,
            fontSize: 6.5,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.78,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.FittedBox(
          fit: pw.BoxFit.scaleDown,
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            certificate.learnerName,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 27,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: -0.55,
            ),
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Container(width: double.infinity, height: 1, color: _signal),
      ],
    );
  }

  static pw.Widget _completionCopy(ModuleCertificate certificate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'FOR SUCCESSFULLY COMPLETING',
          style: pw.TextStyle(
            color: _slate,
            fontSize: 6.5,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.78,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          certificate.moduleTitle,
          maxLines: 2,
          overflow: pw.TextOverflow.clip,
          style: pw.TextStyle(
            color: _ink,
            fontSize: 14.5,
            fontWeight: pw.FontWeight.bold,
            lineSpacing: 1.08,
          ),
        ),
        if (certificate.moduleDescription.trim().isNotEmpty) ...[
          pw.SizedBox(height: 5),
          pw.Text(
            certificate.moduleDescription,
            maxLines: 2,
            overflow: pw.TextOverflow.clip,
            style: pw.TextStyle(
              color: _slate,
              fontSize: 7.8,
              lineSpacing: 1.35,
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _credentialFooter(
    ModuleCertificate certificate,
    String verificationUrl,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(child: _issuerAndFacts(certificate)),
        pw.SizedBox(width: 18),
        _verificationQr(verificationUrl),
      ],
    );
  }

  static pw.Widget _issuerAndFacts(ModuleCertificate certificate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.SizedBox(
          width: 136,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'NGODING LOK',
                style: pw.TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: pw.FontWeight.bold,
                  fontStyle: pw.FontStyle.italic,
                  letterSpacing: -0.55,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(width: 112, height: 0.8, color: _slate),
              pw.SizedBox(height: 4),
              pw.Text(
                'ISSUING STUDIO',
                style: pw.TextStyle(
                  color: _slate,
                  fontSize: 5.4,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 0.65,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 14),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 70,
              child: _footerFact('ISSUED', _date(certificate.issuedAt)),
            ),
            pw.SizedBox(width: 14),
            pw.SizedBox(
              width: 76,
              child: _footerFact(
                'MODULE SCORE',
                '${certificate.score} XP',
                valueColor: _signalInk,
              ),
            ),
            pw.SizedBox(width: 14),
            pw.Expanded(
              child: _footerFact(
                'CREDENTIAL ID',
                _certificateIdPreview(certificate.certificateId),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _footerFact(
    String label,
    String value, {
    PdfColor? valueColor,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          label,
          maxLines: 1,
          overflow: pw.TextOverflow.clip,
          style: pw.TextStyle(
            color: _slate,
            fontSize: 5.2,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          maxLines: 1,
          overflow: pw.TextOverflow.clip,
          style: pw.TextStyle(
            color: valueColor ?? _ink,
            fontSize: 7.6,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _verificationQr(String verificationUrl) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 104,
          height: 104,
          padding: const pw.EdgeInsets.all(7),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: _ink, width: 1.15),
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: verificationUrl,
            width: 90,
            height: 90,
            color: PdfColors.black,
            backgroundColor: PdfColors.white,
            drawText: false,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'SCAN TO VERIFY',
          style: pw.TextStyle(
            color: _slate,
            fontSize: 5.5,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.65,
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
    return '${date.day.toString().padLeft(2, '0')}'
        ' ${months[date.month - 1]} ${date.year}';
  }

  static String _certificateIdPreview(String certificateId) {
    if (certificateId.length <= 22) return certificateId;
    return '${certificateId.substring(0, 13)}...'
        '${certificateId.substring(certificateId.length - 6)}';
  }
}

class _AwardSeal extends pw.StatelessWidget {
  _AwardSeal();

  @override
  pw.Widget build(pw.Context context) {
    return pw.SizedBox(
      width: 86,
      height: 101,
      child: pw.Stack(
        alignment: pw.Alignment.topCenter,
        overflow: pw.Overflow.visible,
        children: [
          pw.Positioned(
            top: 53,
            child: pw.Container(
              width: 46,
              height: 36,
              color: CertificatePdf._ember,
            ),
          ),
          pw.Container(
            width: 86,
            height: 86,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              color: CertificatePdf._paper,
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: CertificatePdf._signal, width: 4),
            ),
            child: pw.Container(
              width: 35,
              height: 27,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: CertificatePdf._ink, width: 2.2),
                borderRadius: pw.BorderRadius.circular(2),
              ),
              child: pw.Text(
                '>_',
                style: pw.TextStyle(
                  color: CertificatePdf._ink,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
