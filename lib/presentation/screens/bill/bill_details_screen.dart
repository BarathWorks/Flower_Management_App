import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/typography.dart';
import '../../../domain/entities/bill.dart';
import '../../bloc/bill/bill_bloc.dart';
import '../../bloc/bill/bill_event.dart';
import '../../bloc/bill/bill_state.dart';

class BillDetailsScreen extends StatefulWidget {
  final String billId;
  final String billNumber;

  const BillDetailsScreen({
    super.key,
    required this.billId,
    required this.billNumber,
  });

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BillBloc>().add(LoadBillDetails(widget.billId));
  }

  Future<void> _printBill(Bill bill) async {
    final pdf = await _generatePdf(bill);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<pw.Document> _generatePdf(Bill bill) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 2),
                ),
                child: pw.Column(
                  children: [
                    // Contact numbers
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('AG: 9789129544',
                            style: pw.TextStyle(fontSize: 10)),
                        pw.Text('JV: 9600687289',
                            style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    // Business name
                    pw.Text(
                      'PDA',
                      style: pw.TextStyle(
                        fontSize: 48,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red,
                      ),
                    ),
                    pw.Text(
                      'புஷ்பா வியாபாரம் & கமிஷன் மண்டிரை',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'கோச்சி மாரிவேட், திருவன்னாமலை',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                    pw.SizedBox(height: 8),
                    // Customer name
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(),
                      ),
                      child: pw.Text(
                        'உரிமை: ${bill.customerName}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              // Bill info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'இரு: ${bill.billNumber}',
                    style: pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    AppFormatters.formatDate(bill.generatedAt),
                    style: pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              // Table header
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('எண்',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('எடை',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('விலை',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('கமிஷன்',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('மொத்தம்',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Items
                  ...bill.items.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final item = entry.value;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(index.toString()),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(item.totalQuantity.toStringAsFixed(3)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(item.totalAmount.toStringAsFixed(0)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(item.totalCommission.toStringAsFixed(0)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(item.netAmount.toStringAsFixed(0)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 16),
              // Totals
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('மொத்தம்',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          bill.totalAmount.toStringAsFixed(0),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('கமிஷன்',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          bill.totalCommission.toStringAsFixed(0),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('பட்டி',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          bill.netAmount.toStringAsFixed(0),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Bill: ${widget.billNumber}'),
        backgroundColor: AppColors.primaryEmerald,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<BillBloc, BillState>(
        listener: (context, state) {
          if (state is BillError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BillLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryEmerald,
              ),
            );
          }

          if (state is BillDetailsLoaded) {
            final bill = state.bill;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bill Header Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Customer',
                                  style: AppTypography.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bill.customerName,
                                  style: AppTypography.titleLarge,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: bill.status == 'PAID'
                                    ? AppColors.successGreen.withOpacity(0.2)
                                    : AppColors.warningAmber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                bill.status,
                                style: AppTypography.bodySmall.copyWith(
                                  color: bill.status == 'PAID'
                                      ? AppColors.successGreen
                                      : AppColors.warningAmber,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Period', style: AppTypography.bodySmall),
                                const SizedBox(height: 4),
                                Text(
                                  AppFormatters.formatMonthYear(
                                      bill.billYear, bill.billMonth),
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Generated', style: AppTypography.bodySmall),
                                const SizedBox(height: 4),
                                Text(
                                  AppFormatters.formatDate(bill.generatedAt),
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Items Header
                  Text('Items', style: AppTypography.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  // Items List
                  if (bill.items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          'No items found',
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ...bill.items.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.flowerName,
                              style: AppTypography.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Quantity', style: AppTypography.bodySmall),
                                    Text(
                                      '${item.totalQuantity.toStringAsFixed(3)} kg',
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Amount', style: AppTypography.bodySmall),
                                    Text(
                                      AppFormatters.formatCurrency(item.totalAmount),
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Commission', style: AppTypography.bodySmall),
                                    Text(
                                      AppFormatters.formatCurrency(item.totalCommission),
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Net Amount', style: AppTypography.bodySmall),
                                    Text(
                                      AppFormatters.formatCurrency(item.netAmount),
                                      style: AppTypography.titleMedium.copyWith(
                                        color: AppColors.primaryEmerald,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: AppSpacing.lg),
                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.primaryEmerald,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Quantity', style: AppTypography.bodyMedium),
                            Text(
                              '${bill.totalQuantity.toStringAsFixed(3)} kg',
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount', style: AppTypography.bodyMedium),
                            Text(
                              AppFormatters.formatCurrency(bill.totalAmount),
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Commission', style: AppTypography.bodyMedium),
                            Text(
                              AppFormatters.formatCurrency(bill.totalCommission),
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Expenses', style: AppTypography.bodyMedium),
                            Text(
                              AppFormatters.formatCurrency(bill.totalExpense),
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Net Amount', style: AppTypography.titleLarge),
                            Text(
                              AppFormatters.formatCurrency(bill.netAmount),
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.primaryEmerald,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Print Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _printBill(bill),
                      icon: const Icon(Icons.print),
                      label: const Text('Print Bill'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryEmerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(AppSpacing.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.screenVertical),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
