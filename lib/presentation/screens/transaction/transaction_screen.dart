import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/typography.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/transaction/transaction_state.dart';
import 'add_transaction_screen.dart';
import 'customer_details_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    if (_isToday(_selectedDate)) {
      context.read<TransactionBloc>().add(LoadTodayDailyEntries());
    } else {
      context
          .read<TransactionBloc>()
          .add(LoadDailyEntriesByDate(_selectedDate));
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadTransactions();
    }
  }

  void _resetToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _loadTransactions();
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
                        'Transactions',
                        style: AppTypography.headlineLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _isToday(_selectedDate)
                            ? 'Today\'s flower transactions'
                            : 'Transactions for ${AppFormatters.formatDate(_selectedDate)}',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (!_isToday(_selectedDate))
                  IconButton(
                    onPressed: _resetToToday,
                    tooltip: 'Reset to Today',
                    icon: const Icon(Icons.today_rounded),
                    color: AppColors.primaryEmerald,
                  ),
                IconButton(
                  onPressed: () => _selectDate(context),
                  tooltip: 'Select Date',
                  icon: const Icon(Icons.calendar_month_rounded),
                  color: AppColors.primaryEmerald,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(),
                      ),
                    );
                  },
                  tooltip: 'Add Transaction',
                  icon: const Icon(Icons.add_circle_rounded),
                  color: AppColors.primaryEmerald,
                  iconSize: 32,
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<TransactionBloc, TransactionState>(
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

                if (state is DailyEntriesLoaded) {
                  if (state.entries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _isToday(_selectedDate)
                                ? 'No transactions today'
                                : 'No transactions on this date',
                            style: AppTypography.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      // We need to reload based on selected date, but RefreshTransactions usually just reloads today or current view.
                      // Ideally RefreshTransactions event should handle current view context or we just trigger load again.
                      // For now, let's just trigger load again for simplicity.
                      _loadTransactions();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        0,
                        AppSpacing.screenHorizontal,
                        AppSpacing.screenVertical,
                      ),
                      itemCount: state.entries.length,
                      itemBuilder: (context, index) {
                        final entry = state.entries[index];
                        return InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerDetailsScreen(
                                  dailyEntryId: entry.id,
                                  flowerName: entry.flowerName,
                                  entryDate: entry.entryDate,
                                ),
                              ),
                            );
                            if (context.mounted) {
                              _loadTransactions();
                            }
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color:
                                    AppColors.primaryEmerald.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
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
                                    Icons.local_florist_rounded,
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
                                        entry.flowerName,
                                        style:
                                            AppTypography.titleMedium.copyWith(
                                          color: AppColors.primaryEmerald,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        '${entry.customerCount} customers • ${entry.totalQuantity.toStringAsFixed(0)} qty',
                                        style: AppTypography.bodySmall,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Row(
                                        children: [
                                          Text(
                                            '₹${entry.totalAmount.toStringAsFixed(2)}',
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            ' - ₹${entry.totalCommission.toStringAsFixed(2)}',
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                              color: AppColors.accentOrange,
                                            ),
                                          ),
                                          Text(
                                            ' = ₹${entry.netAmount.toStringAsFixed(2)}',
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                              color: AppColors.successGreen,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
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
