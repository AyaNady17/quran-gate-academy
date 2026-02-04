#!/usr/bin/env node

const sdk = require('node-appwrite');

// Configuration
const config = {
  endpoint: process.env.APPWRITE_ENDPOINT || 'https://fra.cloud.appwrite.io/v1',
  projectId: process.env.APPWRITE_PROJECT_ID || '697cff53000c636e00c8',
  apiKey: process.env.APPWRITE_API_KEY || 'standard_a47c328bd5cd3c598ff69e965c96db16befdf903292009e698b0d27e9a8fbaa22566440e54d103ce20746ccf5bf43e0057e118dd29ee9a3216aee2767896a22cff5418a6f640d8b5774317afb3cf09d86b7bc3f1972fe69c955a1a62ce635bce23ba69aabea3ee3d58abdff95c68a9e7efe175b9a8012a35474f2a2196024561', // Set via environment variable
  databaseId: 'quran_gate_db', // Must exist already
};

// Initialize Appwrite client
const client = new sdk.Client()
  .setEndpoint(config.endpoint)
  .setProject(config.projectId)
  .setKey(config.apiKey);

const databases = new sdk.Databases(client);
const users = new sdk.Users(client);
const storage = new sdk.Storage(client);

// Admin credentials
const ADMIN_CREDENTIALS = {
  email: 'admin@qurangateacademy.com',
  password: 'Admin@123456',
  name: 'Admin User',
};

const COLLECTIONS = {
  USERS: 'users',
  STUDENTS: 'students',
  COURSES: 'courses',
  PLANS: 'plans',
  CLASS_SESSIONS: 'class_sessions',
  TEACHER_AVAILABILITY: 'teacher_availability',
  RESCHEDULE_REQUESTS: 'reschedule_requests',
  SALARY_RECORDS: 'salary_records',
  TASKS: 'tasks',
  LEARNING_MATERIALS: 'learning_materials',
};

// Delay helper
const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Handle collection errors
function handleCollectionError(name, error) {
  if (error.code === 409) {
    console.log(`ℹ️  ${name} collection already exists, skipping...`);
  } else {
    console.error(`❌ Error creating ${name} collection:`, error.message);
    throw error;
  }
}

// -------------------- COLLECTIONS --------------------

// Users Collection
async function createUsersCollection() {
  console.log('\n👤 Creating Users collection...');
  try {
    await databases.createCollection(config.databaseId, COLLECTIONS.USERS, 'Users', [
      sdk.Permission.read(sdk.Role.any()),
      sdk.Permission.create(sdk.Role.users()),
      sdk.Permission.update(sdk.Role.users()),
      sdk.Permission.delete(sdk.Role.users()),
    ]);

    await delay(2000);

    await databases.createStringAttribute(config.databaseId, COLLECTIONS.USERS, 'userId', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.USERS, 'email', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.USERS, 'fullName', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.USERS, 'role', 50, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.USERS, 'phone', 50, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.USERS, 'linkedStudentId', 255, false);
    await databases.createFloatAttribute(config.databaseId, COLLECTIONS.USERS, 'hourlyRate', false, 0, 10000, 0);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.USERS, 'profilePicture', 500, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.USERS, 'status', 50, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.USERS, 'specialization', 500, false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.USERS, 'createdAt', true);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.USERS, 'updatedAt', false);

    await delay(3000); // Wait for attributes to be ready

    await databases.createIndex(config.databaseId, COLLECTIONS.USERS, 'userId_index', 'key', ['userId'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.USERS, 'email_index', 'key', ['email'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.USERS, 'role_index', 'key', ['role'], ['asc']);

    console.log('✅ Users collection created');
  } catch (error) {
    handleCollectionError('Users', error);
  }
}

