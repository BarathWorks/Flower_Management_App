import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';

import 'package:printing/printing.dart';
import '../../../core/utils/bill_pdf_helper.dart';
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
    print('DEBUG: _printBillUI called with ${bill.items.length} items');
    final pdf = await BillPdfHelper.generatePdf(bill);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _showAddPaymentDialog(BuildContext context, Bill bill) {
    final amountController = TextEditingController(
      text: (bill.netAmount - bill.paidAmount).toStringAsFixed(2),
    );
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: Text('Add Payment', style: AppTypography.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    AppFormatters.formatDate(selectedDate),
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: notesController,
                style: AppTypography.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTypography.bodyMedium),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid amount')),
                  );
                  return;
                }

                context.read<BillBloc>().add(
                      AddPaymentEvent(
                        billId: bill.id,
                        amount: amount,
                        date: selectedDate,
                        notes: notesController.text.isEmpty
                            ? null
                            : notesController.text,
                      ),
                    );
                Navigator.pop(context);
              },
              child: Text(
                'Add Payment',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.successGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillBloc, BillState>(listener: (context, state) {
      if (state is BillError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (state is BillOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.successGreen,
          ),
        );
        if (state.message.contains('deleted')) {
          Navigator.pop(context, true);
        }
      }
    }, builder: (context, state) {
      if (state is BillLoading) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryEmerald,
          ),
        );
      }

      if (state is BillDetailsLoaded) {
        final bill = state.bill;
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            if (didPop) {
              context.read<BillBloc>().add(LoadAllBills());
            }
          },
          child: Scaffold(
              backgroundColor: AppColors.backgroundDark,
              appBar: AppBar(
                title: Text('Bill: ${widget.billNumber}'),
                backgroundColor: AppColors.primaryEmerald,
                foregroundColor: Colors.white,
                actions: [
                  if (bill.status != 'PAID')
                    IconButton(
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.surfaceDark,
                            title: Text('Delete Bill',
                                style: AppTypography.titleLarge),
                            content: Text(
                              'Are you sure you want to delete this bill? This action cannot be undone.',
                              style: AppTypography.bodyMedium,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel',
                                    style: AppTypography.bodyMedium),
                              ),
                              TextButton(
                                onPressed: () {
                                  context
                                      .read<BillBloc>()
                                      .add(DeleteBillEvent(bill.id));
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Delete',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              body: SingleChildScrollView(
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
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
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
                                  Text('Period',
                                      style: AppTypography.bodySmall),
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
                                  Text('Generated',
                                      style: AppTypography.bodySmall),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Quantity',
                                          style: AppTypography.bodySmall),
                                      Text(
                                        '${item.quantity.toStringAsFixed(3)} kg',
                                        style: AppTypography.bodyMedium,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Amount',
                                          style: AppTypography.bodySmall),
                                      Text(
                                        AppFormatters.formatCurrency(
                                            item.totalAmount),
                                        style: AppTypography.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Commission',
                                          style: AppTypography.bodySmall),
                                      Text(
                                        AppFormatters.formatCurrency(
                                            item.totalCommission),
                                        style:
                                            AppTypography.bodyMedium.copyWith(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Net Amount',
                                          style: AppTypography.bodySmall),
                                      Text(
                                        AppFormatters.formatCurrency(
                                            item.netAmount),
                                        style:
                                            AppTypography.titleMedium.copyWith(
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
                              Text('Total Quantity',
                                  style: AppTypography.bodyMedium),
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
                              Text('Total Amount',
                                  style: AppTypography.bodyMedium),
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
                              Text('Total Commission',
                                  style: AppTypography.bodyMedium),
                              Text(
                                AppFormatters.formatCurrency(
                                    bill.totalCommission),
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
                              Text('Net Amount',
                                  style: AppTypography.titleLarge),
                              Text(
                                AppFormatters.formatCurrency(bill.netAmount),
                                style: AppTypography.titleLarge.copyWith(
                                  color: AppColors.primaryEmerald,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Paid Amount',
                                  style: AppTypography.bodyMedium),
                              Text(
                                AppFormatters.formatCurrency(bill.paidAmount),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.successGreen,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Balance Due',
                                  style: AppTypography.titleLarge),
                              Text(
                                AppFormatters.formatCurrency(
                                    bill.netAmount - bill.paidAmount),
                                style: AppTypography.titleLarge.copyWith(
                                  color: (bill.netAmount - bill.paidAmount) > 0
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Payment History
                    if (bill.payments.isNotEmpty) ...[
                      Text('Payment History',
                          style: AppTypography.headlineMedium),
                      const SizedBox(height: AppSpacing.md),
                      ...bill.payments.map((payment) => Container(
                            margin:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppFormatters.formatDate(payment.date),
                                      style: AppTypography.bodyMedium,
                                    ),
                                    if (payment.notes != null &&
                                        payment.notes!.isNotEmpty)
                                      Text(
                                        payment.notes!,
                                        style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.textSecondary),
                                      ),
                                  ],
                                ),
                                Text(
                                  AppFormatters.formatCurrency(payment.amount),
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.successGreen,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],

                    const SizedBox(height: AppSpacing.xl),
                    // Add Payment Button
                    if (bill.status != 'PAID') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddPaymentDialog(context, bill),
                          icon: const Icon(Icons.add_card),
                          label: const Text('Add Payment'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryEmerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(AppSpacing.md),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
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
              )),
        );
      }

      return const SizedBox.shrink();
    });
  }
}
