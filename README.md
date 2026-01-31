# Quran Gate Academy Management System

A comprehensive cross-platform academy management system built with **Flutter** and **Appwrite** for managing Quran teachers, students, classes, schedules, and more.

![Platform](https://img.shields.io/badge/platform-Web%20%7C%20Android%20%7C%20iOS-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter)
![Appwrite](https://img.shields.io/badge/Appwrite-1.4%2B-F02E65?logo=appwrite)

## 📋 Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Appwrite Setup](#appwrite-setup)
- [Flutter App Setup](#flutter-app-setup)
- [Project Structure](#project-structure)
- [User Roles](#user-roles)
- [Key Features Explained](#key-features-explained)
- [Development Guide](#development-guide)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

## ✨ Features

### For Teachers

- 📊 **Dashboard** - View teaching hours, salary, attendance percentage
- 📅 **Schedule Management** - Define weekly availability, view assigned classes
- 👨‍🎓 **Student Information** - Access assigned students' information
- ✅ **Class Status Updates** - Mark classes as completed, absent, or cancelled
- 🔄 **Reschedule Requests** - Request class reschedules (admin approval required)
- 📚 **Course Library** - Browse available courses
- 📝 **Tasks** - View and manage assigned tasks

### For Admins

- 👥 **User Management** - Manage teachers and their profiles
- 👨‍🎓 **Student Management** - Full CRUD operations for students
- 📚 **Course Management** - Create and manage courses
- 📋 **Plan Management** - Create student subscription plans
- 🎓 **Session Assignment** - Assign teachers to sessions based on availability
- ✅ **Reschedule Approval** - Approve or reject reschedule requests
- 💰 **Salary Management** - View and manage teacher salaries
- 📊 **Analytics** - Teacher performance and attendance tracking
- 📝 **Task Management** - Create and assign tasks

## 📱 Screenshots

_Add your screenshots here after implementing the UI_

## 🏗️ Architecture

This project follows **Clean Architecture** with **MVVM** pattern:

```
Presentation Layer (UI + Cubit)
        ↓
Domain Layer (Repository Interfaces)
        ↓
Data Layer (Repository Implementations + Services)
        ↓
Appwrite Backend
```

### Key Principles:

- **Separation of Concerns** - Each layer has a specific responsibility
- **Dependency Inversion** - High-level modules don't depend on low-level modules
- **Testability** - Easy to unit test each layer independently
- **Scalability** - Easy to add new features without affecting existing code

## 🛠️ Tech Stack

### Frontend
- **Flutter** 3.0+ - Cross-platform UI framework
- **flutter_bloc** (Cubit) - State management
- **go_router** - Navigation
- **get_it** - Dependency injection
- **google_fonts** - Typography
- **fl_chart** - Analytics charts
- **table_calendar** - Schedule calendar

### Backend
- **Appwrite** - Backend as a Service
  - Authentication
  - Database (NoSQL)
  - Storage
  - Realtime subscriptions

### Development Tools
- **Node.js** - Appwrite setup script
- **Dart** - Programming language

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0 or higher) - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (3.0 or higher) - Comes with Flutter
- **Node.js** (14 or higher) - [Install Node.js](https://nodejs.org/)
- **Appwrite** - Either:
  - [Appwrite Cloud](https://cloud.appwrite.io/) (Recommended for quick start)
  - [Self-hosted Appwrite](https://appwrite.io/docs/installation) (For production)
- **Git** - Version control
- **Code Editor** - VS Code, Android Studio, or IntelliJ IDEA

### Verify Installation

```bash
# Check Flutter
flutter --version

# Check Dart
dart --version

# Check Node.js
node --version

# Check npm
npm --version
```

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/quran-gate-academy.git
cd quran-gate-academy
```

### 2. Set Up Appwrite Backend

#### Create Appwrite Project

1. Go to [Appwrite Cloud](https://cloud.appwrite.io/) or your self-hosted instance
2. Create a new project
3. Note down your:
   - **Project ID**
   - **API Endpoint** (e.g., `https://cloud.appwrite.io/v1`)
   - **API Key** (Create one with full permissions)

#### Run Automated Setup Script

```bash
cd appwrite-setup
npm install
```

Create `.env` file:

```bash
cp .env.example .env
```

Edit `.env` with your Appwrite credentials:

```env
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your-project-id
APPWRITE_API_KEY=your-api-key
```

Run the setup script:

```bash
npm run setup
```

This will automatically create:
- Database
- All collections (9 collections)
- Attributes for each collection
- Indexes for optimized queries
- Permissions

### 3. Configure Flutter App

Navigate to Flutter app directory:

```bash
cd ../flutter_app
```

Install dependencies:

```bash
flutter pub get
```

Update Appwrite configuration in `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  static const String appwriteEndpoint = 'https://cloud.appwrite.io/v1';
  static const String appwriteProjectId = 'your-project-id';
  static const String appwriteDatabaseId = 'quran_gate_db';
  // ...
}
```

## 🎮 Appwrite Setup

### Database Structure

The system uses the following collections:

#### 1. **Users** (`users`)
Stores teacher and admin accounts
- Fields: userId, email, fullName, role, hourlyRate, profilePicture, status, specialization
- Indexes: userId, email, role

#### 2. **Students** (`students`)
Student information
- Fields: fullName, email, phone, whatsapp, country, timezone, profilePicture, status
- Indexes: fullName (fulltext), country

#### 3. **Courses** (`courses`)
Available courses
- Fields: title, description, category, coverImage, level, estimatedHours, status
- Indexes: title (fulltext), category

#### 4. **Plans** (`plans`)
Student subscription plans
- Fields: studentId, courseId, planName, totalSessions, completedSessions, sessionDuration, totalPrice, status
- Indexes: studentId, courseId, status

#### 5. **Class Sessions** (`class_sessions`)
Individual class sessions
- Fields: teacherId, studentId, courseId, scheduledDate, scheduledTime, duration, status, salaryAmount
- Indexes: teacherId, studentId, courseId, status, scheduledDate

#### 6. **Teacher Availability** (`teacher_availability`)
Teacher weekly availability
- Fields: teacherId, dayOfWeek, startTime, endTime, isAvailable, timezone
- Indexes: teacherId, dayOfWeek

#### 7. **Reschedule Requests** (`reschedule_requests`)
Session reschedule requests
- Fields: sessionId, requestedBy, originalDate, newDate, reason, status, reviewedBy
- Indexes: sessionId, status

#### 8. **Salary Records** (`salary_records`)
Monthly salary calculations
- Fields: teacherId, month, year, totalHours, totalAmount, fines, bonuses, netAmount, status
- Indexes: teacherId, month/year

#### 9. **Tasks** (`tasks`)
Task management
- Fields: title, description, assignedTo, createdBy, status, priority, dueDate
- Indexes: assignedTo, status, dueDate

### Creating First Admin User

After running the setup script, create your first admin user:

1. Go to Appwrite Console → Auth
2. Create a new user with email/password
3. Note the User ID
4. Go to Database → quran_gate_db → users collection
5. Create a document with:
   ```json
   {
     "userId": "the-user-id-from-auth",
     "email": "admin@example.com",
     "fullName": "Admin User",
     "role": "admin",
     "hourlyRate": 0,
     "status": "active",
     "createdAt": "2024-01-01T00:00:00.000Z"
   }
   ```

## 📱 Flutter App Setup

### Running the App

#### Web

```bash
flutter run -d chrome
```

#### Android

```bash
flutter run -d android
```

#### iOS

```bash
flutter run -d ios
```

### Build for Production

#### Web

```bash
flutter build web
```

#### Android APK

```bash
flutter build apk --release
```

#### iOS

```bash
flutter build ios --release
```

## 📁 Project Structure

```
quran-gate-academy/
├── appwrite-setup/              # Appwrite backend setup
│   ├── setup.js                 # Automated setup script
│   ├── package.json
│   ├── .env.example
│   └── README.md
│
├── flutter_app/                 # Flutter application
│   ├── lib/
│   │   ├── main.dart           # App entry point
│   │   ├── core/               # Core functionality
│   │   │   ├── config/         # Configuration
│   │   │   ├── di/             # Dependency injection
│   │   │   ├── models/         # Shared data models
│   │   │   ├── router/         # Navigation
│   │   │   ├── theme/          # Theme & styling
│   │   │   ├── utils/          # Utilities
│   │   │   └── widgets/        # Shared widgets
│   │   │
│   │   └── features/           # Feature modules
│   │       ├── auth/           # Authentication
│   │       ├── dashboard/      # Dashboard
│   │       ├── schedule/       # Schedule & Availability
│   │       ├── students/       # Student Management
│   │       ├── library/        # Course Library
│   │       └── tasks/          # Task Management
│   │
│   ├── pubspec.yaml            # Dependencies
│   └── README.md
│
├── IMPLEMENTATION_GUIDE.md     # Detailed implementation guide
└── README.md                   # This file
```

## 👥 User Roles

### Teacher Role

**Permissions:**
- View own dashboard and statistics
- View assigned classes
- Update class status (after session end time)
- View assigned students (read-only)
- Manage personal availability
- Request reschedules
- View course library
- View assigned tasks

**Restrictions:**
- Cannot create or delete students
- Cannot assign classes
- Cannot approve reschedules
- Cannot access admin features

### Admin Role

**Permissions:**
- All teacher permissions
- Create/edit/delete teachers
- Create/edit/delete students
- Create/edit/delete courses
- Create/edit/delete plans
- Assign teachers to sessions
- Approve/reject reschedule requests
- View all teacher statistics
- Manage salary records
- Create/assign tasks
- Access to all system features

## 🎯 Key Features Explained

### 1. Dashboard

Teachers see:
- Total teaching hours (weekly/monthly)
- Hours taken vs. remaining
- Attendance percentage
- Salary till today
- Today's classes list

Calculation formulas:
```dart
// Total Hours
totalHours = sum(completedSessions.duration) / 60

// Salary Till Today
salary = sum(completedSessions.salaryAmount)

// Attendance Percentage
attendance = (completedSessions / totalScheduledSessions) * 100
```

### 2. Schedule & Availability

**Teacher Availability:**
- Teachers define weekly availability (day, start time, end time)
- Multiple time slots per day
- Can mark specific times as unavailable

**Calendar View:**
- Weekly/Monthly view
- Shows availability and assigned sessions
- Color-coded status indicators

**Admin Session Assignment:**
1. Admin receives student request (via WhatsApp)
2. Admin checks teacher availability
3. Admin assigns teacher and creates sessions
4. Sessions appear in teacher's schedule

### 3. Class Session Workflow

**Session Statuses:**
- `scheduled` - Initial status when created
- `completed` - Marked by teacher after session
- `absent` - Student didn't attend
- `student_cancel` - Student cancelled
- `teacher_cancel` - Teacher cancelled

**Status Change Rules:**
- Teachers can only update status after scheduled end time
- Completed sessions contribute to salary
- Status changes trigger salary recalculation

### 4. Reschedule Flow

1. **Teacher Request:**
   - Teacher selects session
   - Proposes new date/time
   - Provides reason
   - Creates RescheduleRequest

2. **Admin Review:**
   - Admin sees pending requests
   - Reviews reason and new proposed time
   - Checks availability conflicts
   - Approves or rejects with notes

3. **Update Session:**
   - If approved: ClassSession updated with new date/time
   - Teacher notified
   - Calendar updated

### 5. Salary Calculation

**Automatic Calculation:**
```dart
// Per Session
sessionSalary = (teacherHourlyRate) * (sessionDuration / 60)

// Monthly Total
monthlySalary = sum(completedSessionsInMonth.salaryAmount)
                - fines
                + bonuses
```

**Salary Record:**
- Generated monthly for each teacher
- Includes: totalHours, totalAmount, fines, bonuses, netAmount
- Status: pending → paid

## 💻 Development Guide

### Adding a New Feature

Follow the feature template in [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md):

1. Create service layer (data/services/)
2. Create repository interface (domain/repositories/)
3. Create repository implementation (data/repositories/)
4. Create state classes (presentation/cubit/)
5. Create cubit (presentation/cubit/)
6. Create UI pages (presentation/pages/)
7. Register in dependency injection

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused
- Use const constructors where possible

### State Management

This project uses **Cubit** (simplified Bloc):

```dart
// Emit states
emit(LoadingState());
emit(LoadedState(data));
emit(ErrorState(message));

// Listen to states
BlocBuilder<MyCubit, MyState>(
  builder: (context, state) {
    if (state is LoadingState) return LoadingWidget();
    if (state is LoadedState) return DataWidget(state.data);
    return ErrorWidget();
  },
)
```

### Navigation

Using **go_router**:

```dart
// Navigate
context.go('/dashboard');
context.push('/students/123');

// Go back
context.pop();
```

## 🧪 Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth/auth_cubit_test.dart

# Run with coverage
flutter test --coverage
```

### Writing Tests

```dart
// Unit test example
test('login with valid credentials should emit AuthAuthenticated', () async {
  // Arrange
  when(mockRepository.login(email: 'test@example.com', password: 'password'))
      .thenAnswer((_) async => mockUser);

  // Act
  await cubit.login(email: 'test@example.com', password: 'password');

  // Assert
  expect(cubit.state, isA<AuthAuthenticated>());
});
```

## 🚀 Deployment

### Web Deployment

1. Build the web app:
   ```bash
   flutter build web --release
   ```

2. Deploy `build/web/` to:
   - Firebase Hosting
   - Netlify
   - Vercel
   - GitHub Pages

### Mobile Deployment

#### Android (Google Play)

1. Create keystore:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Build app bundle:
   ```bash
   flutter build appbundle --release
   ```

3. Upload to Google Play Console

#### iOS (App Store)

1. Configure Xcode project
2. Build:
   ```bash
   flutter build ios --release
   ```
3. Archive and upload via Xcode

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Workflow

1. Create an issue describing the feature/bug
2. Get approval before starting work
3. Follow the code style guide
4. Write tests for new features
5. Update documentation
6. Submit PR with clear description

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support, email support@qurangateacademy.com or create an issue in this repository.

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev/) - Amazing cross-platform framework
- [Appwrite Team](https://appwrite.io/) - Excellent BaaS platform
- [Community Contributors](https://github.com/yourusername/quran-gate-academy/graphs/contributors)

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Appwrite Documentation](https://appwrite.io/docs)
- [Implementation Guide](IMPLEMENTATION_GUIDE.md) - Detailed feature implementation guide
- [API Documentation](docs/API.md) - Appwrite API reference

---

**Built with ❤️ for Quran education**

**Version:** 1.0.0
**Last Updated:** 2024
