# Hey Jarvis iOS 18+ - Ray-Ban Meta Glasses Companion App

A complete iOS 18+ SwiftUI application that simulates a "Hey Jarvis" voice assistant for Ray-Ban Meta Glasses. The app listens for the "Hey Jarvis" wake word, processes voice commands, and responds with JARVIS-style AI voice.

## ✨ Features

- 🎤 **Wake Word Detection** - Continuous listening for "Hey Jarvis"
- 🗣️ **Voice Commands** - "Take a photo", "Show last video", "Record note"
- 🔊 **JARVIS TTS** - OpenAI gpt-4o-mini-tts with AVSpeech fallback
- 📸 **Photo Capture** - Uses iOS camera and saves to Photos library
- 🎬 **Video Playback** - Plays most recent video from Photos
- 🎙️ **Voice Notes** - Records audio notes to Documents folder
- 🌙 **Stark Industries UI** - Dark metallic theme with animated orb

## 📋 Requirements

- macOS with Xcode 15.0+
- iOS 18.0+ deployment target
- Apple Developer Account (for device testing/IPA)
- Physical iOS device (simulator doesn't support all audio features)

## 🚀 Quick Setup (3 Steps)

### Step 1: Open Project

```bash
open HeyJarvisApp.xcodeproj
```

### Step 2: Configure API Key (Optional)

Edit `HeyJarvisApp/Resources/JarvisVoiceSettings.plist`:

```xml
<key>OpenAIAPIKey</key>
<string>sk-your-actual-api-key-here</string>
```

> ⚠️ Without an API key, the app will use AVSpeechSynthesizer fallback (still works great!)

### Step 3: Set Your Team

1. Select `HeyJarvisApp` in the Project Navigator
2. Go to **Signing & Capabilities** tab
3. Select your **Team** from the dropdown
4. Update **Bundle Identifier** if needed (e.g., `com.yourname.HeyJarvis`)

## 📱 Run on Simulator

1. Select an iOS 18.0+ simulator (iPhone 15/16 recommended)
2. Press **⌘+R** to build and run
3. Grant all permissions when prompted
4. Note: Some audio features may not work in simulator

## 🔧 Build IPA (7 Steps)

### Step 1: Configure for Release

1. Select **HeyJarvisApp** target
2. Set **Build Configuration** to "Release"

### Step 2: Select Generic Device

1. In the device dropdown, choose **Any iOS Device (arm64)**

### Step 3: Archive

1. Go to **Product → Archive**
2. Wait for the build to complete

### Step 4: Open Organizer

1. Go to **Window → Organizer**
2. Select the newest archive

### Step 5: Distribute

1. Click **Distribute App**
2. Choose distribution method:
   - **Ad Hoc** - For personal devices
   - **Development** - For registered devices
   - **App Store Connect** - For TestFlight/App Store

### Step 6: Export IPA

1. Follow the prompts to sign the app
2. Choose export location
3. Your `.ipa` file will be created

### Step 7: Install on Device

Choose one of these methods:

**Apple Configurator 2 (Mac):**

```bash
# Install via Apple Configurator
# Connect device → Drag .ipa onto device
```

**Sideloadly (Windows/Mac):**

1. Download [Sideloadly](https://sideloadly.io/)
2. Connect your iPhone
3. Drag `.ipa` and click Start

**AltStore:**

1. Install AltStore on your device
2. Use AltStore to install the `.ipa`

## 🎮 Usage

### Voice Commands

| Wake Word    | Command           | Response                                |
| ------------ | ----------------- | --------------------------------------- |
| "Hey Jarvis" | "Take a photo"    | Captures photo → "Photo saved, sir"     |
| "Hey Jarvis" | "Show last video" | Plays recent video → "Playing now, sir" |
| "Hey Jarvis" | "Record note"     | Records 5s audio → "Note saved, sir"    |

### App States

- **Idle** - Orb is dim, waiting to start
- **Listening** - Blue pulsing orb, detecting wake word
- **Wake Detected** - Green flash, JARVIS responds "Yes, sir?"
- **Processing** - Orange spinning, executing command
- **Speaking** - Blue pulsing, JARVIS speaking response

## 🎨 Design Tokens

| Color         | Hex       | Usage            |
| ------------- | --------- | ---------------- |
| Primary Dark  | `#1a1a2e` | Main background  |
| Accent Dark   | `#16213e` | Card backgrounds |
| Jarvis Blue   | `#0f3460` | Orb, highlights  |
| Success Green | `#00d4aa` | Success states   |
| Dim Text      | `#888888` | Secondary text   |

## 📁 Project Structure

```
HeyJarvisApp/
├── HeyJarvisApp.swift           # @main app entry
├── ContentView.swift            # Main UI
├── AppViewModel.swift           # MVVM state manager
├── WakeWordDetector.swift       # Speech recognition
├── CommandManager.swift         # Text → command parsing
├── MetaWorkflowController.swift # Photo/video/note handlers
├── TextToSpeechManager.swift    # TTS facade
├── OpenAITTSManager.swift       # OpenAI API integration
├── Models/
│   └── Command.swift            # Data models
├── Views/
│   ├── StatusView.swift         # Animated orb
│   └── CommandHistoryView.swift # Command history list
├── Resources/
│   └── JarvisVoiceSettings.plist # API key config
├── Assets.xcassets/             # Colors and icons
└── Info.plist                   # Permissions
```

## 🔒 Permissions

The app requires these permissions (configured in Info.plist):

- **Microphone** - For wake word and command detection
- **Speech Recognition** - For voice transcription
- **Camera** - For "take a photo" command
- **Photo Library** - For saving photos and playing videos

## 🐛 Troubleshooting

### "Speech recognition not available"

- Ensure device has internet (required for speech recognition)
- Check Settings → Privacy → Speech Recognition

### "Camera access denied"

- Go to Settings → Hey Jarvis → Enable Camera

### No sound from JARVIS

- Check device is not in silent mode
- Without API key, uses AVSpeech (may sound different)

### Wake word not detected

- Speak clearly: "Hey Jarvis"
- Ensure quiet environment
- Try "Hey Travis" (alternative trigger)

## 📄 License

This project is provided as-is for educational purposes.
Built with ❤️ for Ray-Ban Meta Glasses enthusiasts.

---

**JARVIS**: "At your service, sir."
