# EditVerse iOS

Native SwiftUI app: vertical short-form feed **only for edits** (gaming, anime, sports, cinema, music, cars) — original app, not a TikTok/Instagram mod.

Repo: https://github.com/dskja/EditVerse-iOS

## What you get

- Full-screen vertical swipe feed with looping video
- Categories, like / save / follow
- Discover grid + profile desk
- GitHub Actions workflow that builds an **unsigned IPA** (no Apple certs required)

## Open in Xcode

1. Clone this repo on a Mac
2. Open `EditVerse.xcodeproj`
3. Set your **Team** under Signing & Capabilities (only needed for device install from Xcode)
4. Run on a simulator or device (iOS 17+)

## Build unsigned IPA with GitHub Actions

No Apple Developer secrets needed.

1. Push to `main`, or open **Actions → Build EditVerse IPA → Run workflow**
2. Download the artifact **`EditVerse-unsigned-ipa`**
3. Inside: `EditVerse-unsigned.ipa`

### What “unsigned” means

The IPA is packaged as a normal IPA (`Payload/EditVerse.app`) but **not code-signed**.

- You can resign it yourself later (e.g. with your own cert / sideload tool)
- It will **not** install on a normal iPhone until it is signed

### Local unsigned IPA (on a Mac)

```bash
xcodebuild \
  -project EditVerse.xcodeproj \
  -scheme EditVerse \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

mkdir -p build/ipa/Payload
cp -R build/DerivedData/Build/Products/Release-iphoneos/EditVerse.app build/ipa/Payload/
(cd build/ipa && zip -qr EditVerse-unsigned.ipa Payload)
```

## Bundle ID

`com.editverse.app` — change in Xcode / `project.pbxproj` if needed.