// Students Collection
async function createStudentsCollection() {
  console.log('\n👨‍🎓 Creating Students collection...');
  try {
    await databases.createCollection(config.databaseId, COLLECTIONS.STUDENTS, 'Students', [
      sdk.Permission.read(sdk.Role.any()),
      sdk.Permission.create(sdk.Role.users()),
      sdk.Permission.update(sdk.Role.users()),
      sdk.Permission.delete(sdk.Role.users()),
    ]);

    await delay(2000);

    await databases.createStringAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'fullName', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'userId', 255, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'email', 255, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'phone', 50, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'whatsapp', 50, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'country', 100, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'countryCode', 10, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'timezone', 100, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'profilePicture', 500, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'status', 50, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'notes', 2000, false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'createdAt', true);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.STUDENTS, 'updatedAt', false);

    await delay(3000); // Wait for attributes to be ready

    await databases.createIndex(config.databaseId, COLLECTIONS.STUDENTS, 'fullName_index', 'fulltext', ['fullName'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.STUDENTS, 'country_index', 'key', ['country'], ['asc']);

    console.log('✅ Students collection created');
  } catch (error) {
    handleCollectionError('Students', error);
  }
}

// Courses Collection
async function createCoursesCollection() {
  console.log('\n📚 Creating Courses collection...');
  try {
    await databases.createCollection(config.databaseId, COLLECTIONS.COURSES, 'Courses', [
      sdk.Permission.read(sdk.Role.any()),
      sdk.Permission.create(sdk.Role.users()),
      sdk.Permission.update(sdk.Role.users()),
      sdk.Permission.delete(sdk.Role.users()),
    ]);
    await delay(2000);

    await databases.createStringAttribute(config.databaseId, COLLECTIONS.COURSES, 'title', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.COURSES, 'description', 2000, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.COURSES, 'category', 100, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.COURSES, 'coverImage', 500, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.COURSES, 'level', 50, false);
    await databases.createIntegerAttribute(config.databaseId, COLLECTIONS.COURSES, 'estimatedHours', false, 0, 1000, 0);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.COURSES, 'status', 50, false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.COURSES, 'createdAt', true);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.COURSES, 'updatedAt', false);

    await delay(3000); // Wait for attributes to be ready

    await databases.createIndex(config.databaseId, COLLECTIONS.COURSES, 'title_index', 'fulltext', ['title'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.COURSES, 'category_index', 'key', ['category'], ['asc']);

    console.log('✅ Courses collection created');
  } catch (error) {
    handleCollectionError('Courses', error);
  }
}

// Plans Collection
async function createPlansCollection() {
  console.log('\n📋 Creating Plans collection...');
  try {
    await databases.createCollection(config.databaseId, COLLECTIONS.PLANS, 'Plans', [
      sdk.Permission.read(sdk.Role.any()),
      sdk.Permission.create(sdk.Role.users()),
      sdk.Permission.update(sdk.Role.users()),
      sdk.Permission.delete(sdk.Role.users()),
    ]);
    await delay(2000);

    await databases.createStringAttribute(config.databaseId, COLLECTIONS.PLANS, 'studentId', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.PLANS, 'courseId', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.PLANS, 'planName', 255, true);
    await databases.createIntegerAttribute(config.databaseId, COLLECTIONS.PLANS, 'totalSessions', true, 1, 1000);
    await databases.createIntegerAttribute(config.databaseId, COLLECTIONS.PLANS, 'completedSessions', false, 0, 1000, 0);
    await databases.createIntegerAttribute(config.databaseId, COLLECTIONS.PLANS, 'remainingSessions', true, 0, 1000);
    await databases.createIntegerAttribute(config.databaseId, COLLECTIONS.PLANS, 'sessionDuration', true, 15, 240);
    await databases.createFloatAttribute(config.databaseId, COLLECTIONS.PLANS, 'totalPrice', false, 0, 100000, 0);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.PLANS, 'status', 50, false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.PLANS, 'startDate', false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.PLANS, 'endDate', false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.PLANS, 'createdAt', true);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.PLANS, 'updatedAt', false);

    await delay(3000); // Wait for attributes to be ready

    await databases.createIndex(config.databaseId, COLLECTIONS.PLANS, 'studentId_index', 'key', ['studentId'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.PLANS, 'courseId_index', 'key', ['courseId'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.PLANS, 'status_index', 'key', ['status'], ['asc']);

    console.log('✅ Plans collection created');
  } catch (error) {
    handleCollectionError('Plans', error);
  }
}

