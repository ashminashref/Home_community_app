import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptPdfService {
  ReceiptPdfService._();

  static Future<Uint8List> generateReceiptPdf({
    required String mahalName,
    required String mahalLocation,
    required String receiptNo,
    required String memberName,
    required String houseName,
    required String familyId,
    required String purpose,
    required double amount,
    required DateTime date,
    required String paymentMode,
  }) async {
    final pdf = pw.Document();

    final emerald = PdfColor.fromHex('0E3E2E');
    final mint = PdfColor.fromHex('E8F3EE');
    final darkGrey = PdfColor.fromHex('1A202C');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: emerald, width: 2),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header
                pw.Center(
                  child: pw.Text(
                    mahalName,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: emerald,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    mahalLocation,
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Divider(color: emerald, thickness: 1),
                pw.SizedBox(height: 8),

                // Receipt Title & Number
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'OFFICIAL RECEIPT',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: darkGrey,
                      ),
                    ),
                    pw.Text(
                      'Receipt No: $receiptNo',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: emerald,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Member Details Table
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: mint,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      _buildRow('Member Name:', memberName),
                      pw.SizedBox(height: 6),
                      _buildRow('House Name:', houseName),
                      pw.SizedBox(height: 6),
                      _buildRow('Family ID:', familyId),
                      pw.SizedBox(height: 6),
                      _buildRow('Contribution Type:', purpose),
                      pw.SizedBox(height: 6),
                      _buildRow('Payment Mode:', paymentMode),
                      pw.SizedBox(height: 6),
                      _buildRow('Date:', '${date.day}/${date.month}/${date.year}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // Amount
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: emerald,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Amount Paid:',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'INR ${amount.toStringAsFixed(0)}',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),

                // Footer signatures
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Container(width: 80, height: 1, color: PdfColors.grey500),
                        pw.SizedBox(height: 4),
                        pw.Text('General Secretary', style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Container(width: 80, height: 1, color: PdfColors.grey500),
                        pw.SizedBox(height: 4),
                        pw.Text('Treasurer', style: const pw.TextStyle(fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
        pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static Future<void> shareOrPrintReceipt({
    required String mahalName,
    required String mahalLocation,
    required String receiptNo,
    required String memberName,
    required String houseName,
    required String familyId,
    required String purpose,
    required double amount,
    required DateTime date,
    required String paymentMode,
  }) async {
    final pdfBytes = await generateReceiptPdf(
      mahalName: mahalName,
      mahalLocation: mahalLocation,
      receiptNo: receiptNo,
      memberName: memberName,
      houseName: houseName,
      familyId: familyId,
      purpose: purpose,
      amount: amount,
      date: date,
      paymentMode: paymentMode,
    );

    await Printing.sharePdf(bytes: pdfBytes, filename: '$receiptNo.pdf');
  }
}

