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
      // NOTE: We are keeping the old function for backward compatibility if needed,
      // but creating a new one for date ranges.

      // Add start_date and end_date columns to bills
      await database.connection.execute(
        'ALTER TABLE bills ADD COLUMN IF NOT EXISTS start_date DATE',
      );
      await database.connection.execute(
        'ALTER TABLE bills ADD COLUMN IF NOT EXISTS end_date DATE',
      );
      await database.connection.execute(
        'ALTER TABLE bills ADD COLUMN IF NOT EXISTS end_date DATE',
      );
      _logger.i('Added start_date and end_date to bills table');

      // Add paid_amount to bills
      await database.connection.execute(
        'ALTER TABLE bills ADD COLUMN IF NOT EXISTS paid_amount DOUBLE PRECISION DEFAULT 0',
      );
      _logger.i('Added paid_amount to bills table');

      // Create payments table if it doesn't exist
      await database.connection.execute(
        '''
        CREATE TABLE IF NOT EXISTS payments (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          bill_id UUID REFERENCES bills(id) ON DELETE CASCADE,
          amount DOUBLE PRECISION NOT NULL,
          payment_date TIMESTAMP DEFAULT NOW(),
          notes TEXT
        )
        ''',
      );
      _logger.i('Ensured payments table exists');

      // Drop unique constraint to allow multiple bills per month
      await database.connection.execute(
        'ALTER TABLE bills DROP CONSTRAINT IF EXISTS bills_customer_id_bill_year_bill_month_key',
      );
      _logger.i('Dropped unique constraint on bills table');

      await database.connection.execute('''
        CREATE OR REPLACE FUNCTION generate_bill(
          p_customer_id UUID,
          p_start_date DATE,
          p_end_date DATE
        ) RETURNS UUID AS \$\$
        DECLARE
          v_bill_id UUID;
          v_total_quantity DOUBLE PRECISION;
          v_total_amount DOUBLE PRECISION;
          v_total_commission DOUBLE PRECISION;
          v_total_advance DOUBLE PRECISION;
          v_net_amount DOUBLE PRECISION;
          v_bill_number VARCHAR;
          v_year INTEGER;
          v_month INTEGER;
        BEGIN
          -- Calculate totals from daily_flower_customer for the given date range
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
            AND dfe.entry_date BETWEEN p_start_date AND p_end_date;

          -- Calculate net amount (Amount - Commission - Advance)
          v_net_amount := v_total_amount - v_total_commission - v_total_advance;

          -- Use start date for year/month reference
          v_year := EXTRACT(YEAR FROM p_start_date);
          v_month := EXTRACT(MONTH FROM p_start_date);

          -- Generate Bill Number (Format: YYYYMMDD-CUSTID-RANDOM)
          v_bill_number := to_char(p_start_date, 'YYYYMMDD') || '-' || to_char(p_end_date, 'MMDD') || '-' || substring(p_customer_id::text, 1, 4);

          -- Create Bill Record
          INSERT INTO bills (
            bill_number, customer_id, bill_year, bill_month,
            start_date, end_date,
            total_quantity, total_amount, total_commission, total_advance,
            net_amount, status, generated_at
          ) VALUES (
            v_bill_number, p_customer_id, v_year, v_month,
            p_start_date, p_end_date,
            v_total_quantity, v_total_amount, v_total_commission, v_total_advance,
            v_net_amount, 'UNPAID', NOW()
          ) RETURNING id INTO v_bill_id;

          -- Insert Bill Items
          INSERT INTO bill_items (
            bill_id, flower_id, total_quantity, total_amount, total_commission, net_amount
          )
          SELECT 
            v_bill_id,
            dfe.flower_id,
            SUM(dfc.quantity),
            SUM(dfc.amount),
            SUM(dfc.commission),
            SUM(dfc.amount) - SUM(dfc.commission)
          FROM daily_flower_customer dfc
          JOIN daily_flower_entry dfe ON dfc.daily_entry_id = dfe.id
          WHERE dfc.customer_id = p_customer_id
            AND dfe.entry_date BETWEEN p_start_date AND p_end_date
          GROUP BY dfe.flower_id;

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
