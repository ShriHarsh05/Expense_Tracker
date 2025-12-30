# Simplified System Architecture Diagram

## Easy-to-Draw Version for Research Paper

### Main Components (Top to Bottom):

```
┌─────────────────────────────────────────────────────────────┐
│                    SMS NOTIFICATIONS                        │
│  [HDFC] [AXIS] [PAYTM] [ICICI] [SBI] [PHONEPE] [GPAY]     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              LAYER 0: SECURITY VALIDATION                  │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │   ACCEPT    │    │  VALIDATE   │    │   REJECT    │    │
│  │ Bank Codes  │    │  Patterns   │    │ Phone Nums  │    │
│  │ Short Codes │    │             │    │ Fraud SMS   │    │
│  └─────────────┘    └─────────────┘    └─────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│            LAYER 1: MERCHANT DATABASE                      │
│                   (150+ Merchants)                         │
│                                                             │
│ [Food] [Shopping] [Transport] [Utilities] [Entertainment]  │
│  95%     93%        94%        91%         89%             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│           LAYER 2: KEYWORD ANALYSIS                        │
│                                                             │
│  Keywords → Weights → Context → Category Score             │
│                                                             │
│  High Weight: restaurant, fuel, movie                      │
│  Medium Weight: payment, bill, transfer                    │
│  Low Weight: service, charge, fee                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│            LAYER 3: SMART LEARNING                         │
│                                                             │
│  User Feedback → Feature Extraction → Similarity Match     │
│                                                             │
│  Features: Amount, Time, Day, Source                       │
│  Threshold: 70% similarity for auto-categorization         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              FLUTTER MOBILE APP                             │
│                                                             │
│  Local Processing | 12ms per SMS | <50MB Memory           │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │ SMS Scanner │    │ Categorizer │    │ UI Display  │    │
│  │ Permissions │    │ Duplicate   │    │ Analytics   │    │
│  │ Filtering   │    │ Detection   │    │ Learning    │    │
│  └─────────────┘    └─────────────┘    └─────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                FIREBASE CLOUD BACKEND                       │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │    AUTH     │    │  DATABASE   │    │  ANALYTICS  │    │
│  │ Google      │    │ Firestore   │    │ Performance │    │
│  │ OAuth 2.0   │    │ Expenses    │    │ Monitoring  │    │
│  │ Multi-device│    │ User Prefs  │    │ Usage Stats │    │
│  └─────────────┘    └─────────────┘    └─────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    RESULTS & INSIGHTS                       │
│                                                             │
│  94.2% Detection Accuracy | 89.7% Classification Accuracy  │
│  87% Manual Effort Reduction | 4.6/5.0 User Satisfaction  │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │  EXPENSE    │    │  ANALYTICS  │    │  LEARNING   │    │
│  │  TRACKING   │    │  DASHBOARD  │    │  FEEDBACK   │    │
│  └─────────────┘    └─────────────┘    └─────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Drawing Instructions for Professional Tools:

### 1. **Using Draw.io (Recommended - Free)**

**Step 1: Create Basic Layout**
- Open draw.io in browser
- Choose "Blank Diagram"
- Use "Basic Shapes" → Rectangle for main components
- Use "Arrows" → Block Arrow for data flow

**Step 2: Add Components**
- Create 7 main rectangular boxes (one for each layer)
- Add smaller rectangles inside for sub-components
- Use different colors: Blue for processing, Green for success, Red for rejection

**Step 3: Add Text and Icons**
- Insert text boxes with component names
- Add icons from "Icons" library (phone, shield, database, brain, cloud)
- Use "Flowchart" shapes for decision points

**Step 4: Style and Format**
- Set consistent fonts (Arial, 12pt for headers, 10pt for body)
- Apply color scheme: Blue (#2196F3), Green (#4CAF50), Orange (#FF9800)
- Add shadows and borders for professional look

### 2. **Using PowerPoint (Alternative)**

**Slide Layout:**
- Use "Blank" slide layout
- Insert → Shapes → Rectangles for components
- Insert → Icons for visual elements
- Format → Shape Styles for consistent appearance

**Text Formatting:**
- Headers: Bold, 14pt, Blue
- Body: Regular, 11pt, Black
- Metrics: Bold, 12pt, Green

### 3. **Using Canva (User-Friendly)**

**Template Selection:**
- Search "Flowchart" or "System Architecture"
- Choose professional business template
- Customize colors and text

**Elements to Add:**
- Shapes: Rectangles, arrows, icons
- Text: Headers, descriptions, metrics
- Colors: Professional blue/green scheme

## Key Visual Elements to Include:

### **Icons and Symbols:**
- 📱 Mobile phone (Input layer)
- 🔒 Shield (Security layer)
- 🏪 Database/Store (Merchant layer)
- 🔍 Magnifying glass (Keyword layer)
- 🧠 Brain (Learning layer)
- ⚙️ Gear (Processing layer)
- ☁️ Cloud (Backend layer)
- 📊 Chart (Results layer)

### **Color Coding:**
- **Blue (#2196F3)**: Main system components
- **Green (#4CAF50)**: Accepted/positive elements
- **Orange (#FF9800)**: Processing/active elements
- **Red (#F44336)**: Rejected/warning elements
- **Gray (#757575)**: Supporting text

### **Typography:**
- **Headers**: Arial Bold, 14pt
- **Subheaders**: Arial Bold, 12pt
- **Body text**: Arial Regular, 10pt
- **Metrics**: Arial Bold, 11pt, Green color

## Final Diagram Dimensions:
- **Width**: 8 inches (suitable for journal column)
- **Height**: 10 inches (fits on standard page)
- **Resolution**: 300 DPI for print quality
- **Format**: PNG or SVG for scalability

This simplified version maintains all the technical accuracy while being much easier to create in standard drawing tools. The visual hierarchy clearly shows the data flow from SMS input through the three-layer processing to final results.