# BodyReader — iOS App Setup Guide

## What's Built
A complete SwiftUI iOS app that:
- Captures a photo of any body part (face, palm, tongue, eye, nails)
- Sends it to Claude Vision AI for analysis
- Returns a detailed, zone-by-zone reading with infographic layout
- Gives 1 free reading per user, then charges $0.99 per reading
- Uses StoreKit 2 for in-app purchases

---

## Step 1: Prerequisites
- Mac with Xcode 15+ installed
- Apple Developer account ($99/year) — required for App Store
- Anthropic API key — get one at console.anthropic.com

---

## Step 2: Create the Xcode Project

1. Open Xcode → **File → New → Project**
2. Choose **iOS → App**
3. Set:
   - Product Name: `BodyReader`
   - Bundle Identifier: `com.yourname.bodyreader` *(you'll change this)*
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum Deployments: **iOS 16.0**
4. Save it alongside this `BodyReader/` folder (or inside it)

---

## Step 3: Add Source Files

Copy all `.swift` files from this repo into your Xcode project, maintaining the folder structure:

```
BodyReader/
├── App/
│   └── BodyReaderApp.swift
├── Models/
│   ├── BodyPart.swift
│   └── BodyReading.swift
├── Views/
│   ├── ContentView.swift
│   ├── HomeView.swift
│   ├── ScanView.swift
│   ├── LoadingView.swift
│   ├── ResultView.swift
│   ├── PaywallView.swift
│   └── Components/
│       ├── BodyPartCard.swift
│       └── ReadingSectionView.swift
├── Services/
│   ├── ClaudeService.swift
│   ├── PurchaseManager.swift
│   └── UsageManager.swift
└── Helpers/
    ├── Extensions.swift
    └── ImagePicker.swift
```

In Xcode: drag files into the navigator, check **"Add to target: BodyReader"** for each.

---

## Step 4: Add Resource Files

1. **Config.plist** — Add to project (do NOT commit with real key)
   - Open `Config.plist` and replace `YOUR_API_KEY_HERE` with your Anthropic API key
   - Add `Config.plist` to `.gitignore`

2. **Info.plist** — Merge camera/photo permissions into your existing Info.plist:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>BodyReader needs camera access to photograph your body part for analysis.</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>BodyReader needs photo library access so you can select an existing photo.</string>
   ```

3. **StoreKit.storekit** — Add to project for local testing:
   - In Xcode: Edit Scheme → Run → Options → StoreKit Configuration → select `StoreKit.storekit`

---

## Step 5: Configure App Store Connect

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Create a new app: **BodyReader**, Bundle ID matching your project
3. Under **In-App Purchases**, create:
   - Type: **Non-Consumable**
   - Product ID: `com.bodyreader.app.reading`
   - Price: **$0.99**
   - Display Name: `Single Reading`
   - Description: `Unlock a detailed AI-powered analysis of your chosen body part.`

> **Important:** The product ID in App Store Connect must exactly match `com.bodyreader.app.reading` (defined in `PurchaseManager.swift`). Change it if you use a different bundle ID.

---

## Step 6: API Key Security

The current implementation reads the API key from `Config.plist` (client-side). This is acceptable for initial launch but the key can be extracted from the binary.

**For production**, replace `ClaudeService.swift` with a call to your own backend endpoint that proxies to Anthropic:
```
User → Your backend (holds API key) → Anthropic API → User
```
A simple Cloudflare Worker or Supabase Edge Function works well for this at minimal cost.

---

## Step 7: Build & Test

```bash
# In Xcode:
# Product → Run (⌘R) on Simulator or device
```

Test checklist:
- [ ] Home screen shows all 5 body parts
- [ ] Camera and photo library open correctly
- [ ] Free reading works (no paywall on first tap)
- [ ] Paywall appears after free reading used
- [ ] Reading result displays correctly
- [ ] StoreKit sandbox purchase works (use test account)

---

## Step 8: App Store Submission

1. Set version `1.0` and build number `1` in Xcode project settings
2. Select **Any iOS Device** as target
3. **Product → Archive**
4. In Organizer, click **Distribute App → App Store Connect**
5. In App Store Connect, add:
   - Screenshots (6.7" and 5.5" required)
   - App description, keywords, category: **Health & Fitness**
   - Age rating, privacy policy URL (required)
   - Price: $0.00 (free download, $0.99 in-app)

---

## App Store Description (Suggested)

**BodyReader — Ancient Wisdom, Modern Vision**

Discover what your body reveals. BodyReader uses advanced AI to analyze your face, palm, tongue, eyes, and nails — delivering detailed readings inspired by centuries of traditional interpretation.

• Face Reading — Physiognomy & structural analysis
• Palm Reading — Life, head, heart, and fate lines
• Tongue Analysis — Traditional Chinese Medicine mapping
• Eye Reading — Iridology zone analysis
• Nail Reading — Character and energy insights

Your first reading is FREE. Additional readings unlock for $0.99 each.

*For entertainment and self-reflection purposes. Not a medical diagnosis.*

---

## Privacy Policy (Required)

You need a hosted privacy policy. Key points to include:
- Photos are sent to Anthropic's API for analysis and are not stored
- No account or personal data is collected
- Usage count stored locally on device only
- Payments processed by Apple

---

## Cost Estimate (per reading to you)
- Claude Sonnet 4.6 + vision: ~$0.01–0.03 per reading
- Revenue per reading: $0.99 × 0.70 (Apple 30%) = **$0.69**
- Gross margin per reading: **~$0.66–0.68**

---

## Folder Structure Reference

```
ios/BodyReader/
├── SETUP.md                    ← This file
└── BodyReader/
    ├── App/BodyReaderApp.swift  ← @main entry point
    ├── Models/                  ← Data + Claude prompts
    ├── Views/                   ← All SwiftUI screens
    ├── Services/                ← Claude API, StoreKit, Usage tracking
    ├── Helpers/                 ← Extensions, ImagePicker
    └── Resources/               ← Config.plist, Info.plist, StoreKit config
```
