# Quran Gate Academy - Complete Implementation Guide

This guide provides a comprehensive overview of the system architecture and step-by-step instructions for implementing each feature.

## 📁 Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── config/
│   │   │   └── app_config.dart          # Appwrite configuration
│   │   ├── di/
│   │   │   └── injection.dart           # Dependency injection
│   │   ├── models/                       # Shared data models
│   │   │   ├── user_model.dart
│   │   │   ├── student_model.dart
│   │   │   ├── course_model.dart
│   │   │   ├── plan_model.dart
│   │   │   ├── class_session_model.dart
│   │   │   ├── teacher_availability_model.dart
│   │   │   ├── reschedule_request_model.dart
│   │   │   ├── salary_record_model.dart
│   │   │   └── task_model.dart
│   │   ├── router/
│   │   │   └── app_router.dart          # Navigation configuration
│   │   ├── theme/
│   │   │   └── app_theme.dart           # Theme configuration
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   └── validators.dart
│   │   └── widgets/                      # Shared UI components
│   │       ├── app_sidebar.dart
│   │       ├── stat_card.dart
│   │       ├── session_card.dart
│   │       ├── student_card.dart
│   │       └── loading_widget.dart
│   └── features/
│       ├── auth/                         # Authentication feature
│       │   ├── data/
│       │   │   ├── models/
│       │   │   ├── repositories/
│       │   │   │   └── auth_repository_impl.dart
│       │   │   └── services/
│       │   │       └── auth_service.dart
│       │   ├── domain/
│       │   │   └── repositories/
│       │   │       └── auth_repository.dart
│       │   └── presentation/
│       │       ├── cubit/
│       │       │   ├── auth_cubit.dart
│       │       │   └── auth_state.dart
│       │       └── pages/
│       │           └── login_page.dart
│       ├── dashboard/                    # Dashboard feature
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── dashboard_stats_model.dart
│       │   │   ├── repositories/
│       │   │   │   └── dashboard_repository_impl.dart
│       │   │   └── services/
│       │   │       └── dashboard_service.dart
│       │   ├── domain/
│       │   │   └── repositories/
│       │   │       └── dashboard_repository.dart
│       │   └── presentation/
│       │       ├── cubit/
│       │       │   ├── dashboard_cubit.dart
│       │       │   └── dashboard_state.dart
│       │       ├── pages/
│       │       │   └── dashboard_page.dart
│       │       └── widgets/
│       │           ├── stats_overview.dart
│       │           └── today_classes_list.dart
│       ├── schedule/                     # Schedule & Availability
│       ├── students/                     # Student Management
│       ├── library/                      # Courses Library
│       └── tasks/                        # Task Management
```

## 🏗️ Architecture Pattern: MVVM with Clean Architecture

### Layers:

1. **Presentation Layer** (`presentation/`)
   - UI (Pages & Widgets)
   - State Management (Cubit)
   - User interaction handling

2. **Domain Layer** (`domain/`)
   - Repository interfaces
   - Business logic (optional use cases)

3. **Data Layer** (`data/`)
   - Repository implementations
   - Services (Appwrite API calls)
   - Models (JSON serialization)

### Data Flow:

```
UI → Cubit → Repository Interface → Repository Implementation → Service → Appwrite
```

## 📝 Feature Implementation Template

For each feature, follow these steps:

### Step 1: Create Service Layer

**File:** `features/[feature]/data/services/[feature]_service.dart`

```dart
import 'package:appwrite/appwrite.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';

class [Feature]Service {
  final Databases databases;

  [Feature]Service({required this.databases});

