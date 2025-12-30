# System Architecture Diagram Specifications

## Figure 1: Overall System Architecture

### ASCII Diagram (Text-based representation):

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           INTELLIGENT SMS EXPENSE TRACKER                        │
│                              SYSTEM ARCHITECTURE                                │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                                 INPUT LAYER                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│  📱 SMS NOTIFICATIONS                                                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │
│  │   HDFC      │  │    AXIS     │  │   PAYTM     │  │   ICICI     │           │
│  │  HDFCBK     │  │   AXISBK    │  │   PAYTM     │  │   ICICIB    │           │
│  │ Rs.500 deb  │  │ Spent INR   │  │ Rs.150 deb  │  │ Rs.1200 sp  │           │
│  │ at SWIGGY   │  │ 4006.35 at  │  │ from wallet │  │ on AMAZON   │           │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘           │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            LAYER 0: SECURITY VALIDATION                        │
├─────────────────────────────────────────────────────────────────────────────────┤
│  🔒 AUTHENTIC SENDER VALIDATION                                                 │
│                                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐            │
│  │   ACCEPT ✅     │    │   PATTERNS      │    │   REJECT ❌     │            │
│  │                 │    │                 │    │                 │            │
│  │ • 4-6 digits    │    │ • Bank codes    │    │ • Phone numbers │            │
│  │   (56767)       │    │   (HDFCBK)      │    │   (+91xxxxxxx)  │            │
│  │ • Alphanumeric  │    │ • Wallet codes  │    │ • 800 numbers   │            │
│  │   (AXISBK)      │    │   (VM-MOBIKW-)  │    │ • Invalid chars │            │
│  │ • Extended      │    │ • Short codes   │    │ • Personal names│            │
│  │   (PAYTM-ZOMATO)│    │   (92665)       │    │   (JOHN, ADMIN) │            │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘            │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        LAYER 1: MERCHANT DATABASE                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│  🏪 INDIAN MERCHANT RECOGNITION (150+ Merchants)                               │
│                                                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────┐ │
│  │FOOD & DINING│ │ E-COMMERCE  │ │TRANSPORTATION│ │  UTILITIES  │ │ENTERTAINMENT│
│  │             │ │             │ │             │ │             │ │          │ │
│  │• Zomato     │ │• Amazon     │ │• Uber       │ │• Airtel     │ │• Netflix │ │
│  │• Swiggy     │ │• Flipkart   │ │• Ola        │ │• Jio        │ │• Spotify │ │
│  │• Dominos    │ │• Myntra     │ │• IRCTC      │ │• BSNL       │ │• BookMyShow│
│  │• McDonald's │ │• BigBasket  │ │• RedBus     │ │• Indian Oil │ │• Prime   │ │
│  │• KFC        │ │• Nykaa      │ │• Metro      │ │• HP Gas     │ │• Hotstar │ │
│  │             │ │             │ │             │ │             │ │          │ │
│  │ 95% Accuracy│ │ 93% Accuracy│ │ 94% Accuracy│ │ 91% Accuracy│ │89% Accuracy│
│  │ <5ms Response│ │ <5ms Response│ │ <5ms Response│ │ <5ms Response│ │<5ms Response│
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └──────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                      LAYER 2: CONTEXTUAL KEYWORD ANALYSIS                      │
├─────────────────────────────────────────────────────────────────────────────────┤
│  🔍 WEIGHTED KEYWORD SCORING                                                    │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                        KEYWORD SCORING ALGORITHM                            │ │
│  │                                                                             │ │
│  │  Input: SMS Text T, Categories C                                            │ │
│  │  Output: Category with highest score                                        │ │
│  │                                                                             │ │
│  │  1. Initialize Score[i] = 0 for all categories                             │ │
│  │  2. For each category C[i]:                                                 │ │
│  │     For each keyword K in C[i]:                                             │ │
│  │       If K found in T:                                                      │ │
│  │         Score[i] += Weight(K) × Context_Factor(K,T)                        │ │
│  │  3. Return category with max(Score)                                         │ │
│  │                                                                             │ │
│  │  Weights: High=3.0, Medium=2.0, Low=1.0                                    │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐              │
│  │HIGH WEIGHT  │ │MEDIUM WEIGHT│ │ LOW WEIGHT  │ │ CONTEXT     │              │
│  │Keywords     │ │Keywords     │ │Keywords     │ │ FACTORS     │              │
│  │             │ │             │ │             │ │             │              │
│  │• restaurant │ │• payment    │ │• service    │ │• Time of day│              │
│  │• fuel       │ │• bill       │ │• charge     │ │• Amount     │              │
│  │• movie      │ │• transfer   │ │• fee        │ │• Frequency  │              │
│  │• grocery    │ │• purchase   │ │• transaction│ │• Location   │              │
│  │• medicine   │ │• booking    │ │• debit      │ │• Pattern    │              │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘              │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                       LAYER 3: SMART LEARNING SYSTEM                          │
├─────────────────────────────────────────────────────────────────────────────────┤
│  🧠 ADAPTIVE USER FEEDBACK LEARNING                                            │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                         FEATURE EXTRACTION                                  │ │
│  │                                                                             │ │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │ │
│  │  │   AMOUNT    │ │    TIME     │ │    DAY      │ │   SOURCE    │          │ │
│  │  │   RANGES    │ │  PATTERNS   │ │  PATTERNS   │ │  PATTERNS   │          │ │
│  │  │             │ │             │ │             │ │             │          │ │
│  │  │• ₹0-100     │ │• Morning    │ │• Weekday    │ │• Bank SMS   │          │ │
│  │  │• ₹100-500   │ │• Afternoon  │ │• Weekend    │ │• Wallet SMS │          │ │
│  │  │• ₹500-2000  │ │• Evening    │ │• Holiday    │ │• Card SMS   │          │ │
│  │  │• ₹2000+     │ │• Night      │ │• Festival   │ │• UPI SMS    │          │ │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘          │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                      SIMILARITY MATCHING                                    │ │
│  │                                                                             │ │
│  │  Cosine Similarity: sim(t1,t2) = (f1·f2) / (||f1|| × ||f2||)              │ │
│  │                                                                             │ │
│  │  If similarity > 0.7: Auto-categorize based on previous correction         │ │
│  │  If similarity < 0.7: Prompt user for categorization                       │ │
│  │                                                                             │ │
│  │  Learning Database:                                                         │ │
│  │  • User corrections stored with feature vectors                            │ │
│  │  • Continuous improvement over time                                         │ │
│  │  • Personalized categorization patterns                                     │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            PROCESSING ENGINE                                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│  ⚙️ FLUTTER MOBILE APPLICATION                                                  │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐ │
│  │                         LOCAL PROCESSING                                    │ │
│  │                                                                             │ │
│  │  📱 ON-DEVICE COMPONENTS:                                                   │ │
│  │  • SMS Permission Manager                                                   │ │
│  │  • Message Scanner (last 7 days, max 50 messages)                          │ │
│  │  • Amount Extraction Engine (Regex patterns)                               │ │
│  │  • Three-layer Categorization Pipeline                                     │ │
│  │  • Duplicate Detection & Prevention                                         │ │
│  │  • Local Data Cache & Synchronization                                       │ │
│  │                                                                             │ │
│  │  ⚡ PERFORMANCE METRICS:                                                    │ │
│  │  • Average Processing Time: 12ms per SMS                                   │ │
│  │  • Memory Usage: <50MB during operation                                    │ │
│  │  • Battery Impact: <2% per day                                             │ │
│  │  • Offline Capability: Core functions work without internet               │ │
│  └─────────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              CLOUD BACKEND                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│  ☁️ FIREBASE INFRASTRUCTURE                                                     │
│                                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐            │
│  │  AUTHENTICATION │    │    DATABASE     │    │   ANALYTICS     │            │
│  │                 │    │                 │    │                 │            │
│  │ • Google OAuth  │    │ • Cloud         │    │ • Performance   │            │
│  │ • User Sessions │    │   Firestore     │    │   Monitoring    │            │
│  │ • Security      │    │ • Expense Data  │    │ • Usage Stats   │            │
│  │   Tokens        │    │ • User Prefs    │    │ • Error Logs    │            │
│  │ • Multi-device  │    │ • Learning      │    │ • Crash Reports │            │
│  │   Sync          │    │   Patterns      │    │ • A/B Testing   │            │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘            │
│                                                                                 │
│  🔒 SECURITY & PRIVACY:                                                         │
│  • End-to-end encryption for all data transmission                             │
│  • SMS content never leaves device (ephemeral processing)                      │
│  • Only extracted expense metadata synchronized                                 │
│  • GDPR/CCPA compliant data handling                                           │
│  • User consent management                                                      │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                               OUTPUT LAYER                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│  📊 USER INTERFACE & INSIGHTS                                                  │
│                                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐            │
│  │   EXPENSE       │    │   ANALYTICS     │    │   LEARNING      │            │
│  │   TRACKING      │    │   DASHBOARD     │    │   INTERFACE     │            │
│  │                 │    │                 │    │                 │            │
│  │ • Real-time     │    │ • Category      │    │ • User Feedback │            │
│  │   Detection     │    │   Breakdown     │    │ • Correction    │            │
│  │ • Auto          │    │ • Spending      │    │   Interface     │            │
│  │   Categorization│    │   Trends        │    │ • Learning      │            │
│  │ • Manual        │    │ • Monthly       │    │   Progress      │            │
│  │   Override      │    │   Reports       │    │ • Accuracy      │            │
│  │ • Search &      │    │ • Budget        │    │   Metrics       │            │
│  │   Filter        │    │   Insights      │    │ • Suggestions   │            │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘            │
│                                                                                 │
│  📈 PERFORMANCE RESULTS:                                                        │
│  • 94.2% Expense Detection Accuracy                                            │
│  • 89.7% Category Classification Accuracy                                      │
│  • 87% Reduction in Manual Effort                                              │
│  • 4.6/5.0 User Satisfaction Rating                                            │
│  • 91% Users Find Categorization Accurate                                      │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                              DATA FLOW LEGEND                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│  📱 SMS Input → 🔒 Security → 🏪 Merchant DB → 🔍 Keywords → 🧠 Learning       │
│                                                                                 │
│  ✅ Accepted SMS    ❌ Rejected SMS    ⚡ Fast Processing    🔒 Secure          │
│  📊 Analytics       🧠 AI Learning     ☁️ Cloud Sync       📱 Mobile App       │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## Visual Diagram Specifications for Professional Creation:

