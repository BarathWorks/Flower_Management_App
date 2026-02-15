import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/typography.dart';
import '../../bloc/bill/bill_bloc.dart';
import '../../bloc/bill/bill_event.dart';
import '../../bloc/bill/bill_state.dart';
import 'bill_details_screen.dart';
import 'generate_bill_screen.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BillBloc>().add(LoadAllBills());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bills',
                        style: AppTypography.headlineLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Monthly customer bills',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenerateBillScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Generate Bill'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<BillBloc, BillState>(
              listener: (context, state) {
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
                }
              },
              builder: (context, state) {
                if (state is BillLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryEmerald),
                  );
                }

                if (state is BillListLoaded) {
                  if (state.bills.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_rounded,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No bills generated yet',
                            style: AppTypography.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<BillBloc>().add(RefreshBills());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        0,
                        AppSpacing.screenHorizontal,
                        AppSpacing.screenVertical,
                      ),
                      itemCount: state.bills.length,
                      itemBuilder: (context, index) {
                        final bill = state.bills[index];
                        return InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BillDetailsScreen(
                                  billId: bill.id,
                                  billNumber: bill.billNumber,
                                ),
                              ),
                            );

                            if (context.mounted) {
                              context.read<BillBloc>().add(LoadAllBills());
                            }
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryEmerald
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.sm),
                                      ),
                                      child: const Icon(
                                        Icons.description_rounded,
                                        color: AppColors.primaryEmerald,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bill.billNumber,
                                            style: AppTypography.titleMedium,
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            bill.customerName,
                                            style: AppTypography.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Removed broken print button here. Users must open details to print.
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: bill.status == 'PAID'
                                            ? AppColors.successGreen
                                                .withOpacity(0.2)
                                            : AppColors.warningAmber
                                                .withOpacity(0.2),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppFormatters.formatMonthYear(
                                          bill.billYear, bill.billMonth),
                                      style: AppTypography.bodySmall,
                                    ),
                                    Text(
                                      AppFormatters.formatCurrency(
                                          bill.netAmount),
                                      style: AppTypography.titleMedium.copyWith(
                                        color: AppColors.primaryEmerald,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
