import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/lab_result.dart';

class LabPdfGenerator {
  static const _colorNormal = PdfColors.black;
  static const _colorLow = PdfColor.fromInt(0xFF1D4ED8); // blue
  static const _colorHigh = PdfColor.fromInt(0xFFEA580C); // orange
  static const _colorCritical = PdfColor.fromInt(0xFFDC2626); // red
  static const _colorGreen = PdfColor.fromInt(0xFF15803D);
  static const _colorHeaderBg = PdfColor.fromInt(0xFF006629);
  static const _colorRowAlt = PdfColor.fromInt(0xFFF0FDF4);
  static const _colorBorder = PdfColor.fromInt(0xFFD1FAE5);

  static PdfColor _statusColor(String status) {
    switch (status) {
      case 'critical':
        return _colorCritical;
      case 'high':
        return _colorHigh;
      case 'low':
        return _colorLow;
      default:
        return _colorNormal;
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'critical':
        return 'KRITIS';
      case 'high':
        return 'TINGGI';
      case 'low':
        return 'RENDAH';
      default:
        return 'NORMAL';
    }
  }

  static Future<String> generate({
    required List<LabResult> results,
    required String nmPasien,
    required String noRm,
    required String tglPeriksa,
    required String nmDokter,
  }) async {
    final pdf = pw.Document();
    final tanggalCetak = DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.now());

    String formattedTgl = tglPeriksa;
    try {
      formattedTgl = DateFormat('dd MMMM yyyy', 'id_ID')
          .format(DateTime.parse(tglPeriksa));
    } catch (_) {}

    // Separate header rows (nilai empty) from data rows
    final headerRows = results.where((r) => r.nilai.trim().isEmpty).toList();
    final dataRows = results.where((r) => r.nilai.trim().isNotEmpty).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(nmPasien, noRm, formattedTgl, nmDokter),
        footer: (context) => _buildFooter(tanggalCetak, context),
        build: (context) => [
          pw.SizedBox(height: 16),
          _buildResultTable(headerRows, dataRows),
          pw.SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/hasil_lab_${noRm}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return path;
  }

  static pw.Widget _buildHeader(
    String nmPasien,
    String noRm,
    String tglPeriksa,
    String nmDokter,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Hospital header
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const pw.BoxDecoration(
            color: _colorHeaderBg,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'RSUD KOTA BAU-BAU',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Hasil Pemeriksaan Laboratorium',
                style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 11),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        // Patient info
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: _colorBorder),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            color: _colorRowAlt,
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _infoRow('Pasien', nmPasien),
                    pw.SizedBox(height: 4),
                    _infoRow('No. RM', noRm),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _infoRow('Tanggal Periksa', tglPeriksa),
                    pw.SizedBox(height: 4),
                    _infoRow('Dokter Pemeriksa', nmDokter.isNotEmpty ? nmDokter : '-'),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: _colorBorder, thickness: 1),
      ],
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label: ',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.TextSpan(
            text: value,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildResultTable(
    List<LabResult> headerRows,
    List<LabResult> dataRows,
  ) {
    const colWidths = [
      pw.FlexColumnWidth(3.5), // Pemeriksaan
      pw.FlexColumnWidth(1.5), // Hasil
      pw.FlexColumnWidth(1.2), // Satuan
      pw.FlexColumnWidth(2.0), // Nilai Normal
      pw.FlexColumnWidth(1.3), // Status
    ];

    return pw.Table(
      columnWidths: {
        0: colWidths[0],
        1: colWidths[1],
        2: colWidths[2],
        3: colWidths[3],
        4: colWidths[4],
      },
      border: pw.TableBorder.all(color: _colorBorder, width: 0.5),
      children: [
        // Table header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _colorHeaderBg),
          children: [
            _headerCell('PEMERIKSAAN'),
            _headerCell('HASIL'),
            _headerCell('SATUAN'),
            _headerCell('NILAI NORMAL'),
            _headerCell('STATUS'),
          ],
        ),
        // Data rows
        ...dataRows.asMap().entries.map((entry) {
          final i = entry.key;
          final row = entry.value;
          final isAlt = i % 2 == 1;
          final status = row.status;
          final color = _statusColor(status);
          final isCritical = status == 'critical';

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isAlt ? _colorRowAlt : PdfColors.white,
            ),
            children: [
              _dataCell(row.nmPerawatan, textColor: PdfColors.black),
              _dataCell(
                row.nilai,
                textColor: color,
                bold: isCritical || status != 'normal',
              ),
              _dataCell(row.satuan, textColor: PdfColors.grey700),
              _dataCell(row.nilaiRujukan, textColor: PdfColors.grey700),
              _statusCell(status, color),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _dataCell(
    String text, {
    PdfColor textColor = PdfColors.black,
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          color: textColor,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _statusCell(String status, PdfColor color) {
    if (status == 'normal') {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Center(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: pw.BoxDecoration(
              color: _colorGreen,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              'NORMAL',
              style: pw.TextStyle(
                fontSize: 7,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Center(
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text(
            _statusLabel(status),
            style: pw.TextStyle(
              fontSize: 7,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildLegend() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _colorBorder),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        color: _colorRowAlt,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Keterangan Warna:',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              _legendItem('NORMAL', _colorGreen),
              pw.SizedBox(width: 16),
              _legendItem('RENDAH', _colorLow),
              pw.SizedBox(width: 16),
              _legendItem('TINGGI', _colorHigh),
              pw.SizedBox(width: 16),
              _legendItem('KRITIS', _colorCritical),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '* Harap konsultasikan hasil ini dengan dokter Anda. Nilai normal dapat berbeda berdasarkan jenis kelamin dan usia.',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _legendItem(String label, PdfColor color) {
    return pw.Row(
      children: [
        pw.Container(
          width: 12,
          height: 12,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  static pw.Widget _buildFooter(String tanggalCetak, pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(color: _colorBorder, thickness: 0.5),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Dicetak: $tanggalCetak • Aplikasi SiSehat Bau-Bau',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
            ),
            pw.Text(
              'Halaman ${context.pageNumber}/${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500),
            ),
          ],
        ),
      ],
    );
  }
}
