#!/usr/bin/env node

/**
 * Appwrite Database Setup Script
 *
 * This script sets up the Appwrite backend for Quran Gate Academy
 * with proper collections, attributes, indexes, and permissions.
 *
 * Features:
 * - Idempotent (safe to run multiple times)
 * - Creates/updates all required collections
 * - Adds learning materials support
 * - Links users with students
 *
 * Usage: node setup.js
 */

const sdk = require('node-appwrite');
require('dotenv').config({ path: '../.env' });

// Appwrite Configuration
const APPWRITE_ENDPOINT = process.env.APPWRITE_ENDPOINT;
const APPWRITE_PROJECT_ID = process.env.APPWRITE_PROJECT_ID;
const APPWRITE_API_KEY = process.env.APPWRITE_API_KEY;
const DATABASE_ID = 'quran_gate_db';

// Collection IDs
const COLLECTIONS = {
  USERS: 'users',
  STUDENTS: 'students',
  TEACHERS: 'teachers',
  COURSES: 'courses',
  PLANS: 'plans',
  CLASS_SESSIONS: 'class_sessions',
  TEACHER_AVAILABILITY: 'teacher_availability',
  RESCHEDULE_REQUESTS: 'reschedule_requests',
  SALARY_RECORDS: 'salary_records',
  TASKS: 'tasks',
  LEARNING_MATERIALS: 'learning_materials' // NEW
};

// Initialize Appwrite Client
const client = new sdk.Client();
client
  .setEndpoint(APPWRITE_ENDPOINT)
  .setProject(APPWRITE_PROJECT_ID)
  .setKey(APPWRITE_API_KEY);

const databases = new sdk.Databases(client);
const storage = new sdk.Storage(client);

/**
 * Helper to handle idempotent operations
 */
async function safeExecute(operation, errorMessage, successMessage) {
  try {
    const result = await operation();
    console.log(`✅ ${successMessage}`);
    return result;
  } catch (error) {
    if (error.code === 409) {
      console.log(`ℹ️  ${successMessage} (already exists)`);
      return null;
    }
    console.error(`❌ ${errorMessage}:`, error.message);
    throw error;
  }
}

/**
 * Create Learning Materials Collection
 */
async function createLearningMaterialsCollection() {
  console.log('\n📦 Creating learning_materials collection...');

  await safeExecute(
    () => databases.createCollection(
      DATABASE_ID,
      COLLECTIONS.LEARNING_MATERIALS,
      'Learning Materials',
      [
        sdk.Permission.read(sdk.Role.any()),
        sdk.Permission.create(sdk.Role.label('admin')),
        sdk.Permission.create(sdk.Role.label('teacher')),
        sdk.Permission.update(sdk.Role.label('admin')),
        sdk.Permission.update(sdk.Role.label('teacher')),
        sdk.Permission.delete(sdk.Role.label('admin'))
      ],
      false, // documentSecurity
      true   // enabled
    ),
    'Failed to create learning_materials collection',
    'Learning materials collection created'
  );

  // Add attributes
  const attributes = [
    { name: 'title', type: 'string', size: 255, required: true },
    { name: 'description', type: 'string', size: 2000, required: false },
    { name: 'category', type: 'string', size: 100, required: false },
    { name: 'type', type: 'string', size: 50, required: true }, // pdf, video, audio, document
    { name: 'fileUrl', type: 'string', size: 500, required: false },
    { name: 'fileId', type: 'string', size: 255, required: false },
    { name: 'fileSize', type: 'integer', required: false },
    { name: 'thumbnailUrl', type: 'string', size: 500, required: false },
    { name: 'courseId', type: 'string', size: 255, required: false }, // Link to course
    { name: 'uploadedBy', type: 'string', size: 255, required: true }, // userId
    { name: 'status', type: 'string', size: 50, required: true }, // published, draft, archived (no default for required)
    { name: 'tags', type: 'string', size: 1000, required: false }, // JSON array
    { name: 'viewCount', type: 'integer', required: false, default: 0 },
    { name: 'publishedAt', type: 'datetime', required: false },
    { name: 'createdAt', type: 'datetime', required: true },
    { name: 'updatedAt', type: 'datetime', required: false }
  ];

  for (const attr of attributes) {
    await safeExecute(
      () => {
        if (attr.type === 'string') {
          return databases.createStringAttribute(
            DATABASE_ID,
            COLLECTIONS.LEARNING_MATERIALS,
            attr.name,
            attr.size,
            attr.required,
            attr.default
          );
        } else if (attr.type === 'integer') {
          return databases.createIntegerAttribute(
            DATABASE_ID,
            COLLECTIONS.LEARNING_MATERIALS,
            attr.name,
            attr.required,
            undefined, // min
            undefined, // max
            attr.default
          );
        } else if (attr.type === 'datetime') {
          return databases.createDatetimeAttribute(
            DATABASE_ID,
            COLLECTIONS.LEARNING_MATERIALS,
            attr.name,
            attr.required,
            attr.default
          );
        }
      },
      `Failed to create attribute ${attr.name}`,
      `Attribute ${attr.name} created`
    );
  }

  // Create indexes
  const indexes = [
    { key: 'title_search', type: 'fulltext', attributes: ['title'] },
    { key: 'category_index', type: 'key', attributes: ['category'] },
    { key: 'status_index', type: 'key', attributes: ['status'] },
    { key: 'type_index', type: 'key', attributes: ['type'] },
    { key: 'courseId_index', type: 'key', attributes: ['courseId'] },
    { key: 'createdAt_index', type: 'key', attributes: ['createdAt'], orders: ['DESC'] }
  ];

  for (const index of indexes) {
    await safeExecute(
      () => databases.createIndex(
        DATABASE_ID,
        COLLECTIONS.LEARNING_MATERIALS,
        index.key,
        index.type,
        index.attributes,
        index.orders
      ),
      `Failed to create index ${index.key}`,
      `Index ${index.key} created`
    );
  }
}

