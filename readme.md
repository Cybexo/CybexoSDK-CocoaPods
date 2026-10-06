# CybexoSDK for iOS

`CybexoSDK` provides native consent choices, IAB TCF signals and explicit Google Consent Mode values for a registered CYBEXO iOS App.

This repository distributes CybexoSDK 2.0.0. Source, consumer integration and live app verification remain separate from Google or IAB certification.

## Requirements

- iOS 15.0 or later. Version 2.0 raises the previous deployment minimum.
- Xcode 27 for this binary release. Swift language mode 5 does not promise import compatibility with older compilers.
- CocoaPods 1.16.2.
- A published CYBEXO iOS App with a `CYB-` App ID and the same bundle identifier as your app.

## Installation

Install version 2.0.0 using the normal CocoaPods source:

```ruby
platform :ios, '15.0'

target 'YourApp' do
  use_frameworks!
  pod 'CybexoSDK', '2.0.0'
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

For Firebase, defer its initial configuration until the CMP has a validated current choice that allows analytics. Keep collection disabled, apply the snapshot's current four effective flags, call `FirebaseApp.configure()` once through the host's normal setup, then call `CybexoCMP.shared.retryRecipientConsent()` and read the snapshot again. Enable Analytics collection only while all four conditions hold: `initializationStatus == "READY"`, `decisionMade == true`, `google.analytics_storage == "granted"`, and `firebaseDelivery == "APPLIED"`. Reevaluate that gate on every CMP notification and disable collection when it closes. Avoid a retry loop inside the observer; retry when recipient setup changes. Keep optional session starts, event calls and advertising requests behind their relevant current consent gates. See Google's [app consent setup](https://developers.google.com/tag-platform/security/guides/app-consent?platform=ios).

After normal host setup makes another previously unavailable recipient ready, call `CybexoCMP.shared.retryRecipientConsent()` to apply the latest effective choice. The host remains responsible for each provider's initialization, credentials, collection lifecycle and any App Tracking Transparency requirement. The CMP does not display an ATT prompt or perform provider account setup. A provider may change or resume its SDK behavior when its consent API is called, so follow that provider’s setup and session order.

Offer an enduring privacy entry point:

```swift
CybexoCMP.shared.showBanner(force: true)
```

Opening and closing choices does not itself create a new decision. `refreshConsentState()` revalidates the current configuration. `retryConsentReceipts()` retries retained original receipts without creating a new choice.

## Framework and recipient behavior

The Dashboard's native consent framework is explicit: `tcf` uses the applicable TCF purpose/vendor interface; `google-consent-mode` offers independent Google choices and emits no TC string. Neither setting changes the visitor's actual jurisdiction. The Google delivery setting is separate from the framework.

The SDK forwards the four effective Google values explicitly and sets `IABTCF_EnableAdvertiserConsentMode` to zero so automatic TCF inference does not replace the independently recorded analytics choice. Native `IABTCF_*` preferences remain available to integrations that read them. This 2.0 audit does not qualify separate legacy US/GPP behavior.

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
