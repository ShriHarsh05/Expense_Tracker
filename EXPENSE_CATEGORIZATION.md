# 🤖 AI-Powered Expense Categorization

Your expense tracker now includes **4 FREE categorization approaches** to automatically classify SMS expenses into categories like Food, Travel, Work, Leisure, and Miscellaneous.

## 🆓 Available Approaches (All FREE!)

### 1. **Rule-Based Classification** (100% Free, Instant)
- Uses keyword matching to categorize expenses
- Works completely offline
- Instant results with no API calls
- Keywords include: restaurants, uber, netflix, office supplies, etc.

### 2. **Gemini AI Classification** (Free Tier)
- Uses Google's Gemini AI for intelligent categorization
- **Free tier**: 60 requests/minute, 1500 requests/day
- Fallback to rule-based if API fails
- More accurate for complex/ambiguous expenses

### 3. **Hybrid Approach** (Recommended)
- Combines rule-based + AI for best results
- Uses rule-based for confident matches (instant)
- Uses Gemini AI only for uncertain cases
- Optimizes API usage while maintaining accuracy

### 4. **Learning-Based** (Future Enhancement)
- Will learn from your manual corrections
- Improves accuracy over time
- Currently uses hybrid approach

## 🔧 Setup Instructions

### For Rule-Based Only (No Setup Required)
- Works out of the box
- No configuration needed
- 100% free and offline

### For AI-Enhanced Categorization
1. **Get Free Gemini API Key**:
   - Visit: https://makersuite.google.com/app/apikey
   - Sign in with Google account
   - Click "Create API Key"
   - Copy the generated key

2. **Configure API Key**:
   - Open `lib/config/api_config.dart`
   - Replace `'YOUR_GEMINI_API_KEY'` with your actual key
   - Save the file

3. **Keep Key Secure**:
   - Don't commit API keys to public repositories
   - Consider using environment variables for production

## 📊 How It Works

When an SMS expense is detected:

1. **SMS Parsing**: Extracts amount and details from bank SMS
2. **Duplicate Check**: Prevents duplicate entries using SMS hash
3. **Categorization**: Uses hybrid approach by default:
   - Rule-based check first (instant)
   - If uncertain → Gemini AI classification
   - Confidence score calculated
4. **Storage**: Saves to Firebase with category and confidence

## 🎯 Category Examples

| Category | Keywords | Examples |
|----------|----------|----------|
| **Food** | restaurant, cafe, zomato, swiggy | "Debited Rs.450 at DOMINOS PIZZA" |
| **Travel** | uber, taxi, flight, hotel, fuel | "Rs.280 debited for UBER TRIP" |
| **Work** | office, software, subscription | "Debited Rs.999 MICROSOFT OFFICE" |
| **Leisure** | movie, netflix, shopping, gym | "Rs.199 debited NETFLIX SUBSCRIPTION" |
| **Miscellaneous** | Everything else | Unknown or unclear expenses |

## 🔍 Confidence Scoring

Each categorization includes a confidence score:
- **High (80-100%)**: Strong keyword matches
- **Medium (50-79%)**: Some keyword matches
- **Low (30-49%)**: Weak or no keyword matches
- **AI Enhanced**: Gemini provides additional context

## 💡 Tips for Better Accuracy

1. **Use Hybrid Approach**: Best balance of speed and accuracy
2. **Configure Gemini**: For complex/ambiguous expenses
3. **Monitor Logs**: Check categorization results in console
4. **Manual Corrections**: Future versions will learn from your edits

## 🚀 Current Status

✅ **Implemented**:
- Rule-based categorization with 50+ keywords
- Gemini AI integration with free tier
- Hybrid approach combining both
- Confidence scoring system
- SMS hash-based duplicate detection
- Automatic category assignment

🔄 **In Progress**:
- Learning from user corrections
- Category confidence display in UI
- Manual category override option

## 🛠️ Technical Details

- **SMS Processing**: `lib/services/sms_listener.dart`
- **Categorization Logic**: `lib/services/expense_categorizer.dart`
- **API Configuration**: `lib/config/api_config.dart`
- **Models**: `lib/models/expense.dart`

The system processes SMS messages, extracts expense information, categorizes using AI/rules, and stores in Firebase with full duplicate prevention.