// ClassSessions Collection
async function createClassSessionsCollection() {
  console.log('\n🎓 Creating ClassSessions collection...');
  try {
    await databases.createCollection(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'Class Sessions', [
      sdk.Permission.read(sdk.Role.any()),
      sdk.Permission.create(sdk.Role.users()),
      sdk.Permission.update(sdk.Role.users()),
      sdk.Permission.delete(sdk.Role.users()),
    ]);
    await delay(2000);

    await databases.createStringAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'teacherId', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'studentId', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'courseId', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'planId', 255, false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'scheduledDate', true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'scheduledTime', 50, true);
    await databases.createIntegerAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'duration', true, 15, 240);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'status', 50, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'attendanceStatus', 50, false);
    await databases.createFloatAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'salaryAmount', false, 0, 10000, 0);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'notes', 2000, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'meetingLink', 500, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'createdBy', 255, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'rescheduleRequestId', 255, false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'completedAt', false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'createdAt', true);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'updatedAt', false);

    await delay(3000); // Wait for attributes to be ready

    await databases.createIndex(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'teacherId_index', 'key', ['teacherId'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'studentId_index', 'key', ['studentId'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'courseId_index', 'key', ['courseId'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'status_index', 'key', ['status'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.CLASS_SESSIONS, 'scheduledDate_index', 'key', ['scheduledDate'], ['asc']);

    console.log('✅ ClassSessions collection created');
  } catch (error) {
    handleCollectionError('ClassSessions', error);
  }
}

// TeacherAvailability Collection
async function createTeacherAvailabilityCollection() {
  console.log('\n📅 Creating TeacherAvailability collection...');
  try {
    await databases.createCollection(config.databaseId, COLLECTIONS.TEACHER_AVAILABILITY, 'Teacher Availability', [
      sdk.Permission.read(sdk.Role.any()),
      sdk.Permission.create(sdk.Role.users()),
      sdk.Permission.update(sdk.Role.users()),
      sdk.Permission.delete(sdk.Role.users()),
    ]);
    await delay(2000);

    await databases.createStringAttribute(config.databaseId, COLLECTIONS.TEACHER_AVAILABILITY, 'teacherId', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.TEACHER_AVAILABILITY, 'dayOfWeek', 50, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.TEACHER_AVAILABILITY, 'startTime', 50, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.TEACHER_AVAILABILITY, 'endTime', 50, true);
    await databases.createBooleanAttribute(config.databaseId, COLLECTIONS.TEACHER_AVAILABILITY, 'isAvailable', false, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.TEACHER_AVAILABILITY, 'timezone', 100, false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.TEACHER_AVAILABILITY, 'createdAt', true);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.TEACHER_AVAILABILITY, 'updatedAt', false);

    await delay(3000); // Wait for attributes to be ready

    await databases.createIndex(config.databaseId, COLLECTIONS.TEACHER_AVAILABILITY, 'teacherId_index', 'key', ['teacherId'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.TEACHER_AVAILABILITY, 'dayOfWeek_index', 'key', ['dayOfWeek'], ['asc']);

    console.log('✅ TeacherAvailability collection created');
  } catch (error) {
    handleCollectionError('TeacherAvailability', error);
  }
}

// RescheduleRequests Collection
async function createRescheduleRequestsCollection() {
  console.log('\n🔄 Creating RescheduleRequests collection...');
  try {
    await databases.createCollection(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'Reschedule Requests', [
      sdk.Permission.read(sdk.Role.any()),
      sdk.Permission.create(sdk.Role.users()),
      sdk.Permission.update(sdk.Role.users()),
      sdk.Permission.delete(sdk.Role.users()),
    ]);
    await delay(2000);

    await databases.createStringAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'sessionId', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'requestedBy', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'requestedByRole', 50, true);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'originalDate', true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'originalTime', 50, true);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'newDate', true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'newTime', 50, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'reason', 1000, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'status', 50, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'reviewedBy', 255, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'reviewNotes', 1000, false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'reviewedAt', false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'createdAt', true);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'updatedAt', false);

    await delay(3000); // Wait for attributes to be ready

    await databases.createIndex(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'sessionId_index', 'key', ['sessionId'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.RESCHEDULE_REQUESTS, 'status_index', 'key', ['status'], ['asc']);

    console.log('✅ RescheduleRequests collection created');
  } catch (error) {
    handleCollectionError('RescheduleRequests', error);
  }
}

