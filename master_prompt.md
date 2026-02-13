 MASTER PROMPT: Flutter + Neon PostgreSQL Flower Market App with Clean Architecture (BLoC)
📋 PROJECT OVERVIEW
Build a modern, production-ready Flutter mobile application for managing a flower market business using Clean Architecture with BLoC pattern and direct Neon PostgreSQL cloud database integration.
Core Business Logic

Daily flower transaction management (Flower + Customer + Quantity + Rate)
Automated monthly billing with flower-wise breakup
Customer and inventory management
Real-time dashboard analytics
Payment tracking


🏗️ ARCHITECTURE BLUEPRINT
Clean Architecture Layers
📦 lib/
├── 🎯 main.dart
├── 💉 injection_container.dart
│
├── 🔷 core/
│   ├── error/
│   │   ├── failures.dart          # Abstract Failure classes
│   │   └── exceptions.dart        # DatabaseException, ServerException
│   ├── usecases/
│   │   └── usecase.dart           # Abstract UseCase<Type, Params>
│   └── utils/
│       ├── constants.dart
│       └── formatters.dart
│
├── 📊 data/
│   ├── datasources/
│   │   ├── neon_database.dart                    # Singleton Neon connection
│   │   ├── customer_remote_datasource.dart
│   │   ├── flower_remote_datasource.dart
│   │   ├── transaction_remote_datasource.dart
│   │   ├── bill_remote_datasource.dart
│   │   └── dashboard_remote_datasource.dart
│   ├── models/
│   │   ├── customer_model.dart                   # Extends Customer entity
│   │   ├── flower_model.dart
│   │   ├── transaction_model.dart
│   │   ├── bill_model.dart
│   │   └── dashboard_model.dart
│   └── repositories/
│       ├── customer_repository_impl.dart         # Implements domain repository
│       ├── flower_repository_impl.dart
│       ├── transaction_repository_impl.dart
│       ├── bill_repository_impl.dart
│       └── dashboard_repository_impl.dart
│
├── 🎭 domain/
│   ├── entities/
│   │   ├── customer.dart                         # Pure business objects
│   │   ├── flower.dart
│   │   ├── transaction.dart
│   │   ├── bill.dart
│   │   └── dashboard_summary.dart
│   ├── repositories/
│   │   ├── customer_repository.dart              # Abstract contracts
│   │   ├── flower_repository.dart
│   │   ├── transaction_repository.dart
│   │   ├── bill_repository.dart
│   │   └── dashboard_repository.dart
│   └── usecases/
│       ├── customer/
│       │   ├── get_all_customers.dart
│       │   ├── add_customer.dart
│       │   ├── update_customer.dart
│       │   └── delete_customer.dart
│       ├── flower/
│       │   ├── get_all_flowers.dart
│       │   ├── add_flower.dart
│       │   └── delete_flower.dart
│       ├── transaction/
│       │   ├── get_today_transactions.dart
│       │   ├── get_transactions_by_date.dart
│       │   ├── add_transaction.dart
│       │   └── delete_transaction.dart
│       ├── bill/
│       │   ├── generate_monthly_bill.dart
│       │   ├── get_bill_details.dart
│       │   ├── get_all_bills.dart
│       │   └── get_customer_bills.dart
│       └── dashboard/
│           └── get_dashboard_summary.dart
│
└── 🎨 presentation/
    ├── bloc/
    │   ├── customer/
    │   │   ├── customer_bloc.dart
    │   │   ├── customer_event.dart
    │   │   └── customer_state.dart
    │   ├── flower/
    │   │   ├── flower_bloc.dart
    │   │   ├── flower_event.dart
    │   │   └── flower_state.dart
    │   ├── transaction/
    │   │   ├── transaction_bloc.dart
    │   │   ├── transaction_event.dart
    │   │   └── transaction_state.dart
    │   ├── bill/
    │   │   ├── bill_bloc.dart
    │   │   ├── bill_event.dart
    │   │   └── bill_state.dart
    │   └── dashboard/
    │       ├── dashboard_bloc.dart
    │       ├── dashboard_event.dart
    │       └── dashboard_state.dart
    ├── screens/
    │   ├── shell_screen.dart                     # Main navigation shell
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart
    │   ├── manage/
    │   │   ├── manage_screen.dart               # TabBar: Flowers & Customers
    │   │   ├── flower_list_view.dart
    │   │   ├── customer_list_view.dart
    │   │   ├── add_flower_screen.dart
    │   │   └── add_customer_screen.dart
    │   ├── transaction/
    │   │   ├── transaction_screen.dart
    │   │   └── add_transaction_screen.dart
    │   ├── bill/
    │   │   ├── bill_screen.dart
    │   │   ├── bill_detail_screen.dart
    │   │   └── generate_bill_screen.dart
    │   └── settings/
    │       └── settings_screen.dart
    └── widgets/
        ├── modern_nav_bar.dart
        ├── summary_card.dart
        ├── transaction_card.dart
        ├── bill_card.dart
        ├── loading_widget.dart
        └── error_widget.dart

