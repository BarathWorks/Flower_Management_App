import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/utils/constants.dart';
import 'core/utils/typography.dart';
import 'injection_container.dart';
import 'presentation/bloc/bill/bill_bloc.dart';
import 'presentation/bloc/customer/customer_bloc.dart';
import 'presentation/bloc/dashboard/dashboard_bloc.dart';
import 'presentation/bloc/flower/flower_bloc.dart';
import 'presentation/bloc/transaction/transaction_bloc.dart';
import 'presentation/screens/shell_screen.dart';
import 'data/datasources/neon_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await init();

  // Initialize database connection
  // TODO: Replace with your actual Neon database credentials
  await sl<NeonDatabase>().initialize(
    host: 'ep-noisy-firefly-aia82988-pooler.c-4.us-east-1.aws.neon.tech',
    port: 5432,
    database: 'neondb',
    username: 'neondb_owner',
    password: 'npg_Y4z9uBKCjdyg',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DashboardBloc>()),
        BlocProvider(create: (_) => sl<TransactionBloc>()),
        BlocProvider(create: (_) => sl<CustomerBloc>()),
        BlocProvider(create: (_) => sl<FlowerBloc>()),
        BlocProvider(create: (_) => sl<BillBloc>()),
      ],
      child: MaterialApp(
        title: 'Flower Market Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.backgroundDark,
          primaryColor: AppColors.primaryEmerald,
          fontFamily: 'Poppins',
          textTheme: TextTheme(
            displayLarge: AppTypography.headlineLarge,
            displayMedium: AppTypography.headlineMedium,
            displaySmall: AppTypography.headlineSmall,
            titleLarge: AppTypography.titleLarge,
            titleMedium: AppTypography.titleMedium,
            bodyLarge: AppTypography.bodyLarge,
            bodyMedium: AppTypography.bodyMedium,
            bodySmall: AppTypography.bodySmall,
            labelLarge: AppTypography.labelLarge,
          ),
          colorScheme: ColorScheme.dark(
            primary: AppColors.primaryEmerald,
            secondary: AppColors.accentOrange,
            surface: AppColors.surfaceDark,
            background: AppColors.backgroundDark,
            error: AppColors.error,
          ),
        ),
        home: const ShellScreen(),
      ),
    );
  }
}
