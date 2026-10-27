# CybexoSDK for iOS

`CybexoSDK` provides native consent choices, IAB TCF signals and explicit Google Consent Mode values for a registered CYBEXO iOS App.

This repository distributes CybexoSDK 2.0.3. Source, consumer integration and live app verification remain separate from Google or IAB certification.

## Changes in 2.0.3

The existing Google TCF opt-in now honors true/false and persists independently of visitor choices. Direct four-value delivery stays the default; Google-only mode keeps the TCF integration flag off. See [release notes](RELEASE-2.0.3.md).

## Previous changes in 2.0.2

Version 2.0.2 adds an app-owned WebView bridge that shares the native consent state, applies denied Google defaults before page scripts, forwards updates and withdrawal, and opens the same native privacy choices. Existing native APIs and saved-choice formats remain compatible with 2.0.1. See [release notes](RELEASE-2.0.2.md).

## Requirements

- iOS 15.0 or later. Version 2.0 raises the previous deployment minimum.
- Xcode 27 for this binary release. Swift language mode 5 does not promise import compatibility with older compilers.
- CocoaPods 1.16.2.
- A published CYBEXO iOS App with a `CYB-` App ID and the same bundle identifier as your app.

## Installation

Install version 2.0.3 using the normal CocoaPods source:

```ruby
platform :ios, '15.0'

target 'YourApp' do
  use_frameworks!
  pod 'CybexoSDK', '2.0.3'
end
```

Run `pod install`, open the generated `.xcworkspace`, and retain your `Podfile.lock`. This pod does not bundle Firebase or attribution SDKs. Add only the recipients your app uses through their normal supported installation methods, with one copy of each SDK in the final app.

## Host setup and startup

Create and publish the iOS App in the CYBEXO Dashboard. Configure the publisher name, privacy policy, purposes, vendors and consent framework to match the app's actual data practices. Tell visitors which additional analytics or attribution services are active; an installed SDK is not itself evidence of its collection behavior.

If using Google Analytics for Firebase, set the host app's `Info.plist` defaults before Firebase loads. Disable collection and automatic TCF inference, then default all four manual consent values to denied:

```xml
<key>FIREBASE_ANALYTICS_COLLECTION_ENABLED</key><false/>
<key>GOOGLE_ANALYTICS_TCF_DATA_ENABLED</key><false/>
<key>GOOGLE_ANALYTICS_DEFAULT_ALLOW_ANALYTICS_STORAGE</key><false/>
<key>GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_STORAGE</key><false/>
<key>GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_USER_DATA</key><false/>
<key>GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_PERSONALIZATION_SIGNALS</key><false/>
```

The host owns normal Firebase configuration and collection controls. Firebase retains prior settings, so defaults alone do not replace startup ordering. Before any `FirebaseApp.configure()` call on each launch, disable Analytics collection and overwrite all four flags with denied:

```swift
import FirebaseAnalytics

Analytics.setAnalyticsCollectionEnabled(false)
Analytics.setConsent([
    .analyticsStorage: .denied,
    .adStorage: .denied,
    .adUserData: .denied,
    .adPersonalization: .denied
])
```

Register the CMP change observer, then initialize the CMP early, when your app can present its consent UI:

```swift
import CybexoSDK

CybexoCMP.shared.initialize(settingsId: "YOUR_PUBLISHED_CYB_APP_ID")
```

Replace the placeholder with the real `CYB-` App ID. Loading, invalid configuration and an absent or invalid saved choice remain denied. Read `CybexoCMP.shared.getConsentSnapshot()` on the main thread for current state; a completion callback by itself is not a consent grant. Observe `CybexoCMP.consentDidChangeNotification` for consent routing, successful Firebase application and receipt-status changes, then read the snapshot again. Attribution discovery retries can update diagnostics without that notification; inspect their delivery state again after explicit retry or later host setup. Require `initializationStatus == "READY"`, `decisionMade == true` and the relevant effective signal before permitting optional work.

