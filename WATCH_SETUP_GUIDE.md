# Apple Watch Target Setup Guide

## Overview

The JARVIS Watch App source code is already created. You just need to add a Watch App target in Xcode and link the existing files.

---

## Prerequisites

- macOS with Xcode 15+ installed
- Apple Developer account (free tier is fine for testing)
- Apple Watch paired with your iPhone (for real device testing)

---

## Step-by-Step Instructions

### Step 1: Open the Project

1. Open `HeyJarvisApp.xcodeproj` in Xcode
2. Wait for indexing to complete

### Step 2: Add Watch App Target

1. Click **File** → **New** → **Target**
2. Select **watchOS** tab
3. Choose **App** (not App for Watch App Extension)
4. Click **Next**

### Step 3: Configure the Target

1. **Product Name**: `HeyJarvisWatch`
2. **Bundle Identifier**: `com.AI.Jarvis.watchkitapp`
3. **Language**: Swift
4. **User Interface**: SwiftUI
5. **Include Notification Scene**: Optional (uncheck for simplicity)
6. Click **Finish**

### Step 4: Delete Auto-Generated Files

Xcode creates placeholder files. Delete these from the new target:

- `ContentView.swift` (we have our own)
- `HeyJarvisWatchApp.swift` (we have our own)

### Step 5: Add Existing Watch Files

1. In the Project Navigator, right-click the `HeyJarvisWatch` folder
2. Click **Add Files to "HeyJarvisApp"**
3. Navigate to `HeyJarvisWatch/` folder in your project
4. Select these files:
   - `WatchApp.swift`
   - `WatchContentView.swift`
5. Make sure **"Add to targets"** has `HeyJarvisWatch` checked
6. Click **Add**

### Step 6: Configure Watch App Entry Point

1. Open `WatchApp.swift`
2. Make sure it contains `@main struct WatchApp: App`
3. Xcode should recognize this as the entry point

### Step 7: Build and Run

1. Select `HeyJarvisWatch` scheme from the scheme selector
2. Choose a Watch Simulator (e.g., "Apple Watch Series 9 - 45mm")
3. Click **Run** (⌘R)

---

## What the Watch App Does

| Feature            | Description                                           |
| ------------------ | ----------------------------------------------------- |
| **Tap to Listen**  | Taps the big button, sends "listen" command to iPhone |
| **Status Sync**    | Shows JARVIS listening state from iPhone              |
| **Last Command**   | Displays last spoken command                          |
| **Remote Control** | Stop listening from your wrist                        |

---

## Troubleshooting

### "No entry point" error

- Make sure `WatchApp.swift` has `@main` attribute

### Watch App doesn't sync with iPhone

- Both apps must be running
- iPhone app must have `WatchSessionManager` initialized (it is)
- Try restarting both apps

### Can't install on real Watch

- You need an Apple Developer account
- Enable "Automatically manage signing" in target settings

---

## Files Location

```
HeyJarvisWatch/
├── WatchApp.swift         # Entry point
└── WatchContentView.swift # UI + ViewModel
```

---

_Once set up, the Watch App will sync with your iPhone's JARVIS automatically!_