  // Implement CRUD operations
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await databases.listDocuments(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.[collection]CollectionId,
    );
    return response.documents.map((doc) => doc.data).toList();
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final response = await databases.getDocument(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.[collection]CollectionId,
      documentId: id,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await databases.createDocument(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.[collection]CollectionId,
      documentId: ID.unique(),
      data: data,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> data) async {
    final response = await databases.updateDocument(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.[collection]CollectionId,
      documentId: id,
      data: data,
    );
    return response.data;
  }

  Future<void> delete(String id) async {
    await databases.deleteDocument(
      databaseId: AppConfig.appwriteDatabaseId,
      collectionId: AppConfig.[collection]CollectionId,
      documentId: id,
    );
  }
}
```

### Step 2: Create Repository Interface

**File:** `features/[feature]/domain/repositories/[feature]_repository.dart`

```dart
import 'package:quran_gate_academy/core/models/[model].dart';

abstract class [Feature]Repository {
  Future<List<[Model]>> getAll();
  Future<[Model]> getById(String id);
  Future<[Model]> create([Model] model);
  Future<[Model]> update(String id, [Model] model);
  Future<void> delete(String id);
}
```

### Step 3: Create Repository Implementation

**File:** `features/[feature]/data/repositories/[feature]_repository_impl.dart`

```dart
import 'package:quran_gate_academy/core/models/[model].dart';
import 'package:quran_gate_academy/features/[feature]/data/services/[feature]_service.dart';
import 'package:quran_gate_academy/features/[feature]/domain/repositories/[feature]_repository.dart';

class [Feature]RepositoryImpl implements [Feature]Repository {
  final [Feature]Service [feature]Service;

  [Feature]RepositoryImpl({required this.[feature]Service});

