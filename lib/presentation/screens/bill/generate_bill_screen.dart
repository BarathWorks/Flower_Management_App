import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/usecases/customer/get_customers_without_bills.dart';
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
  final GetCustomersWithoutBills _getCustomersWithoutBills = sl();
  
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  List<Customer> _unbilledCustomers = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUnbilledCustomers();
  }

  Future<void> _loadUnbilledCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _getCustomersWithoutBills(
      GetCustomersWithoutBillsParams(
        year: _selectedYear,
        month: _selectedMonth,
      ),
    );

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
          _unbilledCustomers = [];
        });
      },
      (customers) {
        setState(() {
          _isLoading = false;
          _unbilledCustomers = customers;
        });
      },
    );
  }

  void _generateBill(String customerId, String customerName) {
    context.read<BillBloc>().add(
      GenerateBillEvent(
        customerId: customerId,
        year: _selectedYear,
        month: _selectedMonth,
      ),
    );

    // Show confirmation message after generation is triggered
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating bill for $customerName...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Manual Bill'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Month and Year Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      final monthNames = [
                        'January', 'February', 'March', 'April', 'May', 'June',
                        'July', 'August', 'September', 'October', 'November', 'December'
                      ];
                      return DropdownMenuItem(
                        value: month,
                        child: Text(monthNames[index]),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMonth = value;
                        });
                        _loadUnbilledCustomers();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - 2 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedYear = value;
                        });
                        _loadUnbilledCustomers();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Customer List
          Expanded(
            child: BlocListener<BillBloc, BillState>(
              listener: (context, state) {
                if (state is BillOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload unbilled customers after successful generation
                  _loadUnbilledCustomers();
                } else if (state is BillError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: _buildCustomerList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUnbilledCustomers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_unbilledCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
            const SizedBox(height: 16),
            const Text(
              'All customers have bills for this period',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _unbilledCustomers.length,
      itemBuilder: (context, index) {
        final customer = _unbilledCustomers[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                customer.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              customer.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (customer.phone != null) ...[
                  const SizedBox(height: 4),
                  Text('Phone: ${customer.phone}'),
                ],
                if (customer.address != null) ...[
                  const SizedBox(height: 2),
                  Text('Address: ${customer.address}'),
                ],
              ],
            ),
            trailing: ElevatedButton.icon(
              onPressed: () => _generateBill(customer.id, customer.name),
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('Generate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
