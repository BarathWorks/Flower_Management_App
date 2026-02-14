import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/typography.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../widgets/gradient_scaffold.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String dailyEntryId;
  final String flowerName;
  final DateTime entryDate;

  const CustomerDetailsScreen({
    super.key,
    required this.dailyEntryId,
    required this.flowerName,
    required this.entryDate,
  });

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(
          LoadCustomerDetailsForEntry(widget.dailyEntryId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.flowerName, style: AppTypography.headlineSmall),
            Text(
              AppFormatters.formatDate(widget.entryDate),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is TransactionOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.successGreen,
              ),
            );
            // Reload details after successful operation
            context.read<TransactionBloc>().add(
                  LoadCustomerDetailsForEntry(widget.dailyEntryId),
                );
          }
        },
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryEmerald,
              ),
            );
          }

          if (state is CustomerDetailsLoaded) {
            if (state.details.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off_rounded,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No customer details found',
                      style: AppTypography.bodyLarge,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              itemCount: state.details.length,
              itemBuilder: (context, index) {
                final detail = state.details[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryEmerald.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryEmerald,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.customerName,
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.primaryEmerald,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${detail.quantity.toStringAsFixed(0)} × ₹${detail.rate.toStringAsFixed(2)}',
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                Text(
                                  '₹${detail.amount.toStringAsFixed(2)}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' - ₹${detail.commission.toStringAsFixed(2)}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.accentOrange,
                                  ),
                                ),
                                Text(
                                  ' = ₹${detail.netAmount.toStringAsFixed(2)}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.successGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _showDeleteDialog(context, detail.id),
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: AppColors.error,
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Delete Transaction', style: AppTypography.headlineSmall),
        content: Text(
          'Are you sure you want to delete this transaction?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTypography.labelLarge),
          ),
          TextButton(
            onPressed: () {
              context.read<TransactionBloc>().add(
                    DeleteTransactionEvent(transactionId),
                  );
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Go back to daily entries screen
            },
            child: Text(
              'Delete',
              style: AppTypography.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