  @override
  Future<List<[Model]>> getAll() async {
    try {
      final data = await [feature]Service.getAll();
      return data.map((json) => [Model].fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch [items]: $e');
    }
  }

  @override
  Future<[Model]> getById(String id) async {
    try {
      final data = await [feature]Service.getById(id);
      return [Model].fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch [item]: $e');
    }
  }

  @override
  Future<[Model]> create([Model] model) async {
    try {
      final data = await [feature]Service.create(model.toJson());
      return [Model].fromJson(data);
    } catch (e) {
      throw Exception('Failed to create [item]: $e');
    }
  }

  @override
  Future<[Model]> update(String id, [Model] model) async {
    try {
      final data = await [feature]Service.update(id, model.toJson());
      return [Model].fromJson(data);
    } catch (e) {
      throw Exception('Failed to update [item]: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await [feature]Service.delete(id);
    } catch (e) {
      throw Exception('Failed to delete [item]: $e');
    }
  }
}
```

### Step 4: Create State Classes

**File:** `features/[feature]/presentation/cubit/[feature]_state.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:quran_gate_academy/core/models/[model].dart';

abstract class [Feature]State extends Equatable {
  const [Feature]State();

  @override
  List<Object?> get props => [];
}

class [Feature]Initial extends [Feature]State {}

class [Feature]Loading extends [Feature]State {}

class [Feature]Loaded extends [Feature]State {
  final List<[Model]> items;

  const [Feature]Loaded(this.items);

  @override
  List<Object?> get props => [items];
}

class [Feature]Error extends [Feature]State {
  final String message;

  const [Feature]Error(this.message);

  @override
  List<Object?> get props => [message];
}
```

### Step 5: Create Cubit

**File:** `features/[feature]/presentation/cubit/[feature]_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/features/[feature]/domain/repositories/[feature]_repository.dart';
import 'package:quran_gate_academy/features/[feature]/presentation/cubit/[feature]_state.dart';

class [Feature]Cubit extends Cubit<[Feature]State> {
  final [Feature]Repository repository;

  [Feature]Cubit({required this.repository}) : super([Feature]Initial());

  Future<void> loadItems() async {
    emit([Feature]Loading());
    try {
      final items = await repository.getAll();
      emit([Feature]Loaded(items));
    } catch (e) {
      emit([Feature]Error(e.toString()));
    }
  }

  Future<void> createItem([Model] item) async {
    try {
      await repository.create(item);
      await loadItems();
    } catch (e) {
      emit([Feature]Error(e.toString()));
    }
  }

  Future<void> updateItem(String id, [Model] item) async {
    try {
      await repository.update(id, item);
      await loadItems();
    } catch (e) {
      emit([Feature]Error(e.toString()));
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await repository.delete(id);
      await loadItems();
    } catch (e) {
      emit([Feature]Error(e.toString()));
    }
  }
}
```

### Step 6: Create UI Page

**File:** `features/[feature]/presentation/pages/[feature]_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/features/[feature]/presentation/cubit/[feature]_cubit.dart';
import 'package:quran_gate_academy/features/[feature]/presentation/cubit/[feature]_state.dart';

class [Feature]Page extends StatelessWidget {
  const [Feature]Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<[Feature]Cubit>()..loadItems(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('[Feature]'),
        ),
        body: BlocBuilder<[Feature]Cubit, [Feature]State>(
          builder: (context, state) {
            if (state is [Feature]Loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is [Feature]Loaded) {
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ListTile(
                    title: Text(item.name),
                    // Add more UI elements
                  );
                },
              );
            } else if (state is [Feature]Error) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
```

### Step 7: Register in Dependency Injection

Add to `core/di/injection.dart`:

```dart
// Service
getIt.registerLazySingleton(() => [Feature]Service(
  databases: AppConfig.databases,
));

// Repository
getIt.registerLazySingleton<[Feature]Repository>(
  () => [Feature]RepositoryImpl([feature]Service: getIt()),
);

// Cubit
getIt.registerFactory(() => [Feature]Cubit(repository: getIt()));
```

## 🎯 Key Features Implementation Guidelines

### 1. Authentication Feature (auth/)

**Core Functionality:**
- Login with email/password
- Session management
- Role-based access (teacher/admin)
- Auto-login on app start

**Key Files:**
- `auth_service.dart` - Appwrite authentication calls
- `auth_repository.dart` - Auth interface
- `auth_cubit.dart` - Login/logout state management
- `login_page.dart` - Login UI

**Special Considerations:**
- Store user role and ID after login
- Use Appwrite Account for authentication
- Fetch user profile from Users collection after login

### 2. Dashboard Feature (dashboard/)

**Core Functionality:**
- Display teacher stats (total hours, salary, attendance)
- Show today's classes
- Quick actions

**Data Required:**
- Query class_sessions for current teacher
- Calculate metrics:
  - Total hours = sum of completed session durations
  - Salary = sum of salaryAmount for completed sessions
  - Attendance % = (completed sessions / total sessions) * 100

**UI Components:**
- Stat cards (total hours, remaining hours, salary, attendance)
- Today's classes table
- Status indicators

### 3. Schedule Feature (schedule/)

**Core Functionality:**
- Weekly calendar view
- Teacher availability management (CRUD)
- View assigned classes
- Filter by week/month

**Data Models:**
- TeacherAvailabilityModel
- ClassSessionModel

**UI Components:**
- Calendar grid (7 days × 24 hours)
- Time slot selector
- Session cards overlayed on calendar

**Implementation Tips:**
- Use `table_calendar` package for calendar
- Create time slots grid (30-minute intervals)
- Overlay sessions on availability

### 4. Students Feature (students/)

**Core Functionality:**
- List all students (admin)
- View assigned students (teacher)
- Student details and plans
- Contact information (read-only for teachers)

**Data Models:**
- StudentModel
- PlanModel

**UI Components:**
- Student list with search/filter
- Student detail cards
- Plan progress indicators

### 5. Library/Courses Feature (library/)

**Core Functionality:**
- Browse available courses
- View course details
- Course categorization

**Data Models:**
- CourseModel

**UI Components:**
- Course cards with cover images
- Category filters
- Course detail view

### 6. Tasks Feature (tasks/)

**Core Functionality:**
- Task management (CRUD)
- Status tracking (pending, in progress, completed, overdue)
- Priority levels
- Assignment to users

**Data Models:**
- TaskModel

**UI Components:**
- Task list grouped by status
- Task cards with priority indicators
- Create/edit task forms

### 7. Class Sessions Feature

**Core Functionality:**
- View assigned sessions
- Update session status (scheduled → completed/absent/cancelled)
- Add session notes
- Reschedule requests

**Workflow:**
- Teachers can only mark status after session end time
- Status changes trigger salary recalculation
- Completed sessions contribute to teacher salary

### 8. Reschedule Feature

**Core Functionality:**
- Teachers request reschedule with new date/time
- Admins approve/reject requests
- Approved requests update session date

**Workflow:**
1. Teacher selects session and requests reschedule
2. System creates RescheduleRequest document
3. Admin reviews and approves/rejects
4. If approved, ClassSession is updated

### 9. Salary Calculation

**Automatic Calculation:**
```dart
Future<double> calculateTeacherSalary(String teacherId, DateTime month) async {
  // Query completed sessions for the teacher in the given month
  final sessions = await getCompletedSessionsForMonth(teacherId, month);

  // Sum up salary amounts
  double totalSalary = 0;
  for (var session in sessions) {
    totalSalary += session.salaryAmount;
  }

  return totalSalary;
}
```

**Salary Amount Calculation Per Session:**
```dart
double calculateSessionSalary(double hourlyRate, int durationMinutes) {
  final hours = durationMinutes / 60.0;
  return hourlyRate * hours;
}
```

## 🎨 UI Components Library

### Shared Widgets (`core/widgets/`)

#### 1. AppSidebar

Responsive sidebar with navigation menu matching the screenshot design.

```dart
class AppSidebar extends StatelessWidget {
  final String currentRoute;

  // Menu items with icons and routes
  // Active state styling
  // Role-based menu visibility
}
```

#### 2. StatCard

Dashboard metric card displaying key statistics.

```dart
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color color;
  final IconData icon;
}
```

#### 3. SessionCard

Card displaying class session information.

```dart
class SessionCard extends StatelessWidget {
  final ClassSessionModel session;
  final VoidCallback? onTap;
  final VoidCallback? onStatusChange;

  // Display: time, student name, course, duration, status badge
}
```

#### 4. StudentCard

Card for student list items.

```dart
class StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback? onTap;

  // Display: name, country, course, action buttons
}
```

## 🔐 Security & Permissions

### Appwrite Permissions Setup

```javascript
// In setup.js, for each collection:
[
  Permission.read(Role.any()),           // Everyone can read
  Permission.create(Role.users()),       // Authenticated users can create
  Permission.update(Role.users()),       // Authenticated users can update
  Permission.delete(Role.users()),       // Authenticated users can delete
]
```

### Role-Based Access Control in Flutter

```dart
// Check user role before showing features
if (currentUser.role == 'admin') {
  // Show admin features
} else {
  // Show teacher features
}
```

### Query Filters

Teachers should only see their own data:

```dart
final sessions = await databases.listDocuments(
  databaseId: AppConfig.appwriteDatabaseId,
  collectionId: AppConfig.classSessionsCollectionId,
  queries: [
    Query.equal('teacherId', currentUserId),
    Query.greaterThan('scheduledDate', today),
  ],
);
```

## 🧪 Testing Recommendations

### Unit Tests
- Test Cubits with mock repositories
- Test repository implementations with mock services
- Test calculation functions (salary, hours, etc.)

### Integration Tests
- Test full feature flows
- Test navigation between pages
- Test state management across app

### Widget Tests
- Test UI components render correctly
- Test user interactions
- Test responsive layouts

## 📱 Responsive Design

### Breakpoints

```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}
```

### Responsive Layout

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < Breakpoints.mobile) {
      return MobileLayout();
    } else if (constraints.maxWidth < Breakpoints.tablet) {
      return TabletLayout();
    } else {
      return DesktopLayout();
    }
  },
)
```

## 🚀 Deployment Checklist

- [ ] Set production Appwrite endpoint
- [ ] Configure environment variables
- [ ] Test all features with production data
- [ ] Set up proper error logging
- [ ] Configure app permissions (if using camera, storage, etc.)
- [ ] Test on multiple devices and screen sizes
- [ ] Optimize images and assets
- [ ] Enable code obfuscation
- [ ] Set up CI/CD pipeline

## 📊 Analytics & Monitoring

Consider integrating:
- Error tracking (Sentry, Firebase Crashlytics)
- Usage analytics
- Performance monitoring

## 🎓 Best Practices

1. **Always use models** - Never pass raw JSON to UI
2. **Handle errors gracefully** - Show user-friendly messages
3. **Add loading states** - Provide feedback during async operations
4. **Validate input** - Both client and server-side
5. **Keep UI logic in Cubits** - Not in widgets
6. **Use constants** - For colors, strings, routes
7. **Comment complex logic** - Help future developers
8. **Follow Dart style guide** - Consistent formatting

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Appwrite Documentation](https://appwrite.io/docs)
- [flutter_bloc Package](https://bloclibrary.dev/)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

**Next Steps:**
1. Run the Appwrite setup script
2. Implement authentication feature first (reference implementation provided)
3. Follow the template to implement remaining features
4. Test thoroughly
5. Deploy to production

For questions or issues, refer to the README.md file or create an issue in the repository.
