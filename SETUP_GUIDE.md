# 🌸 Flower Market Management App

A modern, production-ready Flutter mobile application for managing a flower market business using **Clean Architecture** with **BLoC pattern** and direct **Neon PostgreSQL** cloud database integration.

## ✨ Features

- **Dashboard Analytics**: Real-time business overview with weekly sales, monthly profit, and key metrics
- **Transaction Management**: Daily flower transaction tracking with customer and flower details
- **Customer Management**: Complete CRUD operations for customer records
- **Flower Inventory**: Manage flower types and pricing
- **Monthly Billing**: Automated bill generation with flower-wise breakup
- **Payment Tracking**: Monitor pending payments and bill statuses

## 🏗️ Architecture

The app follows **Clean Architecture** principles with three distinct layers:

### Domain Layer (Business Logic)
- **Entities**: Pure business objects (Customer, Flower, Transaction, Bill, Dashboard Summary)
- **Repositories**: Abstract contracts for data operations
- **Use Cases**: Single-responsibility business operations

### Data Layer (Data Management)
- **Data Sources**: Direct Neon PostgreSQL database operations
- **Models**: Data transfer objects with JSON serialization
- **Repository Implementations**: Concrete implementations with error handling

### Presentation Layer (UI)
- **BLoC Pattern**: State management with Events, States, and Business Logic Components
- **Screens**: Feature-based UI organization
- **Widgets**: Reusable, design-system-compliant components

## 📋 Prerequisites

- Flutter SDK 3.2.0 or higher
- Dart SDK 3.2.0 or higher
- Neon PostgreSQL database account ([Get one here](https://neon.tech))
- Android Studio / VS Code with Flutter extensions

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Flower_Management_App
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Set Up Neon PostgreSQL Database

1. Create a new project on [Neon](https://neon.tech)
2. Create a database named `flower_market_db`
3. Execute the SQL schema from `master_prompt.md` (lines 143-475) to create all tables, triggers, and views
4. Note your connection credentials

### 4. Configure Database Connection

Edit `lib/main.dart` and update the database credentials:

```dart
await sl<NeonDatabase>().initialize(
  host: 'your-neon-host.aws.neon.tech',  // Your Neon host
  port: 5432,
  database: 'flower_market_db',
  username: 'your-username',              // Your Neon username
  password: 'your-password',              // Your Neon password
);
```

**⚠️ Important**: For production, use environment variables or secure storage instead of hardcoding credentials.

### 5. Run the App

```bash
flutter run
```

## 📦 Project Structure

```
lib/
├── core/
│   ├── error/              # Failures and exceptions
│   ├── usecases/           # Base use case contract
│   └── utils/              # Constants, formatters, design system
├── data/
│   ├── datasources/        # Neon database operations
│   ├── models/             # Data transfer objects
│   └── repositories/       # Repository implementations
├── domain/
│   ├── entities/           # Business objects
│   ├── repositories/       # Repository contracts
│   └── usecases/           # Business logic operations
├── presentation/
│   ├── bloc/               # BLoC (Events, States, BLoCs)
│   ├── screens/            # UI screens
│   └── widgets/            # Reusable widgets
├── injection_container.dart # Dependency injection setup
└── main.dart               # App entry point
```

## 🎨 Design System

The app uses a modern **glassmorphism** design with:

- **Primary Color**: Emerald Green (#50C878)
- **Background**: Deep Black (#121212)
- **Surface**: Card Background (#1E1E1E)
- **Typography**: Google Fonts - Poppins
- **Spacing**: Consistent 4, 8, 16, 24, 32 pixel spacing
- **Border Radius**: 8, 12, 16, 24, 30 pixel rounded corners

## 🔑 Key Technologies

- **Flutter**: Cross-platform mobile framework
- **BLoC**: State management pattern
- **Neon PostgreSQL**: Cloud-native PostgreSQL database
- **Get It**: Dependency injection
- **Dartz**: Functional programming (Either type for error handling)
- **Equatable**: Value equality for BLoC states/events
- **Google Fonts**: Beautiful typography

## 📱 Screens

1. **Dashboard**: Business overview with key metrics
2. **Transactions**: Daily transaction management with add/delete operations
3. **Manage**: Tabbed view for Flowers and Customers management
4. **Bills**: Monthly bill generation and viewing

## 🧪 Testing

The project is structured to support easy unit testing:

```bash
flutter test
```

## 📚 Database Schema Highlights

- **Automatic Calculations**: PostgreSQL triggers auto-update daily totals
- **Bill Generation**: Stored procedure for monthly bill creation
- **Dashboard View**: Server-side aggregation for performance
- **Referential Integrity**: Foreign keys with proper cascade rules

## 🔐 Security Considerations

- ✅ SSL/TLS connection to Neon database
- ✅ Parameterized queries (SQL injection prevention)
- ✅ Input validation on both client and server
- ⚠️ **TODO**: Move database credentials to environment variables

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Development Guidelines

- Follow Clean Architecture principles
- Never violate layer dependencies (Domain → Data → Presentation)
- Use the design system constants (no hardcoded values)
- Always emit Loading state before async BLoC operations
- Handle both success and error cases in repositories
- Write meaningful commit messages

## 🐛 Known Issues

- Date range filtering in transactions needs implementation
- Bill detail view screen not yet created
- Generate bill UI flow needs completion
- Expense tracking feature pending

## 🗺️ Roadmap

- [ ] Payment recording and tracking
- [ ] Expense management
- [ ] Advanced reporting and analytics
- [ ] PDF bill generation
- [ ] Multi-language support
- [ ] Dark/Light theme toggle
- [ ] Export data to Excel/CSV

## 📞 Support

For issues, questions, or contributions, please open an issue on GitHub.

---

**Built with ❤️ using Flutter and Clean Architecture**
