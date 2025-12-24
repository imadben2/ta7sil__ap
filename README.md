# Memo App v2

A comprehensive educational platform consisting of a Laravel API backend and Flutter mobile application, designed for managing academic schedules, courses, and student learning.

## 📋 Project Overview

This project is a multi-application system that includes:

- **memo_api**: Laravel-based REST API backend
- **memo_app**: Flutter-based mobile application

The platform provides tools for teachers and students to manage courses, schedules, assignments, and educational content with support for multiple languages (Arabic RTL by default, French, and English).

## 🏗️ Project Structure

```
memo_app_v2/
├── memo_api/          # Laravel API Backend
│   ├── app/
│   ├── config/
│   ├── database/
│   ├── routes/
│   └── ...
├── memo_app/          # Flutter Mobile App
│   ├── lib/
│   ├── assets/
│   ├── android/
│   ├── ios/
│   └── ...
├── docs/              # Project Documentation
│   ├── project_tree.md
│   ├── functions.md
│   └── variables_file.md
├── .gitignore
└── README.md
```

## 🚀 Technology Stack

### Backend (memo_api)
- **Framework**: Laravel 10.x
- **Authentication**: Laravel Sanctum / JWT
- **Database**: MySQL
- **API Type**: RESTful API
- **Security**: CSRF Protection, Rate Limiting

### Frontend (memo_app)
- **Framework**: Flutter 3.x
- **State Management**: Riverpod / Provider
- **HTTP Client**: Dio
- **Secure Storage**: Flutter Secure Storage
- **UI**: Material Design 3
- **Internationalization**: RTL Support (Arabic, French, English)

## ✨ Key Features

### For Teachers
- Course management and scheduling
- Student progress tracking
- Assignment creation and grading
- Content upload and management
- Session scheduling

### For Students
- Course enrollment and access
- Schedule viewing
- Assignment submission
- Progress tracking
- Notification system

### Platform Features
- Multi-language support (Arabic RTL primary)
- Secure authentication (2FA optional)
- Real-time notifications
- Offline data synchronization
- PDF generation for schedules and reports

## 📦 Installation

### Prerequisites

- PHP >= 8.1
- Composer
- MySQL >= 8.0
- Node.js >= 16.x
- Flutter SDK >= 3.0
- Git

### Backend Setup (memo_api)

```bash
# Navigate to API directory
cd memo_api

# Install PHP dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure database in .env file
# DB_DATABASE=your_database_name
# DB_USERNAME=your_username
# DB_PASSWORD=your_password

# Run migrations
php artisan migrate

# Seed database (optional)
php artisan db:seed

# Start development server
php artisan serve
```

### Frontend Setup (memo_app)

```bash
# Navigate to app directory
cd memo_app

# Install dependencies
flutter pub get

# Configure API endpoint in lib/core/config/
# Update base URL to point to your API

# Run on device/emulator
flutter run

# Build for production
flutter build apk          # Android
flutter build ios          # iOS
```

## 🔧 Configuration

### API Configuration (memo_api)

Edit `.env` file:

```env
APP_NAME=MemoAPI
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=memo_db
DB_USERNAME=root
DB_PASSWORD=

SANCTUM_STATEFUL_DOMAINS=localhost:8000
```

### App Configuration (memo_app)

Edit `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://your-api-url.com/api';
  static const String apiVersion = 'v1';
}
```

## 📚 API Documentation

API endpoints are documented in:
- `docs/09-Complete-API-Endpoints.md`

Base URL: `http://your-domain.com/api`

### Main Endpoints

```
POST   /api/auth/login           # User login
POST   /api/auth/logout          # User logout
GET    /api/courses              # List courses
POST   /api/courses              # Create course
GET    /api/schedules            # Get schedules
POST   /api/assignments          # Create assignment
```

## 🧪 Testing

### Backend Tests

```bash
cd memo_api

# Run all tests
php artisan test

# Run specific test suite
php artisan test --testsuite=Feature
```

### Frontend Tests

```bash
cd memo_app

# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📖 Documentation

Comprehensive documentation is maintained in the `docs/` directory:

- **project_tree.md**: Complete file/folder structure
- **functions.md**: All function signatures
- **variables_file.md**: Important variables and state management
- **02-Workflows.md**: Application workflows
- **03-ValidationAndStates.md**: Validation rules and state management
- **04-DatabaseSchema.sql**: Database schema

## 🌍 Internationalization

The app supports:
- **Arabic (ar)**: Primary language with RTL support
- **French (fr)**: Secondary language
- **English (en)**: Secondary language

Translation files located in:
- API: `memo_api/resources/lang/`
- App: `memo_app/lib/l10n/`

## 🔐 Security

- Laravel Sanctum for API authentication
- CSRF protection on all forms
- Rate limiting on sensitive endpoints
- Secure password hashing (bcrypt)
- SQL injection prevention via Eloquent ORM
- XSS protection via input validation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Development Guidelines

- Follow Laravel and Flutter best practices
- Maintain documentation files (project_tree.md, functions.md, variables_file.md)
- Write tests for new features
- Use meaningful commit messages
- Keep code clean and well-commented

## 📄 License

This project is proprietary software. All rights reserved.

## 👥 Authors

- Development Team

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team

## 🗓️ Version History

- **v2.0.0** (2025) - Current version
  - Complete rewrite with Flutter
  - Enhanced API with Laravel 10
  - Improved RTL support
  - New features for teachers and students

---

**Note**: This project uses automated documentation. Always check and update `docs/project_tree.md`, `docs/functions.md`, and `docs/variables_file.md` when making changes.
