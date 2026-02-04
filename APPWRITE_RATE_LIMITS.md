# Appwrite Rate Limits - Troubleshooting Guide

## Understanding the Error

**Error Message**: "Rate limit for the current endpoint has been exceeded."

**What it means**: Appwrite limits how many requests you can make to certain endpoints (like account creation) within a specific time window to prevent abuse and protect the service.

---

## Quick Solutions

### 1. Wait and Retry (Immediate Fix)

**Action**: Wait 60 seconds before trying again

**Why**: Rate limits typically reset after 1 minute for most Appwrite endpoints

**When to use**: During testing or when you see this error

### 2. Adjust Appwrite Rate Limits (Development)

For development/testing environments, you can temporarily increase rate limits:

#### Appwrite Cloud (cloud.appwrite.io)

1. Go to [Appwrite Console](https://cloud.appwrite.io)
2. Select your project
3. Navigate to **Settings** → **Configuration**
4. Scroll to **Rate Limits** section
5. Increase limits for:
   - **Users** → Account creation endpoint
   - Recommended: 100 requests per minute for development

#### Self-Hosted Appwrite

Edit your `docker-compose.yml` or environment variables:

```yaml
environment:
  - _APP_LIMIT_USERS=100           # Increase account creation limit
  - _APP_LIMIT_ABUSE_TIMEWAIT=60   # Time window in seconds
```

Then restart Appwrite:
```bash
docker-compose down
docker-compose up -d
```

---

## Code Improvements (Already Applied)

### Error Handling Updates

Both account creation methods now detect rate limit errors and show clear messages:

**Files Updated**:
- `student_cubit.dart` - Single-step creation
- `create_account_dialog.dart` - Dialog creation

**New Error Message**:
```
"Too many account creation requests. Please wait a minute and try again."
```

---

## Best Practices

### During Development

1. **Space out account creations**: Wait 10-15 seconds between creating accounts
2. **Use test accounts**: Create a few test accounts and reuse them
3. **Increase limits temporarily**: Set higher limits during testing
4. **Clean up test data**: Delete test accounts when done

### In Production

1. **Keep default limits**: Protects against abuse and brute force attacks
2. **User feedback**: Clear error messages (already implemented)
3. **Retry logic**: Consider adding automatic retry with exponential backoff
4. **Monitor usage**: Track rate limit errors in logs

---

## Rate Limit Defaults

Common Appwrite rate limits (may vary by plan):

| Endpoint | Default Limit | Time Window |
|----------|--------------|-------------|
| Account Creation | 10 requests | 1 minute |
| Login | 10 requests | 1 minute |
| Password Recovery | 10 requests | 15 minutes |
| Email Verification | 10 requests | 1 minute |
| Database Queries | 60 requests | 1 minute |

**Note**: Cloud plans may have different limits based on subscription tier.

---

## Advanced: Retry Logic (Optional Enhancement)

For production, you can add exponential backoff retry logic:

```dart
Future<void> createAccountWithRetry({
  required String email,
  required String password,
  int maxRetries = 3,
}) async {
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      // Attempt account creation
      await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
      );
      return; // Success
    } catch (e) {
      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('rate limit') && retryCount < maxRetries - 1) {
        // Wait with exponential backoff
        final waitTime = Duration(seconds: (retryCount + 1) * 30);
        await Future.delayed(waitTime);
        retryCount++;
      } else {
        rethrow; // Not a rate limit error or max retries reached
      }
    }
  }
}
```

**When to use**: High-traffic production environments where rate limits are frequently hit.

---

## Monitoring Rate Limits

### Check Current Usage

Via Appwrite Console:
1. Go to **Usage** tab in your project
2. View **API Requests** metrics
3. Check for spikes in account creation requests

### Set Up Alerts (Cloud Plans)

For Appwrite Cloud Pro/Scale plans:
1. Navigate to **Settings** → **Alerts**
2. Create alert for "Rate limit exceeded"
3. Configure notification channel (email, Slack, webhook)

---

## Troubleshooting Specific Scenarios

### Scenario 1: Testing Student Account Creation

**Problem**: Creating multiple test student accounts quickly hits rate limit

**Solutions**:
1. **Increase development limits** (see solution #2 above)
2. **Space out creations**: Add delays between test runs
3. **Use seed script**: Create all test accounts in one batch with delays

**Example Seed Script**:
```javascript
// appwrite-setup/seed-test-students.js
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

async function seedTestStudents() {
  const testStudents = [
    { name: 'Test Student 1', email: 'test1@example.com' },
    { name: 'Test Student 2', email: 'test2@example.com' },
    // ... more students
  ];

  for (const student of testStudents) {
    try {
      // Create student and account
      await createStudentWithAccount(student);
      console.log(`✅ Created ${student.name}`);

      // Wait 10 seconds before next creation
      await delay(10000);
    } catch (error) {
      console.error(`❌ Failed to create ${student.name}:`, error.message);
    }
  }
}
```

### Scenario 2: Production Users Creating Accounts

**Problem**: Multiple students signing up at the same time

**Solutions**:
1. **Keep default limits**: Protects your system
2. **Queue system**: Implement account creation queue
3. **Better UX**: Show "Creating account..." with progress indicator
4. **Upgrade plan**: Higher tier Appwrite plans have higher limits

### Scenario 3: Admin Bulk Account Creation

**Problem**: Admin needs to create many student accounts at once

**Solutions**:
1. **Batch with delays**: Create accounts in batches with pauses
2. **Background job**: Process account creation asynchronously
3. **Import tool**: Create separate tool for bulk operations

**Example Implementation**:
```dart
Future<void> bulkCreateAccounts(List<StudentData> students) async {
  final batchSize = 5;
  final delayBetweenBatches = Duration(minutes: 1);

  for (int i = 0; i < students.length; i += batchSize) {
    final batch = students.skip(i).take(batchSize).toList();

    // Create batch
    await Future.wait(
      batch.map((student) => createStudentWithAccount(student))
    );

    // Wait before next batch
    if (i + batchSize < students.length) {
      await Future.delayed(delayBetweenBatches);
    }
  }
}
```

---

## FAQ

### Q: Can I disable rate limits completely?

**A**: Not recommended. Rate limits protect against:
- Brute force attacks
- Accidental infinite loops in code
- Service abuse
- Resource exhaustion

For development, increase limits instead of disabling.

### Q: Do rate limits apply per user or per project?

**A**: Most rate limits are **per IP address per endpoint per project**. Some (like login) may be per user.

### Q: What happens when I hit the rate limit?

**A**:
1. Appwrite returns HTTP 429 (Too Many Requests)
2. Your app receives an error
3. The error is caught and displayed to the user
4. The limit resets after the time window expires

### Q: Will upgrading my Appwrite plan help?

**A**: Yes, higher tiers typically have:
- Higher rate limits
- Longer time windows
- Priority processing
- Custom rate limit configurations

Check your plan details on [Appwrite Pricing](https://appwrite.io/pricing).

---

## Support

If you continue experiencing rate limit issues after following this guide:

1. **Check Appwrite Status**: [status.appwrite.io](https://status.appwrite.io)
2. **Review your code**: Ensure no loops creating accounts
3. **Check logs**: Look for unexpected API calls
4. **Contact Appwrite Support**: For persistent production issues
5. **Community Discord**: [discord.gg/appwrite](https://discord.gg/appwrite)

---

## Related Documentation

- [Appwrite Rate Limits Documentation](https://appwrite.io/docs/rate-limits)
- [Account API Reference](https://appwrite.io/docs/client/account)
- [Error Handling Best Practices](https://appwrite.io/docs/error-handling)

---

**Last Updated**: 2026-02-04
**Applies to**: Appwrite 1.4+
**Status**: ✅ Error handling implemented
