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
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_scaffold.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<FlowerBloc>().add(LoadFlowers());
    context.read<CustomerBloc>().add(LoadCustomers());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _rateController.dispose();
    _commissionController.dispose();
    super.dispose();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Flower',
                  style: AppTypography.labelLarge,
                ),
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
                Text(
                  'Select Customer',
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                BlocBuilder<CustomerBloc, CustomerState>(
                  builder: (context, state) {
                    if (state is CustomerLoaded) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(AppRadius.md),
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
                CustomTextField(
                  label: 'Quantity',
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Rate',
                  controller: _rateController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter rate';
                    }
                    return null;
                  },
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
                const SizedBox(height: AppSpacing.lg),
                CustomButton(
                  text: 'Add Transaction',
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedFlowerId != null &&
                        _selectedCustomerId != null) {
                      context.read<TransactionBloc>().add(
                            AddTransactionEvent(
                              flowerId: _selectedFlowerId!,
                              customerId: _selectedCustomerId!,
                              entryDate: _selectedDate,
                              quantity: double.parse(_quantityController.text),
                              rate: double.parse(_rateController.text),
                              commission:
                                  double.parse(_commissionController.text),
                            ),
                          );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