### Components and Layout:

1. **Input Layer (Top)**
   - SMS notification icons from different banks
   - Color coding: Blue for banks, Green for wallets
   - Sample SMS text snippets

2. **Security Layer (Layer 0)**
   - Shield icon with checkmark
   - Three columns: Accept (Green), Patterns (Blue), Reject (Red)
   - Clear visual separation

3. **Merchant Database (Layer 1)**
   - Database icon with merchant categories
   - Five category boxes with representative logos
   - Performance metrics below each category

4. **Keyword Analysis (Layer 2)**
   - Magnifying glass icon
   - Algorithm flowchart in center
   - Keyword weight visualization (different sizes/colors)

5. **Smart Learning (Layer 3)**
   - Brain icon with neural network pattern
   - Feature extraction boxes
   - Similarity calculation formula

6. **Processing Engine (Middle)**
   - Mobile phone icon with Flutter logo
   - Performance metrics in sidebar
   - Local processing emphasis

7. **Cloud Backend (Bottom)**
   - Cloud icon with Firebase logo
   - Three service boxes with icons
   - Security badges

8. **Output Layer (Bottom)**
   - Dashboard mockup screenshots
   - Performance results in highlighted boxes
   - User interface elements

### Color Scheme:
- **Primary**: Blue (#2196F3) for system components
- **Secondary**: Green (#4CAF50) for accepted/positive elements
- **Accent**: Orange (#FF9800) for processing/active elements
- **Warning**: Red (#F44336) for rejected/negative elements
- **Background**: Light gray (#F5F5F5) with white component boxes

### Typography:
- **Headers**: Bold, 14pt
- **Body text**: Regular, 10pt
- **Metrics**: Bold, 12pt
- **Code/Technical**: Monospace, 9pt

### Icons to Include:
- 📱 Mobile phone, 🔒 Security shield, 🏪 Store/merchant, 🔍 Magnifying glass
- 🧠 Brain, ⚙️ Gear, ☁️ Cloud, 📊 Chart, ✅ Checkmark, ❌ X mark

This diagram can be created using tools like:
- **Draw.io** (free, web-based)
- **Lucidchart** (professional)
- **Microsoft Visio** (enterprise)
- **Adobe Illustrator** (design-focused)
- **Figma** (collaborative design)