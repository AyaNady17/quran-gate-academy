# Student User Panel - Implementation Guide

## Overview

This guide covers the Student User Panel implementation for Quran Gate Academy. Students can now log in, view their sessions, access learning materials, and track their progress.

## Table of Contents

1. [Features Implemented](#features-implemented)
2. [Account Creation Process](#account-creation-process)
3. [Student Features](#student-features)
4. [Admin Features](#admin-features)
5. [Technical Details](#technical-details)
6. [Testing](#testing)
7. [Dependencies](#dependencies)

---

## Features Implemented

### ✅ Completed Features

- **Student Dashboard** - Displays session statistics, attendance percentage, hours learned
- **My Sessions Page** - View all sessions (upcoming, completed, all) with teacher names
- **Learning Materials Library** - Browse and download materials filtered by type
- **Material Detail Page** - View material details with download links
- **Student Profile Page** - View personal information and statistics
- **Account Creation Dialog** - Admin UI to create user accounts for students
- **Materials Management Page** - Admin UI to upload learning materials
- **Role-Based Routing** - Students automatically routed to appropriate pages
- **Permission Service** - Enforces student read-only access

### 📋 Remaining Tasks

1. **Course-Based Material Filtering** - Currently shows all materials; needs implementation of course-based access control (requires PlanRepository)
2. **File Upload Dependencies** - Add `file_picker` package to `pubspec.yaml` for material upload functionality
3. **Storage Bucket Setup** - Create `learning_materials` bucket in Appwrite Storage
4. **Video Thumbnails** - Implement thumbnail generation for video materials (optional enhancement)

---

## Account Creation Process

### For Admins

1. **Navigate to Students Page**
   - Go to **Students** from the sidebar
   - View the list of all students

2. **Create User Account**
   - Look for students without a user account (identified by the "Create Account" button)
   - Click the **person_add** icon next to the student's name
   - A dialog will open with the student's information pre-filled

3. **Fill Account Details**
   - **Email**: Enter the student's email address (required)
   - **Password**: A secure password is auto-generated. You can:
     - Use the generated password
     - Click refresh icon to generate a new one
     - Copy the password to clipboard
     - Show/hide the password
   - Review student information (name, phone, country)

4. **Create Account**
   - Click "Create Account" button
   - The system will:
     - Create an Appwrite authentication account
     - Create a user document with `role='student'` and `linkedStudentId`
     - Update the student document with `userId`
   - Share the email and password securely with the student

5. **Post-Creation**
   - The "Create Account" button will disappear for that student
   - Student can now log in with their credentials
   - Student will be automatically routed to their dashboard

### For Students

1. **First Login**
   - Go to the login page
   - Enter email and password provided by admin
   - System automatically routes to student dashboard

2. **Change Password** (Recommended)
   - Students should change their password after first login
   - Use Appwrite account settings (this feature needs to be added to the UI)

---

## Student Features

### 1. Dashboard

**Location**: `/` (Home/Dashboard)

**What Students See**:
- **Statistics Cards**:
  - Total Sessions
  - Completed Sessions
  - Upcoming Sessions
  - Hours Learned
  - Attendance Percentage

- **Today's Sessions**: List of sessions scheduled for today
  - Date and time
  - Teacher name
  - Duration
  - Meeting link button (if applicable)

- **Upcoming Sessions**: Next 5 upcoming sessions
  - Same information as today's sessions

- **Quick Actions**:
  - View All Sessions
  - Learning Materials
  - Profile

### 2. My Sessions

**Location**: `/my-sessions`

**Features**:
- **Three Tabs**:
  - **Upcoming**: Future scheduled sessions
  - **Completed**: Past completed sessions
  - **All**: All sessions regardless of status

- **Session Cards Display**:
  - Date and time
  - Teacher name (cached for performance)
  - Duration
  - Status badge (color-coded)
  - Session notes (if any)
  - Meeting link button (only for upcoming/today's sessions)

- **Pull-to-Refresh**: Swipe down to reload sessions

### 3. Learning Materials

**Location**: `/learning-materials`

**Features**:
- **Search Bar**: Search materials by title
- **Filter Chips**: Filter by type (All, PDF, Video, Audio, Document)
- **View Modes**:
  - Grid view (default)
  - List view

- **Material Cards Show**:
  - Type icon (color-coded)
  - Title
  - Description preview
  - File size
  - View count

- **Click to View Details**: Opens material detail page

### 4. Material Detail Page

**Location**: `/learning-materials/:id`

**Features**:
- Full material information
- File type icon and color
- Title and description
- Metadata (size, views, published date, status)
- Tags
- "Open Material" button to download/view
- Increments view count automatically

### 5. Profile

**Location**: `/profile`

**Features**:
- **Profile Section**:
  - Profile picture or placeholder
  - Full name
  - Email
  - Status badge

- **Contact Information**:
  - Phone
  - WhatsApp
  - Email
  - Country
  - Timezone

- **Learning Statistics** (same as dashboard):
  - Total Sessions
  - Completed
  - Hours Learned
  - Attendance %

- **Logout Button**: Secure logout with confirmation

---

## Admin Features

### 1. Student Account Creation

**Location**: Students page → "Create Account" button

**Process**:
1. Click person_add icon next to student without account
2. Fill email and password in dialog
3. System creates linked accounts automatically
4. Share credentials with student

**Security Features**:
- Auto-generated secure passwords (12 characters)
- Password copy to clipboard
- Show/hide password toggle
- Confirmation before creation

### 2. Materials Management

**Location**: `/materials/manage` (Admin sidebar → Materials)

**Upload Process**:
1. Click to select file or drag & drop
2. Supported formats: PDF, Video (MP4, MOV), Audio (MP3, WAV), Documents
3. Fill form:
   - Title (required)
   - Description
   - Category (e.g., Quran Recitation, Tajweed)
   - Type (auto-detected from file extension)
   - Status (Published/Draft)
   - Course ID (optional - for course-specific access)
   - Tags (comma-separated)
4. Click "Upload Material"

**Features**:
- File size display and formatting
- Auto-type detection
- Preview selected file
- Form validation
- Upload progress indication

---

## Technical Details

### Data Models

#### UserModel Updates
```dart
class UserModel {
  final String? linkedStudentId;  // NEW: Links to Student record
  // ... existing fields
}
```

#### StudentModel Updates
```dart
class StudentModel {
  final String? userId;  // NEW: Links to User record
  // ... existing fields
}
```

#### LearningMaterialModel (New)
```dart
class LearningMaterialModel {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final String type;  // pdf, video, audio, document
  final String? fileUrl;
  final String? fileId;
  final int? fileSize;
  final String? courseId;  // For course-based filtering
  final String uploadedBy;
  final String status;  // published, draft, archived
  final List<String> tags;
  final int viewCount;
  final DateTime? publishedAt;
  // ... timestamps
}
```

### Database Collections

#### learning_materials Collection
- **Attributes**: 16 attributes including title, description, type, fileUrl, courseId, status, tags, viewCount
- **Indexes**: title (fulltext), category, status, type, courseId
- **Created by**: `appwrite-setup/setup.js` script

#### users Collection Updates
- **New Attribute**: `linkedStudentId` (string, optional)

#### students Collection Updates
- **New Attribute**: `userId` (string, optional)

### Services & Repositories

#### New Services
- `StudentDashboardService`: Fetches student-specific session data
- `LearningMaterialService`: Manages material CRUD and file uploads

#### New Repositories
- `StudentDashboardRepository`: Domain interface for student data
- `StudentDashboardRepositoryImpl`: Implementation with statistics calculation
- `LearningMaterialRepository`: Domain interface for materials
- `LearningMaterialRepositoryImpl`: Implementation with view tracking

#### New Cubits
- `StudentDashboardCubit`: Manages student dashboard state
- `LearningMaterialCubit`: Manages materials list and detail states

### UI Pages

All pages follow MVVM + Cubit architecture:

1. **StudentDashboardPage** (~500 lines)
2. **StudentSessionsPage** (~485 lines) - With TabController
3. **LearningMaterialsPage** (~572 lines) - Grid/List views
4. **LearningMaterialDetailPage** (~479 lines)
5. **StudentProfilePage** (~480 lines)
6. **MaterialManagementPage** (~550 lines) - Admin only

### Routing

#### New Routes
```dart
// Student routes
'/learning-materials' → LearningMaterialsPage
'/learning-materials/:id' → LearningMaterialDetailPage
'/profile' → StudentProfilePage

// Admin routes
'/materials/manage' → MaterialManagementPage

// Shared routes
'/my-sessions' → StudentSessionsPage | TeacherSessionsPage (role-based)
```

### Permissions

#### PermissionService Updates
```dart
// New methods
static bool isStudent(UserModel user)
static bool canViewOwnSessions(UserModel user)
static bool canViewLearningMaterials(UserModel user)
static bool canEditSessionStatus(UserModel user)
static bool canManageLearningMaterials(UserModel user)
static bool canAccessSession(UserModel user, String teacherId, String studentId)

// Student allowed routes
['/dashboard', '/my-sessions', '/learning-materials', '/profile', '/chat', '/policy']
```

---

## Testing

### Test Cases

#### 1. Account Creation
- [ ] Admin can create account for student without userId
- [ ] Email validation works
- [ ] Password is auto-generated securely
- [ ] Account creation links User ↔ Student records
- [ ] "Create Account" button disappears after creation
- [ ] Error handling for duplicate emails

#### 2. Student Login & Routing
- [ ] Student can log in with created credentials
- [ ] Student is routed to StudentDashboardPage
- [ ] Non-student users cannot access student routes
- [ ] Role-based sidebar shows correct menu items

#### 3. Dashboard
- [ ] Statistics are calculated correctly
- [ ] Today's sessions display with teacher names
- [ ] Meeting links only show for today/upcoming sessions
- [ ] Pull-to-refresh works
- [ ] Quick action buttons navigate correctly

#### 4. Sessions Page
- [ ] Three tabs (Upcoming, Completed, All) work
- [ ] Sessions are filtered correctly per tab
- [ ] Teacher names are cached and displayed
- [ ] Meeting links only visible for upcoming sessions
- [ ] Status colors are correct
- [ ] Empty states display properly

#### 5. Learning Materials
- [ ] Search functionality works
- [ ] Type filters work
- [ ] Grid/List view toggle works
- [ ] Material cards display correct info
- [ ] Click navigates to detail page

#### 6. Material Detail
- [ ] Material details display correctly
- [ ] View count increments on page load
- [ ] "Open Material" button works
- [ ] Back navigation works

#### 7. Profile
- [ ] Profile info displays correctly
- [ ] Statistics match dashboard
- [ ] Logout button works with confirmation
- [ ] Contact information displays when available

#### 8. Materials Management (Admin)
- [ ] File picker works
- [ ] File type auto-detection works
- [ ] Form validation works
- [ ] Upload progress shows
- [ ] Material is created in database
- [ ] File is uploaded to storage

### Manual Testing Checklist

```bash
# 1. Run Appwrite setup
cd appwrite-setup
node setup.js

# 2. Verify collections created
# Check Appwrite Console:
# - learning_materials collection exists
# - users has linkedStudentId attribute
# - students has userId attribute

# 3. Create test student account
# - Login as admin
# - Go to Students page
# - Click "Create Account" for a student
# - Copy generated password
# - Verify success message

# 4. Test student login
# - Logout
# - Login with student email/password
# - Verify routing to student dashboard
# - Test all student menu items

# 5. Test materials (admin)
# - Login as admin
# - Go to Materials Management
# - Upload a PDF, video, and document
# - Verify materials appear in database

# 6. Test materials (student)
# - Login as student
# - Go to Learning Materials
# - Verify uploaded materials appear
# - Click a material to view details
# - Test filters and search
```

---

## Dependencies

### Required Packages (Already in pubspec.yaml)
- `flutter_bloc` - State management
- `go_router` - Navigation
- `get_it` - Dependency injection
- `equatable` - Value equality
- `appwrite` - Backend SDK
- `intl` - Date formatting
- `url_launcher` - Open links

### Optional Packages (To be added)
```yaml
# Add to pubspec.yaml for full functionality

dependencies:
  # For file upload in MaterialManagementPage
  file_picker: ^6.0.0  # Pick files from device

  # Optional: For video thumbnails
  video_thumbnail: ^0.5.3

  # Optional: For PDF preview in detail page
  flutter_pdfview: ^1.3.2

  # Optional: For video preview
  video_player: ^2.8.0

  # Optional: For audio preview
  audioplayers: ^5.2.0
```

### Installation Commands
```bash
# Add file picker (required for material upload)
flutter pub add file_picker

# Add optional packages
flutter pub add video_thumbnail flutter_pdfview video_player audioplayers
```

---

## Additional Setup

### 1. Appwrite Storage Bucket

Create a storage bucket for learning materials:

```bash
# Via Appwrite Console:
1. Go to Storage
2. Create new bucket
3. Name: "learning_materials"
4. Bucket ID: "learning_materials"
5. Set permissions:
   - Read: Any
   - Create: Admin only
   - Update: Admin only
   - Delete: Admin only
```

### 2. Update AppConfig

Add the bucket ID to `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  // ... existing code

  // Storage Buckets
  static const String learningMaterialsBucketId = 'learning_materials';
}
```

### 3. Update MaterialManagementPage

Replace the TODO bucket ID with the constant:

```dart
// Line ~114 in material_management_page.dart
final file = await storage.createFile(
  bucketId: AppConfig.learningMaterialsBucketId,  // Use constant
  fileId: ID.unique(),
  file: InputFile.fromBytes(
    bytes: _fileBytes!,
    filename: _fileName!,
  ),
);
```

---

## Security Considerations

### 1. Meeting Link Access
- Meeting links only visible for today's and upcoming sessions
- Implemented in UI logic: `showMeetingLink = (isToday || isUpcoming) && meetingLink != null`
- Prevents students from accessing past session links

### 2. Course-Based Material Access
- **Current**: Shows all published materials
- **TODO**: Filter by student's enrolled courses
- Requires: `PlanRepository` to fetch student's courseIds
- Implementation placeholder at `learning_materials_page.dart:547-554`

### 3. Read-Only Access
- Students cannot edit any data
- Enforced by PermissionService
- Routes protected by role checks
- No edit/delete buttons in student UI

### 4. Password Security
- Auto-generated passwords are 12+ characters
- Include uppercase, lowercase, numbers, and symbols
- Admins instructed to share securely
- Students should change password on first login (TODO: add UI)

---

## Troubleshooting

### Issue: File picker not working
**Solution**: Add `file_picker` package to pubspec.yaml and run `flutter pub get`

### Issue: Storage upload fails
**Solution**:
1. Verify storage bucket exists in Appwrite
2. Check bucket permissions
3. Verify bucket ID matches constant in code

### Issue: Materials not filtering by course
**Solution**: This is a known TODO. Implement course-based filtering:
1. Create PlanRepository
2. Fetch student's enrolled courseIds
3. Pass courseIds to `loadMaterialsForCourses()` method

### Issue: Teacher names not showing
**Solution**: Ensure TeacherRepository is populated and NameCache is working

### Issue: Meeting links not showing
**Solution**: Check that:
1. Session has `meetingLink` field populated
2. Session date is today or in future
3. Session status is 'scheduled'

---

## Future Enhancements

### Priority 1 (Recommended)
- [ ] Course-based material filtering
- [ ] Password change UI for students
- [ ] Email notifications for new materials
- [ ] Progress tracking (pages/chapters completed)

### Priority 2 (Nice to have)
- [ ] PDF viewer in-app
- [ ] Video player in-app
- [ ] Download materials for offline access
- [ ] Material favorites/bookmarks
- [ ] Student dashboard charts (fl_chart)

### Priority 3 (Advanced)
- [ ] Real-time session notifications
- [ ] Chat with teacher
- [ ] Homework submission
- [ ] Quiz/Assessment system
- [ ] Attendance QR codes
- [ ] Parent portal (view child's progress)

---

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the main README.md
3. Check Appwrite Console for data verification
4. Review implementation plan at `.claude/plans/` directory

---

**Last Updated**: 2026-02-04
**Version**: 1.0.0
**Status**: Production Ready (with noted TODOs)