🗄️ NEON POSTGRESQL DATABASE SCHEMA
Tables & Relationships
sql-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--------------------------------------------------
-- 1. CUSTOMERS
--------------------------------------------------
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------
-- 2. FLOWERS
--------------------------------------------------
CREATE TABLE flowers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------
-- 3. DAILY FLOWER ENTRY (Header: Date + Flower)
--------------------------------------------------
CREATE TABLE daily_flower_entry (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entry_date DATE NOT NULL,
    flower_id UUID NOT NULL,
    
    total_quantity DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) DEFAULT 0,
    total_commission DECIMAL(10,2) DEFAULT 0,
    net_amount DECIMAL(10,2) DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(entry_date, flower_id),
    FOREIGN KEY (flower_id) REFERENCES flowers(id) ON DELETE RESTRICT
);

--------------------------------------------------
-- 4. DAILY FLOWER CUSTOMER (Transaction Details)
--------------------------------------------------
CREATE TABLE daily_flower_customer (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    daily_entry_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    
    quantity DECIMAL(10,2) NOT NULL CHECK (quantity > 0),
    rate DECIMAL(10,2) NOT NULL CHECK (rate >= 0),
    amount DECIMAL(10,2) NOT NULL,
    commission DECIMAL(10,2) DEFAULT 0,
    net_amount DECIMAL(10,2) NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (daily_entry_id) REFERENCES daily_flower_entry(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT
);

--------------------------------------------------
-- 5. MONTHLY BILLS
--------------------------------------------------
CREATE TABLE bills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bill_number TEXT UNIQUE NOT NULL,
    customer_id UUID NOT NULL,
    
    bill_year INTEGER NOT NULL,
    bill_month INTEGER NOT NULL CHECK (bill_month BETWEEN 1 AND 12),
    
    total_quantity DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) DEFAULT 0,
    total_commission DECIMAL(10,2) DEFAULT 0,
    total_expense DECIMAL(10,2) DEFAULT 0,
    net_amount DECIMAL(10,2) DEFAULT 0,
    
    status TEXT DEFAULT 'UNPAID' CHECK (status IN ('UNPAID', 'PARTIAL', 'PAID')),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(customer_id, bill_year, bill_month),
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT
);

--------------------------------------------------
-- 6. BILL ITEMS (Flower-wise Breakup)
--------------------------------------------------
CREATE TABLE bill_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bill_id UUID NOT NULL,
    flower_id UUID NOT NULL,
    
    total_quantity DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    total_commission DECIMAL(10,2),
    net_amount DECIMAL(10,2),
    
    FOREIGN KEY (bill_id) REFERENCES bills(id) ON DELETE CASCADE,
    FOREIGN KEY (flower_id) REFERENCES flowers(id) ON DELETE RESTRICT
);

--------------------------------------------------
-- 7. PAYMENTS
--------------------------------------------------
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bill_id UUID NOT NULL,
    
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_mode TEXT CHECK (payment_mode IN ('CASH', 'UPI', 'BANK', 'CHEQUE')),
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bill_id) REFERENCES bills(id) ON DELETE CASCADE
);

--------------------------------------------------
-- 8. EXPENSES
--------------------------------------------------
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    expense_date DATE NOT NULL,
    description TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    category TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------
-- 9. PERFORMANCE INDEXES
--------------------------------------------------
CREATE INDEX idx_daily_entry_date ON daily_flower_entry(entry_date);
CREATE INDEX idx_daily_entry_flower ON daily_flower_entry(flower_id);
CREATE INDEX idx_daily_customer_entry ON daily_flower_customer(daily_entry_id);
CREATE INDEX idx_daily_customer_customer ON daily_flower_customer(customer_id);
CREATE INDEX idx_bills_customer ON bills(customer_id);
CREATE INDEX idx_bills_status ON bills(status);
CREATE INDEX idx_bills_period ON bills(bill_year, bill_month);
CREATE INDEX idx_payments_bill ON payments(bill_id);
CREATE INDEX idx_expenses_date ON expenses(expense_date);

