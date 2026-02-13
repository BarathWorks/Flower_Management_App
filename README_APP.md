# 🌸 Flower Market Management App

A modern, production-ready Flutter mobile application for managing a flower market business using **Clean Architecture** with **BLoC pattern** and **Neon PostgreSQL** database.

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## ✨ Features

- 📊 **Real-time Dashboard** - Business analytics and insights
- 💐 **Transaction Management** - Daily flower sales tracking
- 👥 **Customer Management** - Complete CRUD operations
- 🌺 **Flower Inventory** - Manage flower types and pricing
- 📄 **Automated Billing** - Monthly bill generation with breakdowns
- 💳 **Payment Tracking** - Monitor pending payments and statuses

## 🏗️ Architecture

Built with **Clean Architecture** principles:
- **Domain Layer**: Business logic and entities
- **Data Layer**: PostgreSQL database operations
- **Presentation Layer**: BLoC state management + Flutter UI

## 📚 Documentation

- **[Setup Guide](SETUP_GUIDE.md)**: Complete installation and configuration instructions
- **[Master Prompt](master_prompt.md)**: Detailed architecture and database schema
- **[Skills](SKILL.md)**: Flutter BLoC development guidelines

## 🛠️ Tech Stack

- Flutter 3.2.0+
- BLoC Pattern (State Management)
- Neon PostgreSQL (Cloud Database)
- Clean Architecture
- Get It (Dependency Injection)
- Google Fonts (Typography)

## ⚙️ Configuration

1. Set up your [Neon PostgreSQL](https://neon.tech) database
2. Copy `.env.example` to `.env` and add your credentials
3. Run the SQL schema from `master_prompt.md`
4. Update database connection in `lib/main.dart`

## 📦 Project Structure

```
lib/
├── core/               # Error handling, utilities, design system
├── data/               # Data sources, models, repositories
├── domain/             # Entities, repository contracts, use cases
├── presentation/       # BLoC, screens, widgets
├── injection_container.dart
└── main.dart
```

## 📄 License

MIT License - See LICENSE file for details

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests.

---

**Built with ❤️ using Flutter and Clean Architecture**
