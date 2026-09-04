# EditVerse iOS

Native SwiftUI app: vertical short-form feed **only for edits** — original app, not a TikTok/Instagram mod.

Repo: https://github.com/dskja/EditVerse-iOS

## Build unsigned IPA (GitHub Actions)

The workflow builds **only** an unsigned `EditVerse.ipa` — no simulator build, no GitHub Release.

1. Push to `main`, or **Actions → Build EditVerse IPA → Run workflow**
2. Download the Actions artifact **`EditVerse.ipa`**

Unsigned = packaged IPA, not code-signed. Resign before installing on a device.

## Open in Xcode

1. Clone on a Mac
2. Open `EditVerse.xcodeproj`
3. Set Team under Signing & Capabilities
4. Run (iOS 17+)

## Bundle ID

`com.editverse.app`
