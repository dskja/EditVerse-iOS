# EditVerse iOS

Native SwiftUI app: vertical short-form feed **only for edits** (gaming, anime, sports, cinema, music, cars) — original app, not a TikTok/Instagram mod.

Repo: https://github.com/dskja/EditVerse-iOS

## What you get

- Full-screen vertical swipe feed with looping video
- Categories, like / save / follow
- Discover grid + profile desk
- GitHub Actions workflow that:
  1. Always builds the iOS Simulator app
  2. Builds a signed **IPA** when Apple signing secrets are present

## Open in Xcode

1. Clone this repo on a Mac
2. Open `EditVerse.xcodeproj`
3. Set your **Team** under Signing & Capabilities
4. Run on a simulator or device (iOS 17+)

## Build IPA with GitHub Actions

### 1. Required Apple setup

You need an [Apple Developer](https://developer.apple.com) account and:

- Distribution (or development) certificate as `.p12`
- Matching provisioning profile for `com.editverse.app`
- Your Team ID

### 2. Add repository secrets

Settings → Secrets and variables → Actions:

| Secret | Description |
| --- | --- |
| `BUILD_CERTIFICATE_BASE64` | base64 of your `.p12` |
| `P12_PASSWORD` | password for the `.p12` |
| `BUILD_PROVISION_PROFILE_BASE64` | base64 of `.mobileprovision` |
| `KEYCHAIN_PASSWORD` | any strong password for the CI keychain |
| `APPLE_TEAM_ID` | 10-character Team ID |
| `EXPORT_METHOD` | optional: `ad-hoc`, `development`, `app-store`, or `enterprise` |

Encode files locally:

```bash
chmod +x scripts/encode-signing.sh
./scripts/encode-signing.sh ~/certs/editverse.p12 ~/certs/EditVerse.mobileprovision
```

### 3. Run the workflow

- Push to `main`, or
- Actions → **Build EditVerse IPA** → Run workflow

Artifacts:

- `EditVerse-simulator` — always
- `EditVerse-ipa` — only when signing secrets are set

Install ad-hoc IPAs with Apple Configurator, Xcode, or a device UDID listed in the provisioning profile.

## Bundle ID

`com.editverse.app` — change in Xcode / `project.pbxproj` if needed.

## Note on signing

Without Apple certificates, CI still compiles for Simulator. A real-device IPA **must** be signed; GitHub Actions cannot create Apple credentials for you.
