import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/usecases/customer/get_all_customers.dart';
import '../../../injection_container.dart';
import '../../bloc/bill/bill_bloc.dart';
import '../../bloc/bill/bill_event.dart';
import '../../bloc/bill/bill_state.dart';

class GenerateBillScreen extends StatefulWidget {
  const GenerateBillScreen({super.key});

  @override
  State<GenerateBillScreen> createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends State<GenerateBillScreen> {
  final GetAllCustomers _getAllCustomers = sl();

  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  bool _isLoadingCustomers = true;
  String? _customerError;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _updateDateControllers();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _updateDateControllers() {
    _startDateController.text = DateFormat('dd/MM/yyyy').format(_startDate);
    _endDateController.text = DateFormat('dd/MM/yyyy').format(_endDate);
  }

  Future<void> _loadCustomers() async {
    final result = await _getAllCustomers(const NoParams());
    result.fold(
      (failure) {
        setState(() {
          _isLoadingCustomers = false;
          _customerError = failure.message;
        });
      },
      (customers) {
        setState(() {
          _isLoadingCustomers = false;
          _customers = customers;
        });
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is not before start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          // Ensure start date is not after end date
          if (_startDate.isAfter(_endDate)) {
            _startDate = _endDate;
          }
        }
        _updateDateControllers();
      });
    }
  }

  void _onCustomerSelected(Customer? customer) {
    setState(() {
      _selectedCustomer = customer;
    });

    if (customer != null) {
      context.read<BillBloc>().add(LoadLastBillDate(customer.id));
    }
  }

  void _generateBill() {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }

    context.read<BillBloc>().add(
          GenerateBillEvent(
            customerId: _selectedCustomer!.id,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Bill'),
        backgroundColor: Colors.green,
      ),
      body: BlocListener<BillBloc, BillState>(
        listener: (context, state) {
          if (state is BillOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Optionally reset or navigate away
          } else if (state is BillError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is LastBillDateLoaded) {
            setState(() {
              if (state.date != null) {
                // Smart Start Date: Day after last bill
                _startDate = state.date!.add(const Duration(days: 1));
              } else {
                // Default logic if no previous bills:
                // Suggest first day of current month as default for new customers
                final now = DateTime.now();
                _startDate = DateTime(now.year, now.month, 1);
              }
              // Ensure end date is sane
              if (_endDate.isBefore(_startDate)) {
                _endDate = DateTime.now();
              }
              _updateDateControllers();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Start date updated based on history')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Selector
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Customer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_isLoadingCustomers)
                        const Center(child: CircularProgressIndicator())
                      else if (_customerError != null)
                        Text('Error: $_customerError',
                            style: const TextStyle(color: Colors.red))
                      else
                        DropdownButtonFormField<Customer>(
                          value: _selectedCustomer,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                            hintText: 'Choose a customer',
                          ),
                          items: _customers.map((customer) {
                            return DropdownMenuItem(
                              value: customer,
                              child: Text(customer.name),
                            );
                          }).toList(),
                          onChanged: _onCustomerSelected,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date Range Selector
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Billing Period',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _startDateController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              onTap: () => _selectDate(context, true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _endDateController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event),
                              ),
                              onTap: () => _selectDate(context, false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Generate Button
              BlocBuilder<BillBloc, BillState>(
                builder: (context, state) {
                  if (state is BillLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton.icon(
                    onPressed: _generateBill,
                    icon: const Icon(Icons.receipt_long, size: 24),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'GENERATE BILL',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
