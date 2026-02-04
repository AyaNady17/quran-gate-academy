# Quran Gate Academy - Appwrite Setup

This directory contains the automated setup script for configuring the Appwrite backend for Quran Gate Academy.

## Prerequisites

- Node.js (v14 or higher)
- Appwrite server instance running (either Cloud or Self-hosted)
- Appwrite project created
- API key with full permissions

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment Variables

Copy the `.env.example` file to `.env`:

```bash
cp .env.example .env
```

Edit `.env` and fill in your Appwrite credentials:

```env
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your-project-id
APPWRITE_API_KEY=your-api-key
```

### 3. Run Setup Script

```bash
npm run setup
```

## What the Script Does

The setup script automatically creates:

### Database
- **Database Name**: Quran Gate Academy Database
- **Database ID**: `quran_gate_db`

### Collections

1. **Users** (`users`)
   - Stores teacher and admin accounts
   - Fields: userId, email, fullName, role, phone, hourlyRate, profilePicture, status, specialization
   - Indexes: userId, email, role

2. **Students** (`students`)
   - Stores student information
   - Fields: fullName, email, phone, whatsapp, country, timezone, profilePicture, status, notes
   - Indexes: fullName (fulltext), country

3. **Courses** (`courses`)
   - Stores available courses
   - Fields: title, description, category, coverImage, level, estimatedHours, status
   - Indexes: title (fulltext), category

4. **Plans** (`plans`)
   - Student subscription plans
   - Fields: studentId, courseId, planName, totalSessions, completedSessions, sessionDuration, totalPrice, status
   - Indexes: studentId, courseId, status

5. **Class Sessions** (`class_sessions`)
   - Individual class sessions
   - Fields: teacherId, studentId, courseId, scheduledDate, scheduledTime, duration, status, attendanceStatus, salaryAmount
   - Indexes: teacherId, studentId, courseId, status, scheduledDate

6. **Teacher Availability** (`teacher_availability`)
   - Teacher weekly availability slots
   - Fields: teacherId, dayOfWeek, startTime, endTime, isAvailable, timezone
   - Indexes: teacherId, dayOfWeek

7. **Reschedule Requests** (`reschedule_requests`)
   - Session reschedule requests
   - Fields: sessionId, requestedBy, originalDate, newDate, reason, status, reviewedBy
   - Indexes: sessionId, status

8. **Salary Records** (`salary_records`)
   - Monthly salary calculations
   - Fields: teacherId, month, year, totalHours, totalAmount, fines, bonuses, netAmount, status
   - Indexes: teacherId, month/year

9. **Tasks** (`tasks`)
   - Task management
   - Fields: title, description, assignedTo, createdBy, status, priority, dueDate, relatedEntity
   - Indexes: assignedTo, status, dueDate

## Permissions

All collections are configured with:
- Read: Any authenticated user
- Create: Authenticated users
- Update: Authenticated users
- Delete: Authenticated users

Note: In production, you should fine-tune permissions based on specific roles (admin, teacher).

## Troubleshooting

### Error: Collection already exists
This is normal if you run the script multiple times. The script will skip existing collections.

### Error: Invalid API key
Make sure your API key has the required permissions to create databases and collections.

### Error: Network timeout
Check your Appwrite endpoint URL and ensure the server is accessible.

## Next Steps

After running this setup:

1. Configure your Flutter app with the same Appwrite credentials
2. Create your first admin user through Appwrite Console
3. Start using the Quran Gate Academy application

## Support

For issues or questions, please contact the development team.
# quran-gate-academy