--------------------------------------------------
-- 10. DASHBOARD VIEW (Server-Side Aggregation)
--------------------------------------------------
CREATE VIEW dashboard_summary AS
SELECT 
    -- Weekly Sales
    (SELECT COALESCE(SUM(total_amount), 0) 
     FROM daily_flower_entry 
     WHERE entry_date > CURRENT_DATE - INTERVAL '7 days') as weekly_sales,
    
    -- Current Month Profit
    (SELECT COALESCE(SUM(net_amount), 0) 
     FROM bills 
     WHERE bill_month = EXTRACT(MONTH FROM CURRENT_DATE)
     AND bill_year = EXTRACT(YEAR FROM CURRENT_DATE)) as monthly_profit,
    
    -- Total Active Customers
    (SELECT COUNT(*) FROM customers) as total_customers,
    
    -- Total Flower Types
    (SELECT COUNT(*) FROM flowers) as total_flowers,
    
    -- Pending Payments
    (SELECT COALESCE(SUM(net_amount), 0) 
     FROM bills 
     WHERE status != 'PAID') as pending_payments,
    
    -- Today's Transaction Count
    (SELECT COUNT(*) 
     FROM daily_flower_customer dfc
     JOIN daily_flower_entry dfe ON dfc.daily_entry_id = dfe.id
     WHERE dfe.entry_date = CURRENT_DATE) as today_transactions;

