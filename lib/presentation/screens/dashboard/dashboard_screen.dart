import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/typography.dart';
import '../../bloc/dashboard/dashboard_bloc.dart';
import '../../bloc/dashboard/dashboard_event.dart';
import '../../bloc/dashboard/dashboard_state.dart';
import '../../widgets/summary_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardBloc>().add(RefreshDashboard());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: AppTypography.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Overview of your flower business',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryEmerald,
                      ),
                    );
                  }

                  if (state is DashboardError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    );
                  }

                  if (state is DashboardLoaded) {
                    final summary = state.summary;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                title: 'Weekly Sales',
                                value: AppFormatters.formatCurrency(
                                    summary.weeklySales),
                                icon: Icons.trending_up_rounded,
                                iconColor: AppColors.successGreen,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: SummaryCard(
                                title: 'Monthly Profit',
                                value: AppFormatters.formatCurrency(
                                    summary.monthlyProfit),
                                icon: Icons.account_balance_wallet_rounded,
                                iconColor: AppColors.primaryEmerald,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                title: 'Total Customers',
                                value: summary.totalCustomers.toString(),
                                icon: Icons.people_rounded,
                                iconColor: AppColors.infoBlue,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: SummaryCard(
                                title: 'Total Flowers',
                                value: summary.totalFlowers.toString(),
                                icon: Icons.local_florist_rounded,
                                iconColor: AppColors.accentOrange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                title: 'Pending Payments',
                                value: AppFormatters.formatCurrency(
                                    summary.pendingPayments),
                                icon: Icons.payment_rounded,
                                iconColor: AppColors.warningAmber,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: SummaryCard(
                                title: 'Today Transactions',
                                value: summary.todayTransactions.toString(),
                                icon: Icons.receipt_long_rounded,
                                iconColor: AppColors.primaryEmerald,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
