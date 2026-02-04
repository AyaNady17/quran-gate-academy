# Appwrite Storage Setup Guide

This guide will help you set up the storage bucket for learning materials in Appwrite.

## Prerequisites

- Appwrite project created
- Admin access to Appwrite Console or API

## Option 1: Manual Setup (Appwrite Console)

### Step 1: Access Appwrite Console

1. Go to [Appwrite Console](https://cloud.appwrite.io) or your self-hosted instance
2. Select your project: **Quran Gate Academy**

### Step 2: Create Storage Bucket

1. Click on **Storage** in the left sidebar
2. Click **Create Bucket** button
3. Fill in the details:
   - **Bucket ID**: `learning_materials` *(must match exactly)*
   - **Name**: `Learning Materials`
   - **Permissions**: Configure as follows

### Step 3: Configure Permissions

Set the following permissions for the bucket:

#### Read Permissions
- **Role**: `any` (Any user, including unauthenticated)
- This allows students to view/download materials

#### Create Permissions
- **Role**: `users` with role `admin`
- Only admins can upload materials

#### Update Permissions
- **Role**: `users` with role `admin`
- Only admins can update material files

#### Delete Permissions
- **Role**: `users` with role `admin`
- Only admins can delete materials

**Permissions Configuration (JSON)**:
```json
{
  "read": ["any"],
  "create": ["role:admin"],
  "update": ["role:admin"],
  "delete": ["role:admin"]
}
```

### Step 4: Configure Bucket Settings

1. **Compression**: Enabled (recommended for better performance)
2. **Encryption**: Enabled (recommended for security)
3. **Antivirus**: Enabled (if available, recommended for security)
4. **Maximum File Size**: Set to appropriate limit (e.g., 100MB for videos)
5. **Allowed File Extensions**: Leave empty for all types, or specify:
   - `pdf, mp4, mov, avi, mkv, webm, mp3, wav, ogg, m4a, doc, docx, txt, ppt, pptx`

### Step 5: Verify Setup

1. Go to **Storage** → **learning_materials** bucket
2. Verify permissions are correctly set
3. Try uploading a test file manually to ensure it works

---

## Option 2: API Setup (Automated Script)

Create a Node.js script to automate bucket creation:

### Step 1: Install Dependencies

```bash
cd appwrite-setup
npm install  # If not already done
```

### Step 2: Create Storage Setup Script

Create file: `appwrite-setup/setup-storage.js`

```javascript
const sdk = require('node-appwrite');
require('dotenv').config();

const client = new sdk.Client()
  .setEndpoint(process.env.APPWRITE_ENDPOINT)
  .setProject(process.env.APPWRITE_PROJECT_ID)
  .setKey(process.env.APPWRITE_API_KEY);

const storage = new sdk.Storage(client);

async function setupStorage() {
  try {
    console.log('🚀 Setting up Appwrite Storage...');

    // Create learning_materials bucket
    try {
      const bucket = await storage.createBucket(
        'learning_materials',  // bucketId
        'Learning Materials',   // name
        ['any'],                // read permissions
        ['role:admin'],         // create permissions
        ['role:admin'],         // update permissions
        ['role:admin'],         // delete permissions
        true,                   // enabled
        100000000,              // maximum file size (100MB)
        [],                     // allowed file extensions (empty = all)
        true,                   // compression
        true,                   // encryption
        true                    // antivirus
      );

      console.log('✅ Created bucket: learning_materials');
      console.log('   Bucket ID:', bucket.$id);
      console.log('   Name:', bucket.name);
      console.log('   Max Size:', bucket.maximumFileSize, 'bytes (100MB)');
    } catch (error) {
      if (error.code === 409) {
        console.log('ℹ️  Bucket already exists: learning_materials');
      } else {
        throw error;
      }
    }

    console.log('✅ Storage setup completed successfully!');
  } catch (error) {
    console.error('❌ Storage setup failed:', error.message);
    process.exit(1);
  }
}

setupStorage();
```

### Step 3: Run the Script

```bash
node appwrite-setup/setup-storage.js
```

### Step 4: Verify

Check the Appwrite Console to confirm the bucket was created with correct permissions.

---

## Option 3: Update Existing Setup Script

Add storage setup to the existing `appwrite-setup/setup.js`:

### Add Storage Function

Add this function to `setup.js`:

```javascript
// Add after createLearningMaterialsCollection function

async function createStorageBucket() {
  const bucketId = 'learning_materials';

  try {
    await storage.createBucket(
      bucketId,
      'Learning Materials',
      ['any'],
      ['role:admin'],
      ['role:admin'],
      ['role:admin'],
      true,
      100000000,  // 100MB
      [],
      true,
      true,
      true
    );
    console.log(`✅ Created storage bucket: ${bucketId}`);
  } catch (error) {
    if (error.code === 409) {
      console.log(`ℹ️  Storage bucket already exists: ${bucketId}`);
    } else {
      throw error;
    }
  }
}
```

### Call the Function

Add to the main setup function:

```javascript
async function setup() {
  try {
    console.log('🚀 Starting Appwrite setup...\n');

    await createDatabase();
    await Promise.all([
      createUsersCollection(),
      createStudentsCollection(),
      createCoursesCollection(),
      createPlansCollection(),
      createClassSessionsCollection(),
      createTeacherAvailabilityCollection(),
      createRescheduleRequestsCollection(),
      createSalaryRecordsCollection(),
      createTasksCollection(),
      createLearningMaterialsCollection(),
    ]);

    // Add storage setup
    await createStorageBucket();

    console.log('\n✅ Appwrite setup completed successfully!');
  } catch (error) {
    console.error('\n❌ Setup failed:', error);
    process.exit(1);
  }
}
```

---

## Testing the Setup

### Test 1: Upload via Admin UI

1. Login as admin in the Flutter app
2. Go to **Materials** in the sidebar
3. Try uploading a test file (PDF, image, etc.)
4. Verify the file appears in Appwrite Console → Storage → learning_materials

### Test 2: View as Student

1. Login as a student
2. Go to **Learning Materials**
3. Verify uploaded materials are visible
4. Click a material to view details
5. Click "Open Material" to download/view

### Test 3: Permissions Check

Try these scenarios to verify permissions:

1. **As Admin**: Should be able to upload, update, delete files ✅
2. **As Student**: Should be able to view and download, but NOT upload ✅
3. **Unauthenticated**: Should be able to view material (via direct link) ✅

---

## Troubleshooting

### Issue: Bucket creation fails with 401 Unauthorized

**Cause**: Invalid API key or insufficient permissions

**Solution**:
1. Verify your API key in `.env` file
2. Ensure the API key has Storage permissions (read, write, create, delete)
3. Generate a new API key with full permissions if needed

### Issue: Upload fails with 400 Bad Request

**Cause**: File size exceeds bucket limit or invalid file type

**Solution**:
1. Check file size (must be < 100MB by default)
2. Verify file type is allowed
3. Increase bucket max size if needed:
   ```javascript
   maximumFileSize: 200000000  // 200MB
   ```

### Issue: Files upload but cannot be viewed

**Cause**: Missing read permissions

**Solution**:
1. Go to Storage → learning_materials → Permissions
2. Add read permission: `any`
3. Update the bucket via API or Console

### Issue: Students cannot download files

**Cause**: CORS or permissions issue

**Solution**:
1. Verify bucket read permissions include `any` role
2. Check Appwrite CORS settings (should allow your domain)
3. Verify fileUrl format is correct in the database

---

## Next Steps

After storage setup is complete:

1. ✅ Run `flutter pub get` to install dependencies
2. ✅ Create storage bucket (completed above)
3. ✅ Test file upload as admin
4. ✅ Test file viewing as student
5. 📝 Create your first learning materials
6. 🎓 Create student accounts and share credentials

---

## Storage Best Practices

### File Naming
- Use descriptive filenames
- Avoid special characters
- Include course/topic in filename
- Example: `Tajweed_Lesson_01_Introduction.pdf`

### File Organization
- Use consistent naming conventions
- Add relevant tags for searching
- Assign to specific courses when applicable
- Keep file sizes reasonable (compress large videos)

### Security
- Never share direct storage URLs (use app links)
- Regularly audit uploaded materials
- Monitor storage usage in Appwrite Console
- Set appropriate file size limits

### Performance
- Enable compression for faster downloads
- Use appropriate file formats (MP4 for video, MP3 for audio)
- Consider video transcoding for better compatibility
- Cache frequently accessed materials

---

## Storage Monitoring

### Check Storage Usage

Via Appwrite Console:
1. Go to **Storage**
2. Click on **learning_materials** bucket
3. View **Usage** tab for:
   - Total files count
   - Total storage used
   - Bandwidth usage

### Set Alerts (Optional)

You can set up monitoring for:
- Storage limit approaching (e.g., 80% full)
- Excessive bandwidth usage
- Failed upload attempts

---

## Backup Strategy

Recommended backup approach:

1. **Automated Backups**: Use Appwrite's backup features (if available)
2. **Manual Exports**: Periodically export material metadata from database
3. **File Copies**: Keep copies of important materials in cloud storage (Google Drive, Dropbox)
4. **Version Control**: Track material versions in the database

---

## Support

If you encounter issues:

1. Check Appwrite Console logs
2. Review this troubleshooting section
3. Check Appwrite documentation: https://appwrite.io/docs/storage
4. Check the main STUDENT_PANEL_GUIDE.md for additional help

---

**Last Updated**: 2026-02-04
**Appwrite Version**: 1.4+
**Status**: Production Ready