--------------------------------------------------
-- 11. AUTO-UPDATE TRIGGER for daily_flower_entry
--------------------------------------------------
CREATE OR REPLACE FUNCTION update_daily_entry_totals()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE daily_flower_entry
    SET 
        total_quantity = (
            SELECT COALESCE(SUM(quantity), 0) 
            FROM daily_flower_customer 
            WHERE daily_entry_id = COALESCE(NEW.daily_entry_id, OLD.daily_entry_id)
        ),
        total_amount = (
            SELECT COALESCE(SUM(amount), 0) 
            FROM daily_flower_customer 
            WHERE daily_entry_id = COALESCE(NEW.daily_entry_id, OLD.daily_entry_id)
        ),
        total_commission = (
            SELECT COALESCE(SUM(commission), 0) 
            FROM daily_flower_customer 
            WHERE daily_entry_id = COALESCE(NEW.daily_entry_id, OLD.daily_entry_id)
        ),
        net_amount = (
            SELECT COALESCE(SUM(net_amount), 0) 
            FROM daily_flower_customer 
            WHERE daily_entry_id = COALESCE(NEW.daily_entry_id, OLD.daily_entry_id)
        )
    WHERE id = COALESCE(NEW.daily_entry_id, OLD.daily_entry_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_daily_entry_after_insert
AFTER INSERT ON daily_flower_customer
FOR EACH ROW EXECUTE FUNCTION update_daily_entry_totals();

CREATE TRIGGER trigger_update_daily_entry_after_update
AFTER UPDATE ON daily_flower_customer
FOR EACH ROW EXECUTE FUNCTION update_daily_entry_totals();

CREATE TRIGGER trigger_update_daily_entry_after_delete
AFTER DELETE ON daily_flower_customer
FOR EACH ROW EXECUTE FUNCTION update_daily_entry_totals();

--------------------------------------------------
-- 12. STORED PROCEDURE: Generate Monthly Bill
--------------------------------------------------
CREATE SEQUENCE bill_number_seq START 1000;

CREATE OR REPLACE FUNCTION generate_monthly_bill(
    p_customer_id UUID,
    p_year INTEGER,
    p_month INTEGER
) RETURNS UUID AS $$
DECLARE
    v_bill_id UUID;
    v_bill_number TEXT;
    v_total_qty DECIMAL(10,2);
    v_total_amt DECIMAL(10,2);
    v_total_comm DECIMAL(10,2);
    v_net_amt DECIMAL(10,2);
BEGIN
    -- Check if bill already exists
    SELECT id INTO v_bill_id
    FROM bills
    WHERE customer_id = p_customer_id
      AND bill_year = p_year
      AND bill_month = p_month;
    
    IF v_bill_id IS NOT NULL THEN
        RAISE EXCEPTION 'Bill already exists for this customer and period';
    END IF;
    
    -- Calculate totals
    SELECT 
        COALESCE(SUM(dfc.quantity), 0),
        COALESCE(SUM(dfc.amount), 0),
        COALESCE(SUM(dfc.commission), 0),
        COALESCE(SUM(dfc.net_amount), 0)
    INTO v_total_qty, v_total_amt, v_total_comm, v_net_amt
    FROM daily_flower_customer dfc
    JOIN daily_flower_entry dfe ON dfc.daily_entry_id = dfe.id
    WHERE dfc.customer_id = p_customer_id
      AND EXTRACT(YEAR FROM dfe.entry_date) = p_year
      AND EXTRACT(MONTH FROM dfe.entry_date) = p_month;
    
    -- Generate bill number
    v_bill_number := 'BILL-' || p_year || '-' || 
                     LPAD(p_month::TEXT, 2, '0') || '-' || 
                     LPAD(NEXTVAL('bill_number_seq')::TEXT, 4, '0');
    
    -- Insert bill header
    INSERT INTO bills (
        bill_number, customer_id, bill_year, bill_month,
        total_quantity, total_amount, total_commission, net_amount
    ) VALUES (
        v_bill_number, p_customer_id, p_year, p_month,
        v_total_qty, v_total_amt, v_total_comm, v_net_amt
    ) RETURNING id INTO v_bill_id;
    
    -- Insert bill items (flower-wise breakup)
    INSERT INTO bill_items (bill_id, flower_id, total_quantity, total_amount, total_commission, net_amount)
    SELECT 
        v_bill_id,
        dfe.flower_id,
        SUM(dfc.quantity),
        SUM(dfc.amount),
        SUM(dfc.commission),
        SUM(dfc.net_amount)
    FROM daily_flower_customer dfc
    JOIN daily_flower_entry dfe ON dfc.daily_entry_id = dfe.id
    WHERE dfc.customer_id = p_customer_id
      AND EXTRACT(YEAR FROM dfe.entry_date) = p_year
      AND EXTRACT(MONTH FROM dfe.entry_date) = p_month
    GROUP BY dfe.flower_id;
    
    RETURN v_bill_id;
END;
$$ LANGUAGE plpgsql;

--------------------------------------------------
-- 13. UPDATE BILL STATUS TRIGGER (Based on Payments)
--------------------------------------------------
CREATE OR REPLACE FUNCTION update_bill_payment_status()
RETURNS TRIGGER AS $$
DECLARE
    v_total_paid DECIMAL(10,2);
    v_bill_amount DECIMAL(10,2);
    v_new_status TEXT;
BEGIN
    -- Get total paid amount
    SELECT COALESCE(SUM(amount), 0) INTO v_total_paid
    FROM payments
    WHERE bill_id = COALESCE(NEW.bill_id, OLD.bill_id);
    
    -- Get bill amount
    SELECT net_amount INTO v_bill_amount
    FROM bills
    WHERE id = COALESCE(NEW.bill_id, OLD.bill_id);
    
    -- Determine status
    IF v_total_paid = 0 THEN
        v_new_status := 'UNPAID';
    ELSIF v_total_paid >= v_bill_amount THEN
        v_new_status := 'PAID';
    ELSE
        v_new_status := 'PARTIAL';
    END IF;
    
    -- Update bill status
    UPDATE bills
    SET status = v_new_status
    WHERE id = COALESCE(NEW.bill_id, OLD.bill_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_bill_status_after_payment
AFTER INSERT OR UPDATE OR DELETE ON payments
FOR EACH ROW EXECUTE FUNCTION update_bill_payment_status();

📱 UI/UX DESIGN SPECIFICATIONS
Modern Glassmorphism Design System
Color Palette
dart// Primary Colors
const primaryEmerald = Color(0xFF50C878);    // Emerald green
const backgroundDark = Color(0xFF121212);     // Deep black
const surfaceDark = Color(0xFF1E1E1E);        // Card background
const accentOrange = Color(0xFFFF8C42);       // Warning/alerts

// Text Colors
const textPrimary = Color(0xFFFFFFFF);        // White
const textSecondary = Color(0xFFB0B0B0);      // Light gray
const textTertiary = Color(0xFF707070);       // Dark gray

// Functional Colors
const successGreen = Color(0xFF4CAF50);
const errorRed = Color(0xFFF44336);
const warningAmber = Color(0xFFFFC107);
const infoBlue = Color(0xFF2196F3);
Typography
dart// Use Google Fonts - Poppins or Inter
final headingStyle = GoogleFonts.poppins(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: textPrimary,
);

final bodyStyle = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: textSecondary,
);

final captionStyle = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: textTertiary,
);
Navigation Bar Specifications
dartContainer(
  margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: BottomNavigationBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        selectedItemColor: primaryEmerald,
        unselectedItemColor: Colors.white38,
        // ... items
      ),
    ),
  ),
)
Card Design
dartContainer(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: surfaceDark,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: primaryEmerald.withOpacity(0.2),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryEmerald.withOpacity(0.1),
        blurRadius: 15,
        offset: Offset(0, 5),
      ),
    ],
  ),
)

