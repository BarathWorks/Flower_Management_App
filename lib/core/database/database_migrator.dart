import 'package:logger/logger.dart';
import '../../data/datasources/neon_database.dart';

class DatabaseMigrator {
  final NeonDatabase database;
  final Logger _logger = Logger();

  DatabaseMigrator(this.database);

  Future<void> migrate() async {
    try {
      _logger.i('Starting database migration...');

      // Add default_rate to flowers table
      await database.connection.execute(
        'ALTER TABLE flowers ADD COLUMN IF NOT EXISTS default_rate DOUBLE PRECISION',
      );
      _logger.i('Added default_rate to flowers table');

      // Add default_commission to customers table
      await database.connection.execute(
        'ALTER TABLE customers ADD COLUMN IF NOT EXISTS default_commission DOUBLE PRECISION',
      );
      _logger.i('Added default_commission to customers table');

      // Create settings table
      await database.connection.execute(
        'CREATE TABLE IF NOT EXISTS settings (key VARCHAR(50) PRIMARY KEY, value TEXT)',
      );
      _logger.i('Created settings table');

      // Create customer_flowers table for many-to-many relationship
      await database.connection.execute(
        'CREATE TABLE IF NOT EXISTS customer_flowers ('
        'customer_id UUID REFERENCES customers(id) ON DELETE CASCADE, '
        'flower_id UUID REFERENCES flowers(id) ON DELETE CASCADE, '
        'PRIMARY KEY (customer_id, flower_id))',
      );
      _logger.i('Created customer_flowers table');

      // Add advance column to daily_flower_customer
      await database.connection.execute(
        'ALTER TABLE daily_flower_customer ADD COLUMN IF NOT EXISTS advance DOUBLE PRECISION DEFAULT 0',
      );
      _logger.i('Added advance to daily_flower_customer table');

      // Add total_advance column to bills
      await database.connection.execute(
        'ALTER TABLE bills ADD COLUMN IF NOT EXISTS total_advance DOUBLE PRECISION DEFAULT 0',
      );
      _logger.i('Added total_advance to bills table');

      // Create or replace generate_monthly_bill calculation function
      await database.connection.execute('''
        CREATE OR REPLACE FUNCTION generate_monthly_bill(
          p_customer_id UUID,
          p_year INTEGER,
          p_month INTEGER
        ) RETURNS UUID AS \$\$
        DECLARE
          v_bill_id UUID;
          v_total_quantity DOUBLE PRECISION;
          v_total_amount DOUBLE PRECISION;
          v_total_commission DOUBLE PRECISION;
          v_total_advance DOUBLE PRECISION;
          v_net_amount DOUBLE PRECISION;
          v_bill_number VARCHAR;
        BEGIN
          -- Calculate totals from daily_flower_customer
          SELECT 
            COALESCE(SUM(dfc.quantity), 0),
            COALESCE(SUM(dfc.amount), 0),
            COALESCE(SUM(dfc.commission), 0),
            COALESCE(SUM(dfc.advance), 0)
          INTO 
            v_total_quantity,
            v_total_amount,
            v_total_commission,
            v_total_advance
          FROM daily_flower_customer dfc
          JOIN daily_flower_entry dfe ON dfc.daily_entry_id = dfe.id
          WHERE dfc.customer_id = p_customer_id
            AND EXTRACT(YEAR FROM dfe.entry_date) = p_year
            AND EXTRACT(MONTH FROM dfe.entry_date) = p_month;

          -- Calculate net amount (Amount - Commission - Advance)
          v_net_amount := v_total_amount - v_total_commission - v_total_advance;

          -- Generate Bill Number (Format: YYYYMM-CUSTID-RANDOM)
          v_bill_number := to_char(p_year, 'FM0000') || to_char(p_month, 'FM00') || '-' || substring(p_customer_id::text, 1, 4);

          -- Create Bill Record
          INSERT INTO bills (
            bill_number, customer_id, bill_year, bill_month,
            total_quantity, total_amount, total_commission, total_advance,
            net_amount, status, generated_at
          ) VALUES (
            v_bill_number, p_customer_id, p_year, p_month,
            v_total_quantity, v_total_amount, v_total_commission, v_total_advance,
            v_net_amount, 'GENERATED', NOW()
          ) RETURNING id INTO v_bill_id;

          -- Link items to bill (if you have a bill_items table, populate it here)
          -- For now, we assume bill_items are viewable via daily_flower_customer query

          RETURN v_bill_id;
        END;
        \$\$ LANGUAGE plpgsql;
      ''');
      _logger.i('Updated generate_monthly_bill function');

      _logger.i('Database migration completed successfully');
    } catch (e) {
      _logger.e('Database migration failed: $e');
      // We don't rethrow here to allow the app to try running even if migration fails
      // (e.g. if columns already exist but error text is different)
    }
  }
}
