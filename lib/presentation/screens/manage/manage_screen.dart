import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/typography.dart';
import 'customer_list_view.dart';
import 'flower_list_view.dart';
import '../settings/settings_screen.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage',
                      style: AppTypography.headlineLarge,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.settings,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Manage flowers and customers',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryEmerald,
              labelColor: AppColors.primaryEmerald,
              unselectedLabelColor: AppColors.textTertiary,
              labelStyle: AppTypography.labelLarge,
              tabs: const [
                Tab(text: 'Flowers'),
                Tab(text: 'Customers'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                FlowerListView(),
                CustomerListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
