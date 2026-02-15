import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/typography.dart';
import '../../bloc/flower/flower_bloc.dart';
import '../../bloc/flower/flower_event.dart';
import '../../bloc/flower/flower_state.dart';

class FlowerListView extends StatefulWidget {
  const FlowerListView({super.key});

  @override
  State<FlowerListView> createState() => _FlowerListViewState();
}

class _FlowerListViewState extends State<FlowerListView> {
  @override
  void initState() {
    super.initState();
    context.read<FlowerBloc>().add(LoadFlowers());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocConsumer<FlowerBloc, FlowerState>(
            listener: (context, state) {
              if (state is FlowerError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
              if (state is FlowerOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is FlowerLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryEmerald),
                );
              }

              if (state is FlowerLoaded) {
                if (state.flowers.isEmpty) {
                  return Center(
                    child: Text('No flowers added yet',
                        style: AppTypography.bodyLarge),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  itemCount: state.flowers.length,
                  itemBuilder: (context, index) {
                    final flower = state.flowers[index];
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
                              Icons.local_florist_rounded,
                              color: AppColors.primaryEmerald,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(flower.name,
                                style: AppTypography.titleMedium),
                          ),
                          IconButton(
                            onPressed: () {
                              _showDeleteDialog(
                                  context, flower.id, flower.name);
                            },
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
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context),
            backgroundColor: AppColors.primaryEmerald,
            icon: const Icon(Icons.add),
            label: Text('Add Flower', style: AppTypography.labelLarge),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    final rateController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Add Flower', style: AppTypography.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Flower name',
                hintStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: rateController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Default Rate (Optional)',
                hintStyle: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.backgroundDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTypography.labelLarge),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final rate = double.tryParse(rateController.text);
                context.read<FlowerBloc>().add(AddFlowerEvent(
                      controller.text,
                      defaultRate: rate,
                    ));
                Navigator.pop(dialogContext);
              }
            },
            child: Text('Add',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primaryEmerald,
                )),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Delete Flower', style: AppTypography.headlineSmall),
        content: Text(
          'Are you sure you want to delete $name?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTypography.labelLarge),
          ),
          TextButton(
            onPressed: () {
              context.read<FlowerBloc>().add(DeleteFlowerEvent(id));
              Navigator.pop(dialogContext);
            },
            child: Text('Delete',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.error,
                )),
          ),
        ],
      ),
    );
  }
}
