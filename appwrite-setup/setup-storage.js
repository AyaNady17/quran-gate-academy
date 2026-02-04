const sdk = require('node-appwrite');
require('dotenv').config();

// Initialize Appwrite client
const client = new sdk.Client()
  .setEndpoint(process.env.APPWRITE_ENDPOINT)
  .setProject(process.env.APPWRITE_PROJECT_ID)
  .setKey(process.env.APPWRITE_API_KEY);

const storage = new sdk.Storage(client);

/**
 * Create learning_materials storage bucket
 */
async function createStorageBucket() {
  const bucketId = 'learning_materials';

  try {
    console.log(`📦 Creating storage bucket: ${bucketId}...`);

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
      100000000,                 // maximum file size (100MB = 100,000,000 bytes)
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
    console.log('\n   Permissions:');
    console.log('   - Read: any (public access)');
    console.log('   - Create: role:admin');
    console.log('   - Update: role:admin');
    console.log('   - Delete: role:admin');

    return bucket;
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
        return existingBucket;
      } catch (getError) {
        console.log('   ⚠️  Could not retrieve existing bucket details');
      }
    } else {
      throw error;
    }
  }
}

/**
 * Verify bucket permissions
 */
async function verifyBucketPermissions(bucketId) {
  try {
    console.log('\n🔍 Verifying bucket permissions...');
    const bucket = await storage.getBucket(bucketId);

    const hasReadPermission = bucket.$read && bucket.$read.length > 0;
    const hasCreatePermission = bucket.$create && bucket.$create.length > 0;

    if (hasReadPermission && hasCreatePermission) {
      console.log('✅ Bucket permissions verified successfully');
      return true;
    } else {
      console.log('⚠️  Warning: Bucket permissions may need adjustment');
      console.log('   Read permissions:', bucket.$read || 'None');
      console.log('   Create permissions:', bucket.$create || 'None');
      return false;
    }
  } catch (error) {
    console.log('⚠️  Could not verify permissions:', error.message);
    return false;
  }
}

/**
 * Main setup function
 */
async function setupStorage() {
  console.log('🚀 Starting Appwrite Storage Setup...\n');
  console.log('📡 Endpoint:', process.env.APPWRITE_ENDPOINT);
  console.log('🆔 Project ID:', process.env.APPWRITE_PROJECT_ID);
  console.log('');

  try {
    // Create storage bucket
    await createStorageBucket();

    // Verify permissions
    await verifyBucketPermissions('learning_materials');

    console.log('\n✅ Storage setup completed successfully!');
    console.log('\n📋 Next Steps:');
    console.log('   1. Run: cd ../flutter_app && flutter pub get');
    console.log('   2. Login as admin in the Flutter app');
    console.log('   3. Go to Materials Management (sidebar)');
    console.log('   4. Upload your first learning material');
    console.log('   5. Verify it appears in Appwrite Console → Storage');
    console.log('\n💡 Tip: Check SETUP_STORAGE.md for detailed documentation');

  } catch (error) {
    console.error('\n❌ Storage setup failed!');
    console.error('Error:', error.message);

    if (error.code) {
      console.error('Error Code:', error.code);
    }

    console.error('\n🔧 Troubleshooting:');
    console.error('   - Verify your API key has Storage permissions');
    console.error('   - Check your .env file has correct credentials');
    console.error('   - Ensure you have admin access to the Appwrite project');
    console.error('   - Check SETUP_STORAGE.md for more help');

    process.exit(1);
  }
}

// Run setup
setupStorage();
