# 🤖 Smart Expense Tracker

An AI-powered expense tracking app with SMS auto-categorization and machine learning capabilities, optimized for the Indian market.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

## ✨ Features

### 🧠 **AI-Powered Categorization**
- **Three-Layer Hybrid Approach**: Enhanced Indian merchant database → Foursquare API → Keyword analysis
- **150+ Indian Merchants**: Optimized for Swiggy, Zomato, Uber, Amazon, Flipkart, and more
- **93.4% Accuracy**: Research-backed categorization system
- **Sub-5ms Response Time**: Lightning-fast local processing

### 📱 **SMS Auto-Detection**
- **Automatic SMS Scanning**: Detects expense transactions from SMS
- **Wallet Support**: MobiKwik, Paytm, PhonePe, GPay, and all major Indian wallets
- **Real-time Processing**: Captures new expenses as SMS arrives
- **Duplicate Prevention**: Advanced duplicate detection with SMS hashing

### 🎯 **Smart Learning System**
- **Machine Learning**: Learns from user categorization preferences
- **Auto-Categorization**: Similar transactions categorized automatically
- **Smart Thresholds**: Intelligent prompting for Miscellaneous expenses
- **Pattern Recognition**: Recognizes spending patterns and habits

### 🔒 **Privacy & Security**
- **Local Processing**: SMS analyzed locally, never transmitted
- **Firebase Security**: Enterprise-grade cloud storage
- **User Isolation**: Complete data separation between users
- **No Data Sharing**: Zero cross-user data sharing

## 🚀 **Getting Started**

### Prerequisites
- Flutter SDK (>=3.4.1)
- Android SDK (API 21+)
- Firebase project setup
- Google Services configuration

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ShriHarsh05/Expense_Tracker.git
   cd Expense_Tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` to `android/app/`
   - Update Firebase configuration in the project

4. **Set up signing (for release)**
   - Create `android/key.properties`
   - Add your signing key as `android/key.jks`

5. **Run the app**
   ```bash
   flutter run
   ```

## 📊 **Architecture**

### **Core Components**
- **SMS Listener**: Scans and processes SMS messages
- **Expense Categorizer**: Three-layer categorization system
- **Smart Categorizer**: Machine learning and pattern recognition
- **Firebase Integration**: Cloud storage and synchronization

### **Key Services**
- `sms_listener.dart` - SMS processing and expense detection
- `expense_categorizer.dart` - Hybrid categorization engine
- `smart_categorizer.dart` - Learning and pattern matching
- `auth_service.dart` - Google authentication

## 🎯 **Smart Categorization System**

### **Layer 0: Enhanced Indian Merchant Database**
```dart
// 150+ Indian merchants with high accuracy
'swiggy' → Food (100% confidence)
'uber' → Travel (98% confidence)
'amazon' → Leisure (95% confidence)
```

### **Layer 1: Foursquare API Fallback**
- Real-time merchant lookup
- Location-based categorization
- International merchant support

### **Layer 2: Keyword Analysis**
- Context-aware keyword scoring
- Transaction pattern recognition
- Fallback categorization

## 🧠 **Machine Learning Features**

### **Learning Pattern Structure**
```json
{
  "features": {
    "amountRange": "small|medium|large|xlarge",
    "timeRange": "morning|afternoon|evening|night",
    "smsSource": "mobikwik|paytm|phonepe|bank",
    "transactionType": "wallet|upi|card|atm"
  },
  "category": "Food",
  "confidence": 0.85,
  "usageCount": 3
}
```

### **Smart Thresholds**
- **Don't Prompt**: ≤₹10, ATM withdrawals, bank fees, late night small transactions
- **Do Prompt**: ≥₹100, recurring patterns, merchant info available, peak hours

## 📱 **Supported Platforms**

- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 11.0+ (planned)
- **Web**: Progressive Web App (planned)

## 🔧 **Build & Release**

### **Debug Build**
```bash
flutter build apk --debug
```

### **Release Build**
```bash
# App Bundle for Play Store
flutter build appbundle --release

# APK for testing
flutter build apk --release --split-per-abi
```

### **Available Scripts**
- `build_release.bat` - Automated release build
- `install_apk.bat` - APK installation helper

## 📊 **Performance Metrics**

- **Categorization Accuracy**: 93.4%
- **Response Time**: <5ms (local processing)
- **Memory Usage**: <50MB average
- **Battery Impact**: Minimal (background SMS processing)
- **Storage**: ~45MB app size

## 🇮🇳 **Indian Market Optimization**

### **Supported Payment Methods**
- **Wallets**: MobiKwik, Paytm, PhonePe, GPay, Amazon Pay
- **Banks**: All major Indian banks (SBI, HDFC, ICICI, Axis, etc.)
- **UPI**: All UPI-based transactions
- **Cards**: Debit/Credit card transactions

### **Merchant Categories**
- **Food**: Swiggy, Zomato, Dominos, McDonald's, KFC
- **Travel**: Uber, Ola, IRCTC, MakeMyTrip, Goibibo
- **Shopping**: Amazon, Flipkart, Myntra, BigBasket
- **Entertainment**: Netflix, Hotstar, Spotify, BookMyShow
- **Utilities**: Electricity, Gas, Mobile recharge

## 📚 **Documentation**

- [`LEARNING_WORKFLOW.md`](LEARNING_WORKFLOW.md) - Machine learning system details
- [`EXPENSE_CATEGORIZATION.md`](EXPENSE_CATEGORIZATION.md) - Categorization logic
- [`MISCELLANEOUS_THRESHOLDS.md`](MISCELLANEOUS_THRESHOLDS.md) - Smart threshold system
- [`PUBLICATION_GUIDE.md`](PUBLICATION_GUIDE.md) - Play Store publication guide
- [`research_paper/`](research_paper/) - Academic research and experimental data

## 🔬 **Research & Publications**

This project includes research-grade documentation and experimental data suitable for academic publication:

- **Springer LNCS Format Paper**: Complete research paper with methodology and results
- **Experimental Data**: Performance metrics and accuracy measurements
- **Novel Approach**: First-of-its-kind SMS-based expense categorization system

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 **Acknowledgments**

- **Firebase**: For robust backend infrastructure
- **Flutter Team**: For the amazing cross-platform framework
- **Foursquare API**: For merchant categorization fallback
- **Indian Banking System**: For standardized SMS formats

## 📞 **Support**

- **Issues**: [GitHub Issues](https://github.com/ShriHarsh05/Expense_Tracker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ShriHarsh05/Expense_Tracker/discussions)
- **Email**: [Your support email]

## 🚀 **Roadmap**

### **v1.1.0 (Planned)**
- [ ] Export data functionality
- [ ] Advanced analytics dashboard
- [ ] Custom category creation
- [ ] Spending limits and alerts

### **v1.2.0 (Planned)**
- [ ] iOS support
- [ ] Web dashboard
- [ ] Multi-language support
- [ ] Voice-based expense entry

### **v2.0.0 (Future)**
- [ ] Investment tracking
- [ ] Bill reminders
- [ ] Family expense sharing
- [ ] AI-powered financial insights

---

**Made with ❤️ for the Indian fintech ecosystem**

*Revolutionizing expense tracking with AI and machine learning*