// SalaryRecords Collection
async function createSalaryRecordsCollection() {
  console.log('\n💰 Creating SalaryRecords collection...');
  try {
    await databases.createCollection(config.databaseId, COLLECTIONS.SALARY_RECORDS, 'Salary Records', [
      sdk.Permission.read(sdk.Role.any()),
      sdk.Permission.create(sdk.Role.users()),
      sdk.Permission.update(sdk.Role.users()),
      sdk.Permission.delete(sdk.Role.users()),
    ]);
    await delay(2000);

    await databases.createStringAttribute(config.databaseId, COLLECTIONS.SALARY_RECORDS, 'teacherId', 255, true);
    await databases.createIntegerAttribute(config.databaseId, COLLECTIONS.SALARY_RECORDS, 'month', true, 1, 12);
    await databases.createIntegerAttribute(config.databaseId, COLLECTIONS.SALARY_RECORDS, 'year', true, 2000, 2100);
    await databases.createFloatAttribute(config.databaseId, COLLECTIONS.SALARY_RECORDS, 'totalSalary', false, 0, 100000, 0);
    await databases.createFloatAttribute(config.databaseId, COLLECTIONS.SALARY_RECORDS, 'paidAmount', false, 0, 100000, 0);
    await databases.createFloatAttribute(config.databaseId, COLLECTIONS.SALARY_RECORDS, 'remainingAmount', false, 0, 100000, 0);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.SALARY_RECORDS, 'status', 50, false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.SALARY_RECORDS, 'createdAt', true);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.SALARY_RECORDS, 'updatedAt', false);

    await delay(3000); // Wait for attributes to be ready

    await databases.createIndex(config.databaseId, COLLECTIONS.SALARY_RECORDS, 'teacherId_index', 'key', ['teacherId'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.SALARY_RECORDS, 'status_index', 'key', ['status'], ['asc']);

    console.log('✅ SalaryRecords collection created');
  } catch (error) {
    handleCollectionError('SalaryRecords', error);
  }
}

// Tasks Collection
async function createTasksCollection() {
  console.log('\n📝 Creating Tasks collection...');
  try {
    await databases.createCollection(config.databaseId, COLLECTIONS.TASKS, 'Tasks', [
      sdk.Permission.read(sdk.Role.any()),
      sdk.Permission.create(sdk.Role.users()),
      sdk.Permission.update(sdk.Role.users()),
      sdk.Permission.delete(sdk.Role.users()),
    ]);
    await delay(2000);

    await databases.createStringAttribute(config.databaseId, COLLECTIONS.TASKS, 'title', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.TASKS, 'description', 2000, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.TASKS, 'assignedTo', 255, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.TASKS, 'assignedBy', 255, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.TASKS, 'status', 50, false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.TASKS, 'dueDate', false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.TASKS, 'createdAt', true);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.TASKS, 'updatedAt', false);

    await delay(3000); // Wait for attributes to be ready

    await databases.createIndex(config.databaseId, COLLECTIONS.TASKS, 'assignedTo_index', 'key', ['assignedTo'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.TASKS, 'status_index', 'key', ['status'], ['asc']);

    console.log('✅ Tasks collection created');
  } catch (error) {
    handleCollectionError('Tasks', error);
  }
}

