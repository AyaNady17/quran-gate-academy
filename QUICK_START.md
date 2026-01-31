# Quran Gate Academy - Quick Start Guide

Get your Quran Gate Academy system up and running in under 10 minutes!

## 🚀 Prerequisites Checklist

Before starting, make sure you have:

- [ ] Flutter SDK (3.0+) installed - [Get Flutter](https://flutter.dev/docs/get-started/install)
- [ ] Node.js (14+) installed - [Get Node.js](https://nodejs.org/)
- [ ] Appwrite account - [Create Free Account](https://cloud.appwrite.io/)
- [ ] Git installed
- [ ] Code editor (VS Code recommended)

## 📋 5-Minute Setup

### Step 1: Clone and Install (1 min)

```bash
# Clone the repository
git clone https://github.com/yourusername/quran-gate-academy.git
cd quran-gate-academy
```

### Step 2: Set Up Appwrite Backend (2 min)

```bash
# Navigate to appwrite setup
cd appwrite-setup

# Install dependencies
npm install

# Copy environment file
cp .env.example .env
```

**Edit `.env` file with your Appwrite credentials:**

```env
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your-project-id-here
APPWRITE_API_KEY=your-api-key-here
```

**Get these values:**
1. Go to [Appwrite Cloud](https://cloud.appwrite.io/)
2. Create a new project
3. Copy Project ID from settings
4. Create API Key with full permissions
5. Paste values into `.env`

**Run the setup script:**
```bash
npm run setup
```

You should see:
```
✅ Database created successfully
✅ Users collection created
✅ Students collection created
... (9 collections total)
🎉 Your Quran Gate Academy backend is ready!
```

### Step 3: Configure Flutter App (1 min)

```bash
# Navigate to Flutter app
cd ../flutter_app

# Install dependencies
flutter pub get
```

**Edit `lib/core/config/app_config.dart`:**

```dart
class AppConfig {
  static const String appwriteEndpoint = 'https://cloud.appwrite.io/v1';
  static const String appwriteProjectId = 'your-project-id'; // ← Change this
  static const String appwriteDatabaseId = 'quran_gate_db';
  // ... rest stays the same
}
```

### Step 4: Create First Admin User (1 min)

1. Go to [Appwrite Console](https://cloud.appwrite.io/)
2. Navigate to: **Auth** → **Users**
3. Click **"Add User"**
4. Create user:
   - Email: `admin@example.com`
   - Password: `password123` (change this!)
   - Name: `Admin User`
5. **Copy the User ID** (it looks like: `5f8a7c2b3d9e1`)

6. Navigate to: **Databases** → **quran_gate_db** → **users** collection
7. Click **"Add Document"**
8. Fill in:
   ```json
   {
     "userId": "paste-the-user-id-here",
     "email": "admin@example.com",
     "fullName": "Admin User",
     "role": "admin",
     "hourlyRate": 0,
     "status": "active",
     "createdAt": "2024-01-01T00:00:00.000Z"
   }
   ```
9. Click **"Create"**

### Step 5: Run the App! (< 1 min)

```bash
# Run on web
flutter run -d chrome

# OR run on your device
flutter run
```

## 🎉 Success! You should see:

1. **Login Page** - Clean, professional design
2. Enter credentials:
   - Email: `admin@example.com`
   - Password: `password123`
3. Click **"Login"**
4. **Dashboard** - You'll see the dashboard UI!

---

## 🎨 What You'll See

### Login Page
- Professional login form
- Email and password validation
- Loading states
- Error handling

### Dashboard
- Stat cards showing metrics (currently with sample data)
- Salary information
- Today's classes table
- Professional sidebar navigation

### Navigation
- Home (Dashboard)
- Chat (placeholder)
- Schedule (placeholder)
- Students (placeholder)
- Library (placeholder)
- Tasks (placeholder)
- Policy (placeholder)
- Log Out (placeholder)

---

## 🔍 Troubleshooting

### "Appwrite endpoint unreachable"
**Solution:** Check your internet connection and verify the endpoint URL

### "Invalid credentials"
**Solution:**
1. Make sure user exists in Appwrite Auth
2. Make sure user profile exists in users collection
3. Verify userId matches between Auth and users collection

### "Database not found"
**Solution:** Re-run the setup script:
```bash
cd appwrite-setup
npm run setup
```

### Flutter build errors
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### "Package not found" errors
**Solution:** Make sure you ran `flutter pub get` in the flutter_app directory

---

## 📱 Next Steps

Now that your system is running, you can:

### 1. Explore the UI
- Navigate through all pages
- Check out the dashboard design
- Explore the sidebar menu

### 2. Implement Features
Open [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) and follow the step-by-step guide to implement:
- Dashboard data fetching
- Schedule management
- Student management
- And more...

### 3. Customize
- Change colors in `lib/core/theme/app_theme.dart`
- Modify layout in respective page files
- Add your logo/branding

### 4. Add Data
Go to Appwrite Console and manually add:
- More users (teachers)
- Students
- Courses
- Plans
- Class sessions

---

## 🎯 What Works Right Now

✅ **Authentication**
- Login/logout
- Session management
- User profile fetching

✅ **UI/UX**
- Complete dashboard UI
- Responsive sidebar
- Professional theme
- Stat cards
- All navigation pages

✅ **Architecture**
- Clean architecture
- MVVM pattern
- State management
- Dependency injection
- Routing

## 🚧 What Needs Implementation

The architecture and UI are ready. You need to implement:

1. **Dashboard Logic** (3 hours)
   - Fetch real session data
   - Calculate statistics
   - Display teacher metrics

2. **Schedule Feature** (10 hours)
   - Calendar view
   - Availability management
   - Session display

3. **Students Feature** (7 hours)
   - Student list
   - Detail view
   - CRUD operations

4. **Other Features** (20-30 hours)
   - Library, Tasks, Reschedule workflow, etc.

**Total remaining:** ~50 hours of development

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Complete project documentation (50+ pages) |
| [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) | Step-by-step feature implementation |
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | What's done, what's pending |
| [QUICK_START.md](QUICK_START.md) | This file - get started fast |

---

## 🎓 Learning Resources

### Learn the Stack
- [Flutter Basics](https://flutter.dev/docs/get-started/codelab)
- [Appwrite Basics](https://appwrite.io/docs)
- [Bloc/Cubit Tutorial](https://bloclibrary.dev/#/coreconcepts)

### Understand the Architecture
1. Read [README.md](README.md) - Architecture section
2. Study the auth feature code - Complete reference
3. Follow [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) templates

---

## 💡 Pro Tips

### Development Tips
1. **Hot Reload** - Press `r` in terminal while app is running
2. **Restart App** - Press `R` for full restart
3. **DevTools** - Press `v` to open Flutter DevTools

### Code Tips
1. Use auth feature as your reference for all features
2. Follow the implementation guide templates exactly
3. Test each layer as you build (Service → Repository → Cubit → UI)

### Debugging Tips
1. Check Appwrite Console for data issues
2. Use `print()` statements or debugger
3. Read error messages carefully - they're usually helpful

---

## 🆘 Getting Help

### If You Get Stuck

1. **Check Documentation**
   - README.md for setup issues
   - IMPLEMENTATION_GUIDE.md for code questions
   - PROJECT_SUMMARY.md for feature status

2. **Check Example Code**
   - Auth feature is a complete reference
   - Dashboard UI shows layout patterns
   - Sidebar shows navigation patterns

3. **Check Appwrite Console**
   - Verify data exists
   - Check permissions
   - Test queries

4. **Common Issues**
   - Most issues are configuration (Project ID, API keys)
   - Check user profile exists in both Auth and users collection
   - Verify internet connection for Appwrite calls

---

## ✅ Verification Checklist

Make sure everything works:

- [ ] Appwrite backend setup completed successfully
- [ ] Flutter app runs without errors
- [ ] Can see login page
- [ ] Can login with admin credentials
- [ ] Dashboard displays after login
- [ ] Can navigate between pages via sidebar
- [ ] All pages load without errors

If all checked, **you're ready to start developing!** 🎉

---

## 🚀 Ready to Build?

You now have:
- ✅ Backend configured with 9 collections
- ✅ Flutter app running
- ✅ Authentication working
- ✅ Professional UI displayed
- ✅ Clean architecture in place

**Next:** Open [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) and start implementing features!

---

**Need help? Create an issue or check the documentation.**

**Happy coding! 🎉**
