# How to Setup OpenAI API Key

## ⚠️ Important Security Notice

**DO NOT commit your API key to GitHub!**

GitHub will block pushes containing API keys for security reasons.

---

## 🔑 Setup Instructions

### Step 1: Get Your OpenAI API Key

1. Go to https://platform.openai.com/api-keys
2. Login with your OpenAI account
3. Click "Create new secret key"
4. Name it: `manus-app`
5. **Copy the key immediately** (shown only once)

Your key will look like this:
```
sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Step 2: Add the Key to Your App

**Option 1: Environment Variable (Recommended for Production)**

1. Open `lib/data/services/openai_service.dart`
2. Find line 12 and replace with:
```dart
static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');
```

3. Run the app with:
```bash
flutter run --dart-define=OPENAI_API_KEY=sk-proj-your-actual-key-here
```

**Option 2: Local Configuration File (Recommended for Development)**

1. Create a file: `lib/config/api_keys.dart`
2. Add to `.gitignore`:
```
lib/config/api_keys.dart
```

3. In `api_keys.dart`:
```dart
class ApiKeys {
  static const String openAI = 'sk-proj-your-actual-key-here';
}
```

4. In `openai_service.dart` line 12:
```dart
import '../config/api_keys.dart';
// ...
static const String _apiKey = ApiKeys.openAI;
```

**Option 3: Hardcode (Only for Testing - NOT RECOMMENDED)**

1. Open `lib/data/services/openai_service.dart`
2. Replace line 12:
```dart
static const String _apiKey = 'sk-proj-your-actual-key-here';
```

3. **NEVER push this to GitHub!**

---

## 🔒 Security Best Practices

### For Development
- Use Option 2 (Local Configuration File)
- Add the file to `.gitignore`
- Never commit the file

### For Production
- Use environment variables
- Use a secrets management service
- Rotate keys regularly
- Monitor API usage

### If Key is Exposed
1. **Immediately revoke** the key at https://platform.openai.com/api-keys
2. Create a new key
3. Update your app
4. Check your OpenAI usage for unauthorized access

---

## 📝 Current Setup

The repository currently has:
```dart
static const String _apiKey = 'YOUR_OPENAI_API_KEY_HERE';
```

You **MUST** replace this with your actual key using one of the options above.

---

## ✅ Verify Setup

After adding your key, test it:

1. Run the app
2. Create a project
3. Send a message: "Hello Manus"
4. If Manus responds with a real answer → ✅ Working!
5. If you get an error → Check the key and try again

---

## 💰 Cost Management

### Monitor Usage
- Check usage at: https://platform.openai.com/usage
- Set usage limits in your OpenAI account
- GPT-4o-mini is cost-effective (~$0.15 per 1M tokens)

### Estimated Costs
- Light use (10-20 messages/day): $1-2/month
- Moderate use (50-100 messages/day): $5-10/month
- Heavy use (200+ messages/day): $20-30/month

---

## 🆘 Troubleshooting

### Error: "Authentication error"
- Check if key is correct
- Make sure key starts with `sk-proj-`
- Verify key is not revoked

### Error: "Rate limit exceeded"
- Wait a few minutes
- Check your OpenAI usage limits
- Consider upgrading your OpenAI plan

### Error: "Invalid API key"
- Key might be revoked
- Create a new key
- Update your configuration

---

**Remember:** Keep your API key secret and secure! 🔐