🔌 CLEAN ARCHITECTURE IMPLEMENTATION PATTERNS
1. Entity (Domain Layer)
dart// domain/entities/transaction.dart
import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String flowerName;
  final String customerName;
  final double quantity;
  final double rate;
  final double amount;
  final double commission;
  final double netAmount;
  final DateTime createdAt;
  
  const Transaction({
    required this.id,
    required this.flowerName,
    required this.customerName,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.commission,
    required this.netAmount,
    required this.createdAt,
  });
  
  @override
  List<Object?> get props => [
    id, flowerName, customerName, quantity, 
    rate, amount, commission, netAmount, createdAt
  ];
}
2. Repository Contract (Domain Layer)
dart// domain/repositories/transaction_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTodayTransactions();
  
  Future<Either<Failure, void>> addTransaction({
    required String flowerId,
    required String customerId,
    required double quantity,
    required double rate,
    required double commission,
  });
  
  Future<Either<Failure, void>> deleteTransaction(String transactionId);
  
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
}
3. Use Case (Domain Layer)
dart// domain/usecases/transaction/add_transaction.dart
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/transaction_repository.dart';

class AddTransactionParams {
  final String flowerId;
  final String customerId;
  final double quantity;
  final double rate;
  final double commission;
  
  AddTransactionParams({
    required this.flowerId,
    required this.customerId,
    required this.quantity,
    required this.rate,
    required this.commission,
  });
}

class AddTransaction implements UseCase<void, AddTransactionParams> {
  final TransactionRepository repository;
  
  AddTransaction(this.repository);
  
  @override
  Future<Either<Failure, void>> call(AddTransactionParams params) async {
    return await repository.addTransaction(
      flowerId: params.flowerId,
      customerId: params.customerId,
      quantity: params.quantity,
      rate: params.rate,
      commission: params.commission,
    );
  }
}
4. Model (Data Layer)
dart// data/models/transaction_model.dart
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.flowerName,
    required super.customerName,
    required super.quantity,
    required super.rate,
    required super.amount,
    required super.commission,
    required super.netAmount,
    required super.createdAt,
  });
  
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      flowerName: json['flower_name'],
      customerName: json['customer_name'],
      quantity: (json['quantity'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flower_name': flowerName,
      'customer_name': customerName,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
      'commission': commission,
      'net_amount': netAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
5. Data Source (Data Layer)
dart// data/datasources/transaction_remote_datasource.dart
import '../../core/error/exceptions.dart';
import '../models/transaction_model.dart';
import 'neon_database.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTodayTransactions();
  Future<void> addTransaction({
    required String flowerId,
    required String customerId,
    required double quantity,
    required double rate,
    required double commission,
  });
  Future<void> deleteTransaction(String transactionId);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final NeonDatabase database;
  
  TransactionRemoteDataSourceImpl({required this.database});
  
  @override
  Future<List<TransactionModel>> getTodayTransactions() async {
    try {
      final result = await database.execute('''
        SELECT 
          dfc.id,
          f.name as flower_name,
          c.name as customer_name,
          dfc.quantity,
          dfc.rate,
          dfc.amount,
          dfc.commission,
          dfc.net_amount,
          dfc.created_at
        FROM daily_flower_customer dfc
        JOIN daily_flower_entry dfe ON dfc.daily_entry_id = dfe.id
        JOIN flowers f ON dfe.flower_id = f.id
        JOIN customers c ON dfc.customer_id = c.id
        WHERE dfe.entry_date = CURRENT_DATE
        ORDER BY dfc.created_at DESC
      ''');
      
      return result.map((row) => TransactionModel.fromJson(row)).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch transactions: $e');
    }
  }
  
  @override
  Future<void> addTransaction({
    required String flowerId,
    required String customerId,
    required double quantity,
    required double rate,
    required double commission,
  }) async {
    final amount = quantity * rate;
    final netAmount = amount - commission;
    final entryDate = DateTime.now().toIso8601String().split('T')[0];
    
    try {
      await database.executeInTransaction((ctx) async {
        // Get or create daily_flower_entry
        final entryResult = await ctx.query('''
          INSERT INTO daily_flower_entry (entry_date, flower_id)
          VALUES (@date, @flowerId)
          ON CONFLICT (entry_date, flower_id) 
          DO UPDATE SET entry_date = EXCLUDED.entry_date
          RETURNING id
        ''', substitutionValues: {
          'date': entryDate,
          'flowerId': flowerId,
        });
        
        final dailyEntryId = entryResult.first[0];
        
        // Insert transaction
        await ctx.query('''
          INSERT INTO daily_flower_customer 
          (daily_entry_id, customer_id, quantity, rate, amount, commission, net_amount)
          VALUES (@entryId, @customerId, @qty, @rate, @amount, @comm, @net)
        ''', substitutionValues: {
          'entryId': dailyEntryId,
          'customerId': customerId,
          'qty': quantity,
          'rate': rate,
          'amount': amount,
          'comm': commission,
          'net': netAmount,
        });
      });
    } catch (e) {
      throw DatabaseException('Failed to add transaction: $e');
    }
  }
  
  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await database.execute(
        'DELETE FROM daily_flower_customer WHERE id = @id',
        substitutionValues: {'id': transactionId},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete transaction: $e');
    }
  }
}
6. Repository Implementation (Data Layer)
dart// data/repositories/transaction_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  
  TransactionRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, List<Transaction>>> getTodayTransactions() async {
    try {
      final transactions = await remoteDataSource.getTodayTransactions();
      return Right(transactions);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> addTransaction({
    required String flowerId,
    required String customerId,
    required double quantity,
    required double rate,
    required double commission,
  }) async {
    try {
      await remoteDataSource.addTransaction(
        flowerId: flowerId,
        customerId: customerId,
        quantity: quantity,
        rate: rate,
        commission: commission,
      );
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId) async {
    try {
      await remoteDataSource.deleteTransaction(transactionId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }
  
  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await remoteDataSource.getTransactionsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(transactions);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error: $e'));
    }
  }
}
7. BLoC Event (Presentation Layer)
dart// presentation/bloc/transaction/transaction_event.dart
import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  
  @override
  List<Object> get props => [];
}

class LoadTodayTransactions extends TransactionEvent {}

class LoadTransactionsByDateRange extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;
  
  const LoadTransactionsByDateRange({
    required this.startDate,
    required this.endDate,
  });
  
  @override
  List<Object> get props => [startDate, endDate];
}

