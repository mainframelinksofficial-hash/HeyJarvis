# GitHub Actions IPA Build Guide

This guide explains how to build your Hey Jarvis IPA using GitHub Actions (free, no Mac required!).

## Quick Start (5 Minutes)

### Step 1: Create GitHub Repository

1. Go to [github.com/new](https://github.com/new)
2. Name it `HeyJarvis` (or anything you like)
3. Set to **Private** (recommended)
4. Click **Create repository**

### Step 2: Push Code to GitHub

Open PowerShell/Terminal in the `Meta` folder and run:

```powershell
cd "C:\Users\jacob\Downloads\Meta"

# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - Hey Jarvis iOS app"

# Add your GitHub repo (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/HeyJarvis.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Wait for Build

1. Go to your GitHub repo
2. Click **Actions** tab
3. Watch the "Build Hey Jarvis IPA" workflow run
4. Takes ~5-10 minutes

### Step 4: Download IPA

1. Once the workflow shows ✅ green checkmark
2. Click on the completed workflow run
3. Scroll to **Artifacts** section
4. Download **HeyJarvisApp-IPA**
5. Extract the zip → you have your `.ipa` file!

---

## Installing the Unsigned IPA

Since the IPA is unsigned, use one of these methods:

### Option A: Sideloadly (Recommended)

1. Download [Sideloadly](https://sideloadly.io/)
2. Connect your iPhone via USB
3. Drag the `.ipa` file into Sideloadly
4. Enter your Apple ID (creates a 7-day certificate)
5. Click Start

### Option B: AltStore

1. Install [AltStore](https://altstore.io/) on your iPhone
2. Transfer IPA to phone via AirDrop/Files
3. Open with AltStore to install

### Option C: TrollStore (Jailbroken/Exploited devices)

1. If you have TrollStore installed
2. Just open the IPA with TrollStore
3. Installs permanently without signing

---

## Optional: Signed Builds (Permanent Install)

For a properly signed IPA that doesn't expire, add these GitHub Secrets:

### Required Secrets

Go to **Settings → Secrets → Actions** and add:

| Secret Name                   | Description                                |
| ----------------------------- | ------------------------------------------ |
| `BUILD_CERTIFICATE_BASE64`    | Your .p12 certificate, base64 encoded      |
| `P12_PASSWORD`                | Password for the .p12 file                 |
| `PROVISIONING_PROFILE_BASE64` | Your .mobileprovision file, base64 encoded |
| `DEVELOPMENT_TEAM`            | Your 10-character Team ID                  |
| `KEYCHAIN_PASSWORD`           | Any random password for temp keychain      |

### Enable Signed Builds

Add a **Repository Variable** (Settings → Variables):

- Name: `ENABLE_SIGNING`
- Value: `true`

### How to Get Certificates

1. **Apple Developer Account** ($99/year) at [developer.apple.com](https://developer.apple.com)
2. Go to **Certificates, IDs & Profiles**
3. Create a **Development Certificate**
4. Create an **App ID** for `com.yourname.HeyJarvis`
5. Create a **Development Provisioning Profile**
6. Download both files

### Encode Files for Secrets

On Mac/Linux:

```bash
base64 -i certificate.p12 | pbcopy  # Copies to clipboard
base64 -i profile.mobileprovision | pbcopy
```

On Windows (PowerShell):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.p12")) | Set-Clipboard
[Convert]::ToBase64String([IO.File]::ReadAllBytes("profile.mobileprovision")) | Set-Clipboard
```

---

## Troubleshooting

### Build Failed: "Code signing required"

- This is expected for unsigned builds, the workflow handles it
- Check the "Artifacts" section, IPA should still be there

### Build Failed: "Scheme not found"

- Make sure the `.xcodeproj` folder is in the repo root
- Check that `xcshareddata/xcschemes/HeyJarvisApp.xcscheme` exists

### Can't find Artifacts

- Artifacts are only available for 30 days
- Make sure the build completed successfully (green checkmark)

### App crashes on device

- Unsigned apps need to be sideloaded properly
- Trust the developer in Settings → General → Device Management

---

## Links

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Sideloadly](https://sideloadly.io/)
- [AltStore](https://altstore.io/)
- [Apple Developer Program](https://developer.apple.com/programs/)