Configure Firebase normally after applying the fixed startup denial, with optional collection disabled. CYBEXO detects Firebase and applies changing consent automatically; do not add a customer snapshot-to-Firebase value relay. Observe CMP notifications to control collection only: enable it while `initializationStatus == "READY"`, `decisionMade == true`, `google.analytics_storage == "granted"` and `firebaseDelivery == "APPLIED"`; disable it when any gate closes. If Firebase becomes available later, call `retryRecipientConsent()` once after configuration. Keep optional events, sessions and advertising behind their corresponding current consent gates. See Google's [app consent setup](https://developers.google.com/tag-platform/security/guides/app-consent?platform=ios).

After normal host setup makes another previously unavailable recipient ready, call `CybexoCMP.shared.retryRecipientConsent()` to apply the latest effective choice. The host remains responsible for each provider's initialization, credentials, collection lifecycle and any App Tracking Transparency requirement. The CMP does not display an ATT prompt or perform provider account setup. A provider may change or resume its SDK behavior when its consent API is called, so follow that provider’s setup and session order.

Offer an enduring privacy entry point:

```swift
CybexoCMP.shared.showBanner(force: true)
```

Opening and closing choices does not itself create a new decision. `refreshConsentState()` revalidates the current configuration. `retryConsentReceipts()` retries retained original receipts without creating a new choice.

## Framework and recipient behavior

The Dashboard's native consent framework is explicit: `tcf` uses the applicable TCF purpose/vendor interface; `google-consent-mode` offers independent Google choices and emits no TC string. Neither setting changes the visitor's actual jurisdiction. The Google delivery setting is separate from the framework.

The SDK forwards all four effective Google values explicitly. The default `IABTCF_EnableAdvertiserConsentMode` flag is `0`. In 2.0.3, a host may call `CybexoCMP.shared.setTCFAdvertiserConsentMode(enabled: true)` on the main thread before initialization to opt into Google's TCF advertising integration. Set the host's `GOOGLE_ANALYTICS_TCF_DATA_ENABLED` to true (or omit it) for Firebase to read TCF; retain restrictive startup defaults and collection gates. Calling the API cannot override an Info.plist that disables Google's TCF reader.

The requested option persists for this host installation separately from visitor choices; false opts out. Passive snapshot fields `tcfAdvertiserConsentModeRequested` and `tcfAdvertiserConsentModeEnabled` expose intent and effective eligibility. Flag1 requires a current valid CYBEXO TCF decision, Google delivery enabled and GDPR applicable. It stays `0` without a decision, while loading, in Google-only mode, outside GDPR, after reset and when Google delivery is disabled. Another CMP's standard IAB preferences are preserved. A rejected TC string may legitimately have flag `1`: it enables interpretation of the rejection and grants nothing.

Direct updates continue, preserving the independent Analytics choice and Google vendor veto. Changing the option creates no visitor decision or consent receipt. Flag1 alone is not proof of inference or remote reception; verify actual recipient behavior for your Firebase version/configuration. Legacy US/GPP behavior remains outside this patch's qualification scope.

Optional consent bridges target AppsFlyer 6.17.7, Adjust 5.8.0 and Branch 3.14.2. Keep Objective-C provider classes in statically linked apps using the provider's prescribed linker setup; the reviewed consumer uses `-ObjC`. AppsFlyer receives explicit `AppsFlyerConsent` values with its automatic TCF collection disabled. Branch requires a real configured Branch key. Apply the CMP's effective state before starting optional collection, and retry recipient consent after late host setup. Ordinary refusal does not invoke account erasure or logout.

A successful local API call means the recipient method returned; it is not proof of remote reception. AppsFlyer, Adjust and Branch remote reception requires your own configured test accounts and separate verification.

## Privacy, storage and migration

