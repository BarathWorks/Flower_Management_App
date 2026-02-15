import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/bill.dart';
import 'formatters.dart';

class BillPdfHelper {
  static Future<pw.Document> generatePdf(Bill bill) async {
    final pdf = pw.Document();

    print('DEBUG: BillPdfHelper received bill with ${bill.items.length} items');

    // Load Tamil font with fallback
    pw.Font font;
    bool isTamilFontLoaded = false;
    try {
      // Attempt to load the font. This might throw if assets are missing, which is expected in some environments.
      font = await PdfGoogleFonts.tiroTamilRegular();
      isTamilFontLoaded = true;
    } catch (e) {
      // Only log if it's not the expected AssetManifest error to reduce noise
      if (!e.toString().contains('AssetManifest')) {
        print('Warning: Failed to load Tamil font: $e');
      }
      font = pw.Font.courier(); // Fallback
    }

    final headers = isTamilFontLoaded
        ? ['தேதி', 'விபரம்', '', 'வரவு']
        : ['Date', 'Details', '', 'Credit'];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Top Contact Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Cell : 9500373639',
                      style: pw.TextStyle(fontSize: 10)),
                  pw.Text('Cell : 9486185725',
                      style: pw.TextStyle(fontSize: 10)),
                ],
              ),

              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'M.R.B.',
                      style: pw.TextStyle(
                        fontSize: 36,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green,
                      ),
                    ),
                    pw.Text(
                      isTamilFontLoaded
                          ? 'புஷ்ப வியாபாரம் & கமிஷன் மண்டி'
                          : 'Flower Merchant & Commission Mandi',
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      isTamilFontLoaded
                          ? 'நெ. 18/16, ஜோதி மார்க்கெட், திருவண்ணாமலை.'
                          : 'No. 18/16, Jothi Market, Tiruvannamalai.',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(5)),
                      ),
                      child: pw.Text(
                          isTamilFontLoaded
                              ? 'உரிமை : M. ரமேஷ்பாபு'
                              : 'Prop : M. Ramesh Babu',
                          style: pw.TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 15),

              // Customer / Ref Info
              pw.Row(
                children: [
                  pw.Expanded(
                      child: pw.Text(
                          '${isTamilFontLoaded ? 'திரு.' : 'Mr.'} : ${bill.customerName ?? 'EHM'}')),
                  pw.Expanded(
                      child: pw.Text(
                          '${isTamilFontLoaded ? 'தேதி' : 'Date'} : ${AppFormatters.formatDate(bill.generatedAt)}')),
                ],
              ),
              pw.Text('${isTamilFontLoaded ? 'ஊர்' : 'Place'} : ${'ANR'}'),

              pw.SizedBox(height: 10),

              // Main Transaction Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.green800),
                columnWidths: {
                  0: const pw.FixedColumnWidth(40), // Date
                  1: const pw.FlexColumnWidth(2), // Details (Name + Qty x Rate)
                  2: const pw.FixedColumnWidth(60), // Misc/Empty
                  3: const pw.FixedColumnWidth(80), // Total
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    children: [
                      _headerCell(headers[0]),
                      _headerCell(headers[1]),
                      _headerCell(headers[2]),
                      _headerCell(headers[3]),
                    ],
                  ),
                  // Bill Items
                  ...bill.items.map((item) {
                    final dateStr = AppFormatters.formatShortDate(item.date);
                    // Include flower name in details
                    final detailsStr =
                        '${item.flowerName}\n${item.quantity.toInt()} X ${item.rate.toInt()}';
                    final amountStr = item.totalAmount.toStringAsFixed(0);
                    print(
                        'DEBUG: Adding row: $dateStr | $detailsStr | $amountStr');
                    return pw.TableRow(
                      children: [
                        _dataCell(dateStr), // e.g. 30/1
                        _dataCell(detailsStr),
                        _dataCell(''),
                        _dataCell(amountStr, align: pw.Alignment.centerRight),
                      ],
                    );
                  }).toList(),

                  // Total Calculation Row
                  pw.TableRow(
                    children: [
                      pw.SizedBox(),
                      pw.SizedBox(),
                      _dataCell('Total', align: pw.Alignment.centerRight),
                      _dataCell(bill.totalAmount.toStringAsFixed(0),
                          align: pw.Alignment.centerRight),
                    ],
                  ),
                ],
              ),

              // Deductions footer
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 140,
                  child: pw.Column(
                    children: [
                      pw.Divider(color: PdfColors.black),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                              isTamilFontLoaded ? 'கமிஷன்:' : 'Commission:'),
                          pw.Text(
                              '- ${bill.totalCommission.toStringAsFixed(0)}'),
                        ],
                      ),
                      pw.Divider(thickness: 2),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(isTamilFontLoaded ? 'மொத்தம்:' : 'Total:',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(bill.netAmount.toStringAsFixed(0),
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Center(
          child: pw.Text(text,
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
    );
  }

  static pw.Widget _dataCell(String text,
      {pw.Alignment align = pw.Alignment.centerLeft}) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 11)),
    );
  }
}