class AddTransactionEvent extends TransactionEvent {
  final String flowerId;
  final String customerId;
  final double quantity;
  final double rate;
  final double commission;
  
  const AddTransactionEvent({
    required this.flowerId,
    required this.customerId,
    required this.quantity,
    required this.rate,
    required this.commission,
  });
  
  @override
  List<Object> get props => [flowerId, customerId, quantity, rate, commission];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;
  
  const DeleteTransactionEvent(this.transactionId);
  
  @override
  List<Object> get props => [transactionId];
}

class RefreshTransactions extends TransactionEvent {}
8. BLoC State (Presentation Layer)
dart// presentation/bloc/transaction/transaction_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  
  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  
  const TransactionLoaded(this.transactions);
  
  @override
  List<Object> get props => [transactions];
}

class TransactionError extends TransactionState {
  final String message;
  
  const TransactionError(this.message);
  
  @override
  List<Object> get props => [message];
}

class TransactionOperationSuccess extends TransactionState {
  final String message;
  
  const TransactionOperationSuccess(this.message);
  
  @override
  List<Object> get props => [message];
}
9. BLoC (Presentation Layer)
dart// presentation/bloc/transaction/transaction_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/transaction/add_transaction.dart';
import '../../../domain/usecases/transaction/delete_transaction.dart';
import '../../../domain/usecases/transaction/get_today_transactions.dart';
import '../../../domain/usecases/transaction/get_transactions_by_date_range.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTodayTransactions getTodayTransactions;
  final GetTransactionsByDateRange getTransactionsByDateRange;
  final AddTransaction addTransaction;
  final DeleteTransaction deleteTransaction;
  
  TransactionBloc({
    required this.getTodayTransactions,
    required this.getTransactionsByDateRange,
    required this.addTransaction,
    required this.deleteTransaction,
  }) : super(TransactionInitial()) {
    on<LoadTodayTransactions>(_onLoadTodayTransactions);
    on<LoadTransactionsByDateRange>(_onLoadTransactionsByDateRange);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<RefreshTransactions>(_onRefreshTransactions);
  }
  
  Future<void> _onLoadTodayTransactions(
    LoadTodayTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    
    final result = await getTodayTransactions(NoParams());
    
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }
  
  Future<void> _onLoadTransactionsByDateRange(
    LoadTransactionsByDateRange event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    
    final result = await getTransactionsByDateRange(
      GetTransactionsByDateRangeParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
    
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }
  
  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    
    final result = await addTransaction(
      AddTransactionParams(
        flowerId: event.flowerId,
        customerId: event.customerId,
        quantity: event.quantity,
        rate: event.rate,
        commission: event.commission,
      ),
    );
    
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(const TransactionOperationSuccess('Transaction added successfully'));
        add(LoadTodayTransactions()); // Auto-reload
      },
    );
  }
  
  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await deleteTransaction(
      DeleteTransactionParams(event.transactionId),
    );
    
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(const TransactionOperationSuccess('Transaction deleted successfully'));
        add(LoadTodayTransactions()); // Auto-reload
      },
    );
  }
  
  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTodayTransactions());
  }
}
10. Screen (Presentation Layer)
dart// presentation/screens/transaction/transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/transaction/transaction_state.dart';
import '../../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTodayTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Today's Transactions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Show date range picker
            },
          ),
        ],
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is TransactionOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF50C878),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF50C878),
              ),
            );
          }
          
          if (state is TransactionLoaded) {
            if (state.transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No transactions today',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              color: const Color(0xFF50C878),
              onRefresh: () async {
                context.read<TransactionBloc>().add(RefreshTransactions());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.transactions.length,
                itemBuilder: (context, index) {
                  return TransactionCard(
                    transaction: state.transactions[index],
                    onDelete: () {
                      _showDeleteConfirmation(
                        context,
                        state.transactions[index].id,
                      );
                    },
                  );
                },
              ),
            );
          }
          
          return const Center(
            child: Text(
              'Pull down to refresh',
              style: TextStyle(color: Colors.white54),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<TransactionBloc>(),
                child: const AddTransactionScreen(),
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF50C878),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TransactionBloc>().add(
                DeleteTransactionEvent(transactionId),
              );
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

🔧 DEPENDENCY INJECTION SETUP
dart// injection_container.dart
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Transaction
  // Bloc
  sl.registerFactory(
    () => TransactionBloc(
      getTodayTransactions: sl(),
      getTransactionsByDateRange: sl(),
      addTransaction: sl(),
      deleteTransaction: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTodayTransactions(sl()));
  sl.registerLazySingleton(() => GetTransactionsByDateRange(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(
      database: sl(),
    ),
  );

  //! Features - Customer
  // Bloc
  sl.registerFactory(
    () => CustomerBloc(
      getAllCustomers: sl(),
      addCustomer: sl(),
      updateCustomer: sl(),
      deleteCustomer: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllCustomers(sl()));
  sl.registerLazySingleton(() => AddCustomer(sl()));
  sl.registerLazySingleton(() => UpdateCustomer(sl()));
  sl.registerLazySingleton(() => DeleteCustomer(sl()));

  // Repository
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(
      database: sl(),
    ),
  );

  //! Features - Flower
  sl.registerFactory(
    () => FlowerBloc(
      getAllFlowers: sl(),
      addFlower: sl(),
      deleteFlower: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetAllFlowers(sl()));
  sl.registerLazySingleton(() => AddFlower(sl()));
  sl.registerLazySingleton(() => DeleteFlower(sl()));

  sl.registerLazySingleton<FlowerRepository>(
    () => FlowerRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<FlowerRemoteDataSource>(
    () => FlowerRemoteDataSourceImpl(
      database: sl(),
    ),
  );

  //! Features - Bill
  sl.registerFactory(
    () => BillBloc(
      generateMonthlyBill: sl(),
      getBillDetails: sl(),
      getAllBills: sl(),
      getCustomerBills: sl(),
    ),
  );

  sl.registerLazySingleton(() => GenerateMonthlyBill(sl()));
  sl.registerLazySingleton(() => GetBillDetails(sl()));
  sl.registerLazySingleton(() => GetAllBills(sl()));
  sl.registerLazySingleton(() => GetCustomerBills(sl()));

  sl.registerLazySingleton<BillRepository>(
    () => BillRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<BillRemoteDataSource>(
    () => BillRemoteDataSourceImpl(
      database: sl(),
    ),
  );

  //! Features - Dashboard
  sl.registerFactory(
    () => DashboardBloc(
      getDashboardSummary: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetDashboardSummary(sl()));

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(
      database: sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton(() => NeonDatabase.instance);

  // Initialize Neon Database
  await sl<NeonDatabase>().initialize(
    host: 'ep-XXXXXXXX.us-east-2.aws.neon.tech',
    port: 5432,
    database: 'flower_market_db',
    username: 'your_username',
    password: 'your_password',
  );
}

📦 DEPENDENCIES (pubspec.yaml)
yamlname: flower_market_app
description: Flower market management with Clean Architecture
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Neon PostgreSQL
  postgres: ^3.0.0
  
  # State Management (BLoC)
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Dependency Injection
  get_it: ^7.6.4
  
  # Functional Programming (Either/Failure)
  dartz: ^0.10.1
  
  # UI Enhancements
  google_fonts: ^6.1.0
  shimmer: ^3.0.0
  
  # Date/Time
  intl: ^0.19.0
  
  # PDF Generation (for bills)
  pdf: ^3.10.7
  printing: ^5.12.0
  
  # Utilities
  logger: ^2.0.2+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
  # Testing
  mockito: ^5.4.4
  bloc_test: ^9.1.5
  
  # Build Runner (for code generation)
  build_runner: ^2.4.7

flutter:
  uses-material-design: true

🎯 IMPLEMENTATION CHECKLIST
Phase 1: Core Setup ✅

 Setup Flutter project structure
 Configure pubspec.yaml dependencies
 Create Neon PostgreSQL database
 Run all SQL schema scripts
 Setup NeonDatabase singleton
 Create injection_container.dart
 Configure main.dart with BlocProviders

Phase 2: Domain Layer ✅

 Create all entities (Customer, Flower, Transaction, Bill, DashboardSummary)
 Define all repository contracts
 Implement all use cases for each feature

Phase 3: Data Layer ✅

 Create all models extending entities
 Implement all remote data sources
 Implement all repository implementations
 Add error handling and exceptions

Phase 4: Presentation Layer - BLoC ✅

 Create events for all features
 Create states for all features
 Implement all BLoC logic
 Handle loading, success, and error states

Phase 5: UI Implementation ✅

 Create shell navigation with modern navbar
 Implement Dashboard screen with summary cards
 Implement Manage screen with dual tabs
 Create Flower list and add screens
 Create Customer list and add screens
 Implement Transaction screen with list
 Create Add Transaction form
 Implement Bill screen with generation
 Create Bill detail screen with PDF export
 Implement Settings screen

Phase 6: Testing & Refinement ✅

 Write unit tests for use cases
 Write unit tests for repositories
 Write widget tests for screens
 Write bloc tests
 Test database triggers
 Test stored procedures
 Performance optimization
 UI/UX polish


🚀 EXECUTION PRIORITIES
Priority 1: Core Business Flow

Setup database and connection
Implement Transaction module (full CRUD)
Implement Bill generation
Test end-to-end flow: Transaction → Bill

Priority 2: Supporting Features

Implement Customer management
Implement Flower management
Dashboard with real-time analytics

Priority 3: Enhancement

Payment tracking
Expense management
Advanced reporting
PDF generation for bills


💡 BEST PRACTICES TO FOLLOW

Clean Architecture Principles

Domain layer has ZERO dependencies on outer layers
Data layer only depends on domain
Presentation layer only depends on domain and data


BLoC Pattern

One BLoC per feature
Events represent user intentions
States represent UI conditions
Never call repositories directly from UI


Error Handling

Use Either<Failure, Success> pattern
Always handle both left (failure) and right (success)
Show user-friendly error messages


Database Operations

Use transactions for multi-step operations
Leverage PostgreSQL triggers for auto-calculations
Use views for complex aggregations
Always use parameterized queries (prevent SQL injection)


Code Quality

Follow Dart style guide
Use const constructors where possible
Write meaningful variable/function names
Add comments for complex business logic




🎨 UI COMPONENT EXAMPLES
Summary Card Widget
dartclass SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isWide;

  const SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isWide = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white54,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
Transaction Card Widget
dartclass TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;

  const TransactionCard({
    required this.transaction,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF50C878).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.flowerName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.customerName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(
                'Quantity',
                '${transaction.quantity} kg',
                Icons.scale,
              ),
              _buildInfoColumn(
                'Rate',
                '₹${transaction.rate}',
                Icons.currency_rupee,
              ),
              _buildInfoColumn(
                'Net Amount',
                '₹${transaction.netAmount}',
                Icons.account_balance_wallet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF50C878)),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

🔐 SECURITY CONSIDERATIONS

Never commit Neon credentials

Use environment variables
Store in secure storage (flutter_secure_storage)


SQL Injection Prevention

Always use parameterized queries
Never concatenate user input into SQL


Input Validation

Validate on both client and server (DB constraints)
Use CHECK constraints in PostgreSQL


SSL/TLS

Always use SSL for Neon connection
Verify SSL certificates




📊 PERFORMANCE OPTIMIZATION

Database Level

Create indexes on frequently queried columns
Use PostgreSQL views for complex queries
Leverage triggers for auto-calculations
Use connection pooling


Flutter Level

Use const constructors
Implement lazy loading for lists
Cache frequently accessed data
Optimize widget rebuilds with BLoC


Network Level

Batch operations where possible
Use pagination for large datasets
Implement retry logic with exponential backoff




✅ DEFINITION OF DONE
A feature is complete when:

✅ All layers implemented (Domain → Data → Presentation)
✅ BLoC handles all events and states
✅ UI responds to all BLoC states (loading, success, error)
✅ Database operations work correctly with triggers
✅ Error handling implemented end-to-end
✅ User feedback provided (SnackBars, dialogs)
✅ Code follows Clean Architecture principles
✅ No direct dependencies between layers violated