The framework's `PrivacyInfo.xcprivacy` covers CYBEXO's own API use and consent reporting. It declares app-owned UserDefaults access, a pseudonymous app-scoped visitor identifier, coarse jurisdiction derived from network requests, consent interactions and consent/configuration records. These support consent functionality and reporting. CYBEXO does not read IDFA or use the CMP identifier for cross-app tracking. Provider SDKs retain their own privacy declarations; the host must review the complete app's privacy report and disclosures.

Version 2.0 binds saved choices to the App, bundle, installation and current consent context. It keeps standard IAB keys unchanged and uses the public `CybexoCMP`, `CybexoCMPUtils` and `CybexoAPIServer` names; retired class aliases are no longer public. Do not copy a previous App ID, fabricate a TC string, or import a choice from another app or installation.

The SDK's installation marker and durable receipt files are marked excluded from backup. The app still owns its backup and device-transfer policy, including retained preferences from older versions. Validate the transfer mechanisms you support; this is not a guarantee about every device or restore path. A restored installation without the original marker must obtain a fresh validated choice before optional collection. Do not migrate another installation's queued receipts or visitor identity.

For rollback, retain the exact prior app package and dependency lockfile. Do not restore grants by rewriting preferences or replay historical choices as new decisions. Review identity, configuration and saved-consent compatibility before a rollback; 1.x is not a drop-in compatibility fallback for the 2.0 contract.

## Documentation and license

- [iOS integration guide](https://developer.cybexo.com/sdk/ios/)
- [iOS API reference](https://developer.cybexo.com/sdk/ios-api-reference/)

`CybexoSDK` is commercial software. Use of the SDK is governed by [LICENSE](LICENSE) and requires an active CYBEXO subscription for production use. Engineering tests do not constitute Google or IAB certification.

Support: ios@cybexo.com · https://www.cybexo.com

Copyright 2026 CYBEXO Inc. All rights reserved.

## App-owned embedded WebViews

Version 2.0.2 adds `CybexoWebViewBridge`. Attach it before the first load, retain it with the view, and call `close()` when the view is finished. Use a dedicated `WKUserContentController` and exact HTTPS origins whose content and scripts you control.

```swift
let webView = WKWebView(frame: .zero)
let bridge = try CybexoWebViewBridge(
    webView: webView, settingsId: "YOUR_CYB_APP_ID",
    ownedHTTPSOrigins: ["https://app.example.com"])
webView.load(URLRequest(url: URL(string: "https://app.example.com/embedded")!))
// Retain bridge for this view's lifetime; later call bridge.close().
```

The bridge sets all four Google defaults to denied at document start, then updates them from the app's validated consent. It stays denied while native configuration or a current decision is unavailable. It shares only this app's choice with its own main-frame content; it does not grant consent to unrelated websites, other apps or child frames. Origin paths, wildcards and HTTP origins are rejected.

In the embedded page, `await window.cybexoNativeConsent.ready` returns the first native snapshot (which may still be loading). Use `getSnapshot()` for a fresh snapshot and listen for `cybexoConsentChanged` for subsequent changes. Require `ready`, `decisionMade` and the relevant granted value before starting optional processing. The page can call `showPreferences()` to reopen the same native privacy controls; it cannot directly change native consent through JavaScript.

```javascript
function applyConsent(state) {
  const analyticsAllowed = state.ready && state.decisionMade &&
    state.google.analytics_storage === 'granted';
  // Enable or disable your own optional processing using this state.
}
window.addEventListener('cybexoConsentChanged', e => applyConsent(e.detail));
window.cybexoNativeConsent.ready.then(applyConsent);
document.querySelector('#privacy-choices').onclick = () =>
  window.cybexoNativeConsent.showPreferences();
```

Use only one Google consent owner in the view. Do not install a second web CMP or override its defaults. Google tags, if present, use the bridge's normal `dataLayer` consent commands; other embedded integrations should consume the snapshot. `tcString` is the native app's current TCF string, not a separate website decision or a replacement for a website's `__tcfapi`. Embedded content must have the same disclosed purposes and partners as the app. Host apps remain responsible for restricting navigation and gating non-Google processing.