/**
 * Add linkedStudentId to users collection
 */
async function updateUsersCollection() {
  console.log('\n👤 Updating users collection...');

  await safeExecute(
    () => databases.createStringAttribute(
      DATABASE_ID,
      COLLECTIONS.USERS,
      'linkedStudentId',
      255,
      false // not required
    ),
    'Failed to add linkedStudentId to users',
    'linkedStudentId attribute added to users collection'
  );
}

/**
 * Add userId to students collection
 */
async function updateStudentsCollection() {
  console.log('\n🎓 Updating students collection...');

  const attrCreated = await safeExecute(
    () => databases.createStringAttribute(
      DATABASE_ID,
      COLLECTIONS.STUDENTS,
      'userId',
      255,
      false // not required
    ),
    'Failed to add userId to students',
    'userId attribute added to students collection'
  );

  // Wait for attribute to be available if it was just created
  if (attrCreated) {
    console.log('⏳ Waiting for userId attribute to be available...');
    await new Promise(resolve => setTimeout(resolve, 3000));
  }

  // Add index for userId lookups
  await safeExecute(
    () => databases.createIndex(
      DATABASE_ID,
      COLLECTIONS.STUDENTS,
      'userId_index',
      'key',
      ['userId']
    ),
    'Failed to create userId index on students',
    'userId index created on students collection'
  );
}

/**
 * Create Session Reports Collection
 */
async function createSessionReportsCollection() {
  console.log('\n📊 Creating session_reports collection...');

  const collectionId = 'session_reports';

  await safeExecute(
    () => databases.createCollection(
      DATABASE_ID,
      collectionId,
      'Session Reports',
      [
        sdk.Permission.read(sdk.Role.any()),
        sdk.Permission.create(sdk.Role.label('teacher')),
        sdk.Permission.create(sdk.Role.label('admin')),
        sdk.Permission.update(sdk.Role.label('teacher')),
        sdk.Permission.update(sdk.Role.label('admin')),
        sdk.Permission.delete(sdk.Role.label('admin'))
      ],
      false // documentSecurity
    ),
    'Failed to create session_reports collection',
    'session_reports collection created'
  );

  // Session ID (link to class_sessions)
  await safeExecute(
    () => databases.createStringAttribute(DATABASE_ID, collectionId, 'sessionId', 255, true),
    'Failed to add sessionId',
    'sessionId attribute added'
  );

  // Student ID
  await safeExecute(
    () => databases.createStringAttribute(DATABASE_ID, collectionId, 'studentId', 255, true),
    'Failed to add studentId',
    'studentId attribute added'
  );

  // Teacher ID
  await safeExecute(
    () => databases.createStringAttribute(DATABASE_ID, collectionId, 'teacherId', 255, true),
    'Failed to add teacherId',
    'teacherId attribute added'
  );

  // Attendance status (attended/absent)
  await safeExecute(
    () => databases.createStringAttribute(DATABASE_ID, collectionId, 'attendance', 50, true),
    'Failed to add attendance',
    'attendance attribute added'
  );

  // Student performance (good/excellent) - only if attended
  await safeExecute(
    () => databases.createStringAttribute(DATABASE_ID, collectionId, 'performance', 50, false),
    'Failed to add performance',
    'performance attribute added'
  );

  // Session summary (title-style)
  await safeExecute(
    () => databases.createStringAttribute(DATABASE_ID, collectionId, 'summary', 500, false),
    'Failed to add summary',
    'summary attribute added'
  );

  // Homework
  await safeExecute(
    () => databases.createStringAttribute(DATABASE_ID, collectionId, 'homework', 2000, false),
    'Failed to add homework',
    'homework attribute added'
  );

  // Encouragement message
  await safeExecute(
    () => databases.createStringAttribute(DATABASE_ID, collectionId, 'encouragementMessage', 2000, false),
    'Failed to add encouragementMessage',
    'encouragementMessage attribute added'
  );

  // Session entered at (for late tracking)
  await safeExecute(
    () => databases.createDatetimeAttribute(DATABASE_ID, collectionId, 'sessionEnteredAt', false),
    'Failed to add sessionEnteredAt',
    'sessionEnteredAt attribute added'
  );

  // Session ended at
  await safeExecute(
    () => databases.createDatetimeAttribute(DATABASE_ID, collectionId, 'sessionEndedAt', false),
    'Failed to add sessionEndedAt',
    'sessionEndedAt attribute added'
  );

  // Was teacher late
  await safeExecute(
    () => databases.createBooleanAttribute(DATABASE_ID, collectionId, 'teacherLate', false),
    'Failed to add teacherLate',
    'teacherLate attribute added'
  );

  // Late duration in minutes
  await safeExecute(
    () => databases.createIntegerAttribute(DATABASE_ID, collectionId, 'lateDurationMinutes', false),
    'Failed to add lateDurationMinutes',
    'lateDurationMinutes attribute added'
  );

  // Created and updated timestamps
  await safeExecute(
    () => databases.createDatetimeAttribute(DATABASE_ID, collectionId, 'createdAt', true),
    'Failed to add createdAt',
    'createdAt attribute added'
  );

  await safeExecute(
    () => databases.createDatetimeAttribute(DATABASE_ID, collectionId, 'updatedAt', true),
    'Failed to add updatedAt',
    'updatedAt attribute added'
  );

  console.log('⏳ Waiting for attributes to be available...');
  await new Promise(resolve => setTimeout(resolve, 3000));

  // Create indexes
  await safeExecute(
    () => databases.createIndex(DATABASE_ID, collectionId, 'sessionId_index', 'key', ['sessionId']),
    'Failed to create sessionId index',
    'sessionId index created'
  );

  await safeExecute(
    () => databases.createIndex(DATABASE_ID, collectionId, 'studentId_index', 'key', ['studentId']),
    'Failed to create studentId index',
    'studentId index created'
  );

  await safeExecute(
    () => databases.createIndex(DATABASE_ID, collectionId, 'teacherId_index', 'key', ['teacherId']),
    'Failed to create teacherId index',
    'teacherId index created'
  );
}