// LearningMaterials Collection
async function createLearningMaterialsCollection() {
  console.log('\n📖 Creating LearningMaterials collection...');
  try {
    await databases.createCollection(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'Learning Materials', [
      sdk.Permission.read(sdk.Role.any()),
      sdk.Permission.create(sdk.Role.users()),
      sdk.Permission.update(sdk.Role.users()),
      sdk.Permission.delete(sdk.Role.users()),
    ]);
    await delay(2000);

    await databases.createStringAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'title', 255, true);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'description', 2000, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'category', 100, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'type', 50, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'fileUrl', 500, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'fileId', 255, false);
    await databases.createIntegerAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'fileSize', false, 0, 2147483647, 0);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'thumbnailUrl', 500, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'courseId', 255, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'uploadedBy', 255, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'status', 50, false);
    await databases.createStringAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'tags', 1000, false);
    await databases.createIntegerAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'viewCount', false, 0, 2147483647, 0);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'publishedAt', false);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'createdAt', true);
    await databases.createDatetimeAttribute(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'updatedAt', false);

    await delay(3000); // Wait for attributes to be ready

    await databases.createIndex(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'title_index', 'fulltext', ['title'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'category_index', 'key', ['category'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'status_index', 'key', ['status'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'type_index', 'key', ['type'], ['asc']);
    await databases.createIndex(config.databaseId, COLLECTIONS.LEARNING_MATERIALS, 'courseId_index', 'key', ['courseId'], ['asc']);

    console.log('✅ LearningMaterials collection created');
  } catch (error) {
    handleCollectionError('LearningMaterials', error);
  }
}

// -------------------- STORAGE BUCKET --------------------

async function createStorageBucket() {
  const bucketId = 'learning_materials';
  console.log('\n📦 Creating storage bucket for learning materials...');

  try {
    const bucket = await storage.createBucket(
      bucketId,                 // bucketId
      'Learning Materials',      // name
      [
        sdk.Permission.read(sdk.Role.any()),
        sdk.Permission.create(sdk.Role.label('admin')),
        sdk.Permission.update(sdk.Role.label('admin')),
        sdk.Permission.delete(sdk.Role.label('admin')),
      ],                         // permissions
      false,                     // fileSecurity (false = bucket-level permissions)
      true,                      // enabled
      50000000,                 // maximum file size (100MB = 100,000,000 bytes)
      [],                        // allowed file extensions (empty = all types allowed)
      'gzip',                    // compression (none, gzip, or zstd)
      true,                      // encryption
      true                       // antivirus (if available)
    );

    console.log('✅ Storage bucket created successfully!');
    console.log('   📁 Bucket ID:', bucket.$id);
    console.log('   📝 Name:', bucket.name);
    console.log('   📏 Max File Size:', (bucket.maximumFileSize / 1000000).toFixed(0), 'MB');
    console.log('   🔐 Compression:', bucket.compression ? 'Enabled' : 'Disabled');
    console.log('   🔒 Encryption:', bucket.encryption ? 'Enabled' : 'Disabled');
    console.log('   🛡️  Antivirus:', bucket.antivirus ? 'Enabled' : 'Disabled');
  } catch (error) {
    if (error.code === 409) {
      console.log(`ℹ️  Storage bucket already exists: ${bucketId}`);
      console.log('   Skipping creation...');

      // Try to get existing bucket details
      try {
        const existingBucket = await storage.getBucket(bucketId);
        console.log('   📁 Existing Bucket ID:', existingBucket.$id);
        console.log('   📝 Name:', existingBucket.name);
        console.log('   📏 Max File Size:', (existingBucket.maximumFileSize / 1000000).toFixed(0), 'MB');
      } catch (getError) {
        console.log('   ⚠️  Could not retrieve existing bucket details');
      }
    } else {
      console.error('❌ Error creating storage bucket:', error.message);
      throw error;
    }
  }
}

// -------------------- ADMIN ACCOUNT --------------------

async function createAdminAccount() {
  console.log('\n👤 Creating admin account...');
  try {
    // Check if admin already exists by email
    try {
      const existingUsers = await users.list([sdk.Query.equal('email', [ADMIN_CREDENTIALS.email])]);
      if (existingUsers.users.length > 0) {
        const adminUser = existingUsers.users[0];
        console.log('ℹ️  Admin account already exists');

        // Check if user document exists
        try {
          const userDocs = await databases.listDocuments(
            config.databaseId,
            COLLECTIONS.USERS,
            [sdk.Query.equal('userId', [adminUser.$id])]
          );

          if (userDocs.documents.length === 0) {
            // Create user document for existing auth user
            await databases.createDocument(
              config.databaseId,
              COLLECTIONS.USERS,
              sdk.ID.unique(),
              {
                userId: adminUser.$id,
                email: ADMIN_CREDENTIALS.email,
                fullName: ADMIN_CREDENTIALS.name,
                role: 'admin',
                status: 'active',
                createdAt: new Date().toISOString(),
              }
            );
            console.log('✅ Admin user document created');
          }
        } catch (error) {
          console.log('ℹ️  Admin user document already exists');
        }

        return adminUser;
      }
    } catch (error) {
      // User doesn't exist, continue to create
    }

    // Create auth user
    const authUser = await users.create(
      sdk.ID.unique(),
      ADMIN_CREDENTIALS.email,
      undefined, // phone
      ADMIN_CREDENTIALS.password,
      ADMIN_CREDENTIALS.name
    );

    console.log('✅ Admin auth account created');

    // Wait for user to be ready
    await delay(2000);

    // Create user document in database
    await databases.createDocument(
      config.databaseId,
      COLLECTIONS.USERS,
      sdk.ID.unique(),
      {
        userId: authUser.$id,
        email: ADMIN_CREDENTIALS.email,
        fullName: ADMIN_CREDENTIALS.name,
        role: 'admin',
        status: 'active',
        createdAt: new Date().toISOString(),
      }
    );

    console.log('✅ Admin user document created');

    return authUser;
  } catch (error) {
    console.error('❌ Error creating admin account:', error.message);
    throw error;
  }
}

// -------------------- MAIN SETUP --------------------

async function setupDatabase() {
  console.log('🚀 Starting Quran Gate Academy Appwrite setup...\n');
  try {
    console.log(`ℹ️ Using existing database: ${config.databaseId}`);

    await createUsersCollection();
    await createStudentsCollection();
    await createCoursesCollection();
    await createPlansCollection();
    await createClassSessionsCollection();
    await createTeacherAvailabilityCollection();
    await createRescheduleRequestsCollection();
    await createSalaryRecordsCollection();
    await createTasksCollection();
    await createLearningMaterialsCollection();

    // Create storage bucket for learning materials
    await createStorageBucket();

    // Create admin account
    await createAdminAccount();

    console.log('\n✅ Setup completed successfully!');
    console.log('\n' + '='.repeat(60));
    console.log('🎉 ADMIN LOGIN CREDENTIALS');
    console.log('='.repeat(60));
    console.log(`Email:    ${ADMIN_CREDENTIALS.email}`);
    console.log(`Password: ${ADMIN_CREDENTIALS.password}`);
    console.log('='.repeat(60));
    console.log('\n⚠️  Please change the password after first login!');
    console.log('📝 Save these credentials in a secure location.\n');
  } catch (error) {
    console.error('\n❌ Setup failed:', error.message);
    process.exit(1);
  }
}

setupDatabase();
