import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/typography.dart';
import '../../bloc/customer/customer_bloc.dart';
import '../../bloc/customer/customer_event.dart';
import '../../bloc/customer/customer_state.dart';
import '../../bloc/flower/flower_bloc.dart';
import '../../bloc/flower/flower_event.dart';
import '../../bloc/flower/flower_state.dart';

class CustomerListView extends StatefulWidget {
  const CustomerListView({super.key});

  @override
  State<CustomerListView> createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<CustomerListView> {
  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomers());
    context.read<FlowerBloc>().add(LoadFlowers());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocConsumer<CustomerBloc, CustomerState>(
            listener: (context, state) {
              if (state is CustomerError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
              if (state is CustomerOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is CustomerLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryEmerald),
                );
              }

              if (state is CustomerLoaded) {
                if (state.customers.isEmpty) {
                  return Center(
                    child: Text('No customers added yet',
                        style: AppTypography.bodyLarge),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                  itemCount: state.customers.length,
                  itemBuilder: (context, index) {
                    final customer = state.customers[index];
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
                              color: AppColors.infoBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.infoBlue,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(customer.name,
                                    style: AppTypography.titleMedium),
                                if (customer.phone != null) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(customer.phone!,
                                      style: AppTypography.bodySmall),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _showEditDialog(context, customer);
                            },
                            icon: const Icon(Icons.edit_rounded),
                            color: AppColors.primaryEmerald,
                          ),
                          IconButton(
                            onPressed: () {
                              _showDeleteDialog(
                                  context, customer.id, customer.name);
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
            label: Text('Add Customer', style: AppTypography.labelLarge),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final commissionController = TextEditingController();
    List<String> selectedFlowerIds = [];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: Text('Add Customer', style: AppTypography.headlineSmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: phoneController,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Phone (optional)',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: addressController,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Address (optional)',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: commissionController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Default Commission % (Optional)',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Associated Flowers',
                    style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                const SizedBox(height: AppSpacing.sm),
                BlocBuilder<FlowerBloc, FlowerState>(
                  builder: (context, state) {
                    if (state is FlowerLoaded) {
                      if (state.flowers.isEmpty) {
                        return Text(
                          'No flowers available. Add flowers first.',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textTertiary),
                        );
                      }
                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: state.flowers.map((flower) {
                          final isSelected =
                              selectedFlowerIds.contains(flower.id);
                          return FilterChip(
                            label: Text(flower.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedFlowerIds.add(flower.id);
                                } else {
                                  selectedFlowerIds.remove(flower.id);
                                }
                              });
                            },
                            backgroundColor:
                                AppColors.surfaceDark.withOpacity(0.5),
                            selectedColor:
                                AppColors.primaryEmerald.withOpacity(0.2),
                            checkmarkColor: AppColors.primaryEmerald,
                            labelStyle: AppTypography.bodySmall.copyWith(
                              color: isSelected
                                  ? AppColors.primaryEmerald
                                  : AppColors.textSecondary,
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: AppTypography.labelLarge),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<CustomerBloc>().add(AddCustomerEvent(
                        name: nameController.text,
                        phone: phoneController.text.isEmpty
                            ? null
                            : phoneController.text,
                        address: addressController.text.isEmpty
                            ? null
                            : addressController.text,
                        defaultCommission:
                            double.tryParse(commissionController.text),
                        flowerIds: selectedFlowerIds,
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
      ),
    );
  }

  void _showEditDialog(BuildContext context, dynamic customer) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final addressController = TextEditingController(text: customer.address);
    final commissionController = TextEditingController(
        text: customer.defaultCommission?.toString() ?? '');
    List<String> selectedFlowerIds = List.from(customer.flowerIds);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: Text('Edit Customer', style: AppTypography.headlineSmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: phoneController,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Phone (optional)',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: addressController,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Address (optional)',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: commissionController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Default Commission % (Optional)',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Associated Flowers',
                    style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                const SizedBox(height: AppSpacing.sm),
                BlocBuilder<FlowerBloc, FlowerState>(
                  builder: (context, state) {
                    if (state is FlowerLoaded) {
                      if (state.flowers.isEmpty) {
                        return Text(
                          'No flowers available. Add flowers first.',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textTertiary),
                        );
                      }
                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: state.flowers.map((flower) {
                          final isSelected =
                              selectedFlowerIds.contains(flower.id);
                          return FilterChip(
                            label: Text(flower.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedFlowerIds.add(flower.id);
                                } else {
                                  selectedFlowerIds.remove(flower.id);
                                }
                              });
                            },
                            backgroundColor:
                                AppColors.surfaceDark.withOpacity(0.5),
                            selectedColor:
                                AppColors.primaryEmerald.withOpacity(0.2),
                            checkmarkColor: AppColors.primaryEmerald,
                            labelStyle: AppTypography.bodySmall.copyWith(
                              color: isSelected
                                  ? AppColors.primaryEmerald
                                  : AppColors.textSecondary,
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: AppTypography.labelLarge),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<CustomerBloc>().add(UpdateCustomerEvent(
                        id: customer.id,
                        name: nameController.text,
                        phone: phoneController.text.isEmpty
                            ? null
                            : phoneController.text,
                        address: addressController.text.isEmpty
                            ? null
                            : addressController.text,
                        defaultCommission:
                            double.tryParse(commissionController.text),
                        flowerIds: selectedFlowerIds,
                      ));
                  Navigator.pop(dialogContext);
                }
              },
              child: Text('Save',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primaryEmerald,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Delete Customer', style: AppTypography.headlineSmall),
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
              context.read<CustomerBloc>().add(DeleteCustomerEvent(id));
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
