import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/typography.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/usecases/transaction/add_transaction.dart';
import '../../bloc/customer/customer_bloc.dart';
import '../../bloc/customer/customer_event.dart';
import '../../bloc/customer/customer_state.dart';
import '../../bloc/flower/flower_bloc.dart';
import '../../bloc/flower/flower_event.dart';
import '../../bloc/flower/flower_state.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_scaffold.dart';

class CustomerTransactionEntry {
  final String customerId;
  final String customerName;
  final double quantity;
  final double rate;
  final double commission;

  CustomerTransactionEntry({
    required this.customerId,
    required this.customerName,
    required this.quantity,
    required this.rate,
    required this.commission,
  });

  double get amount => quantity * rate;
  double get netAmount => amount - commission;
}

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  final _commissionController = TextEditingController();

  String? _selectedFlowerId;
  String? _selectedCustomerId;
  DateTime _selectedDate = DateTime.now();

  final List<CustomerTransactionEntry> _customerEntries = [];
  List<Customer> _availableCustomers = [];

  @override
  void initState() {
    super.initState();
    context.read<FlowerBloc>().add(LoadFlowers());
    context.read<CustomerBloc>().add(LoadCustomers());
    context.read<SettingsBloc>().add(LoadSettings());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _rateController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  void _addCustomerEntry() {
    if (_formKey.currentState!.validate() && _selectedCustomerId != null) {
      final customer = _availableCustomers.firstWhere(
        (c) => c.id == _selectedCustomerId,
      );

      setState(() {
        _customerEntries.add(CustomerTransactionEntry(
          customerId: customer.id,
          customerName: customer.name,
          quantity: double.parse(_quantityController.text),
          rate: double.parse(_rateController.text),
          commission: double.parse(_commissionController.text),
        ));

        // Clear form
        _selectedCustomerId = null;
        _quantityController.clear();
        _rateController.clear();
        _commissionController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all customer fields'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeCustomerEntry(int index) {
    setState(() {
      _customerEntries.removeAt(index);
    });
  }

  void _submitAllTransactions() {
    if (_selectedFlowerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a flower'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_customerEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one customer'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final customers = _customerEntries
        .map((entry) => CustomerTransactionData(
              customerId: entry.customerId,
              quantity: entry.quantity,
              rate: entry.rate,
              commission: entry.commission,
            ))
        .toList();

    context.read<TransactionBloc>().add(
          AddMultipleCustomerTransactionEvent(
            flowerId: _selectedFlowerId!,
            entryDate: _selectedDate,
            customers: customers,
          ),
        );

    Navigator.pop(context);
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
        title: Text('Add Transaction', style: AppTypography.headlineSmall),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flower Selection
                    Text('Select Flower', style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.sm),
                    BlocBuilder<FlowerBloc, FlowerState>(
                      builder: (context, state) {
                        if (state is FlowerLoaded) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedFlowerId,
                                isExpanded: true,
                                hint: Text('Select flower',
                                    style: AppTypography.bodyMedium),
                                dropdownColor: AppColors.surfaceDark,
                                style: AppTypography.bodyMedium,
                                items: state.flowers.map((flower) {
                                  return DropdownMenuItem(
                                    value: flower.id,
                                    child: Text(flower.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedFlowerId = value;
                                    final selectedFlower = state.flowers
                                        .firstWhere((f) => f.id == value);
                                    if (selectedFlower.defaultRate != null) {
                                      _rateController.text =
                                          selectedFlower.defaultRate.toString();
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    Divider(color: AppColors.textTertiary),
                    const SizedBox(height: AppSpacing.lg),

                    // Add Customer Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Customers', style: AppTypography.titleMedium),
                        Text('${_customerEntries.length} added',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primaryEmerald,
                            )),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Customer',
                              style: AppTypography.labelLarge),
                          const SizedBox(height: AppSpacing.sm),
                          BlocBuilder<CustomerBloc, CustomerState>(
                            builder: (context, state) {
                              if (state is CustomerLoaded) {
                                _availableCustomers = state.customers;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceDark,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCustomerId,
                                      isExpanded: true,
                                      hint: Text('Select customer',
                                          style: AppTypography.bodyMedium),
                                      dropdownColor: AppColors.surfaceDark,
                                      style: AppTypography.bodyMedium,
                                      items: state.customers.map((customer) {
                                        return DropdownMenuItem(
                                          value: customer.id,
                                          child: Text(customer.name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCustomerId = value;
                                          final selectedCustomer = state
                                              .customers
                                              .firstWhere((c) => c.id == value);

                                          if (selectedCustomer
                                                  .defaultCommission !=
                                              null) {
                                            _commissionController.text =
                                                selectedCustomer
                                                    .defaultCommission
                                                    .toString();
                                          } else {
                                            final settingsState = context
                                                .read<SettingsBloc>()
                                                .state;
                                            if (settingsState
                                                    is SettingsLoaded &&
                                                settingsState
                                                        .globalCommission !=
                                                    null) {
                                              _commissionController.text =
                                                  settingsState.globalCommission
                                                      .toString();
                                            } else {
                                              _commissionController.text = '0';
                                            }
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }
                              return const CircularProgressIndicator();
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  label: 'Quantity',
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: CustomTextField(
                                  label: 'Rate',
                                  controller: _rateController,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          CustomTextField(
                            label: 'Commission',
                            controller: _commissionController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter commission';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _addCustomerEntry,
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Add Customer to List'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surfaceDark,
                                foregroundColor: AppColors.primaryEmerald,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  side: const BorderSide(
                                    color: AppColors.primaryEmerald,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Customer List
                    if (_customerEntries.isNotEmpty) ...[
                      Text('Customer List', style: AppTypography.titleMedium),
                      const SizedBox(height: AppSpacing.md),
                      ..._customerEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final customer = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: AppColors.primaryEmerald.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.customerName,
                                      style: AppTypography.titleMedium.copyWith(
                                        color: AppColors.primaryEmerald,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Qty: ${customer.quantity} × ₹${customer.rate} = ₹${customer.amount.toStringAsFixed(2)}',
                                      style: AppTypography.bodySmall,
                                    ),
                                    Text(
                                      'Commission: ₹${customer.commission.toStringAsFixed(2)} | Net: ₹${customer.netAmount.toStringAsFixed(2)}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeCustomerEntry(index),
                                icon: const Icon(Icons.delete_outline),
                                color: AppColors.error,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: CustomButton(
                text: _customerEntries.isEmpty
                    ? 'Add Customers First'
                    : 'Submit ${_customerEntries.length} Transaction(s)',
                onPressed:
                    _customerEntries.isEmpty ? () {} : _submitAllTransactions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