/**
 * Add enteredAt field to class_sessions collection
 */
async function updateClassSessionsCollection() {
  console.log('\n📅 Updating class_sessions collection...');

  await safeExecute(
    () => databases.createDatetimeAttribute(
      DATABASE_ID,
      COLLECTIONS.CLASS_SESSIONS,
      'enteredAt',
      false // not required
    ),
    'Failed to add enteredAt to class_sessions',
    'enteredAt attribute added to class_sessions collection'
  );
}

/**
 * Create Storage Bucket for Learning Materials (if needed)
 */
async function createStorageBucket() {
  console.log('\n🗄️  Creating storage bucket for learning materials...');

  const bucketId = 'learning_materials';

  try {
    await safeExecute(
      () => storage.createBucket(
        bucketId,
        'Learning Materials',
        [
          sdk.Permission.read(sdk.Role.any()),
          sdk.Permission.create(sdk.Role.label('admin')),
          sdk.Permission.create(sdk.Role.label('teacher')),
          sdk.Permission.update(sdk.Role.label('admin')),
          sdk.Permission.delete(sdk.Role.label('admin'))
        ],
        false,      // fileSecurity
        true,       // enabled
        100000000,  // maxFileSize (100MB)
        [],         // allowedFileExtensions (empty = all allowed)
        'gzip',     // compression
        true,       // encryption
        true        // antivirus
      ),
      'Failed to create storage bucket',
      'Storage bucket created for learning materials'
    );
  } catch (error) {
    if (error.code === 403 && error.type === 'additional_resource_not_allowed') {
      console.log('⚠️  Storage bucket limit reached. You can use an existing bucket or upgrade your plan.');
      console.log('ℹ️  Continuing without creating new bucket...');
    } else {
      throw error;
    }
  }
}

/**
 * Main Setup Function
 */
async function main() {
  console.log('🚀 Starting Quran Gate Academy Appwrite Setup...\n');
  console.log(`📍 Endpoint: ${APPWRITE_ENDPOINT}`);
  console.log(`🔑 Project: ${APPWRITE_PROJECT_ID}`);
  console.log(`🗄️  Database: ${DATABASE_ID}\n`);

  try {
    // Create new collections and features
    await createLearningMaterialsCollection();
    await createSessionReportsCollection();
    await updateUsersCollection();
    await updateStudentsCollection();
    await updateClassSessionsCollection();
    await createStorageBucket();

    console.log('\n✨ Setup completed successfully!\n');
    console.log('📝 Next steps:');
    console.log('1. Update Flutter data models (UserModel, StudentModel, LearningMaterialModel)');
    console.log('2. Add roleStudent to AppConfig');
    console.log('3. Update PermissionService with student role');
    console.log('4. Implement student dashboard and learning materials features\n');

  } catch (error) {
    console.error('\n❌ Setup failed:', error);
    process.exit(1);
  }
}

// Run setup
main().catch(console.error);
