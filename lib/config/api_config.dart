/// 🔧 API Configuration
/// Add your free API keys here
class ApiConfig {
  // 🆓 Get your free Gemini API key from: https://makersuite.google.com/app/apikey
  // Free tier includes: 60 requests per minute, 1500 requests per day
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  
  // 🏪 Get your free Foursquare API key from: https://developer.foursquare.com/
  // Free tier includes: 100,000 requests per month
  static const String foursquareApiKey = 'YOUR_FOURSQUARE_API_KEY';
  
  // 📝 Instructions to get free Foursquare API key:
  // 1. Go to https://developer.foursquare.com/
  // 2. Sign up for a free developer account
  // 3. Create a new app
  // 4. Copy the API key and replace 'YOUR_FOURSQUARE_API_KEY' above
  // 5. Free tier: 100k requests/month (more than enough for personal use)
  
  // 📝 Instructions to get free Gemini API key:
  // 1. Go to https://makersuite.google.com/app/apikey
  // 2. Sign in with your Google account
  // 3. Click "Create API Key"
  // 4. Copy the key and replace 'YOUR_GEMINI_API_KEY' above
  // 5. Keep this key secure and don't commit it to public repositories
  
  static bool get isGeminiConfigured => geminiApiKey != 'YOUR_GEMINI_API_KEY';
  static bool get isFoursquareConfigured => foursquareApiKey != 'YOUR_FOURSQUARE_API_KEY';
}