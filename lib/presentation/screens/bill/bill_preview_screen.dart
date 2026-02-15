import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../core/utils/bill_pdf_helper.dart';
import '../../../domain/entities/bill.dart';

class BillPreviewScreen extends StatelessWidget {
  final Bill bill;

  const BillPreviewScreen({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Preview: ${bill.billNumber}'),
      ),
      body: PdfPreview(
        build: (format) =>
            BillPdfHelper.generatePdf(bill).then((pdf) => pdf.save()),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        // Using A4 format by default as defined in BillPdfHelper
      ),
    );
  }
}
