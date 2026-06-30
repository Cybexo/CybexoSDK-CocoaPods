# CybexoSDK for iOS

`CybexoSDK` is CYBEXO's iOS consent-management SDK for native apps that need a CMP runtime, consent banner UI, preference controls, device-storage disclosures, and IAB consent signaling.

## Requirements

- iOS 13.0 or later
- Xcode 15 or later
- CocoaPods 1.12 or later

## Installation

Add `CybexoSDK` to your Podfile:

```ruby
target 'YourApp' do
  use_frameworks!
  pod 'CybexoSDK', '~> 1.0'
end
```

Then run:

```bash
pod install
```

Open the generated `.xcworkspace` file and import the SDK where you initialize your consent flow.

## Quick Start

```swift
import CybexoSDK

CybexoCMP.shared.initialize(settingsId: "YOUR_SETTINGS_ID")
CybexoCMP.shared.showBanner(force: true)
```

## Runtime Storage

CYBEXO-owned durable consent keys use the `cybexo_cmp_*` prefix.

Industry-standard consent keys are intentionally preserved so downstream advertising, analytics, and compliance integrations can continue reading the expected values:

- `IABTCF_TCString`
- `IABTCF_EnableAdvertiserConsentMode`
- `IABGPP_*`
- `IABUSPrivacy_String`

## License

`CybexoSDK` is commercial software. Use of the SDK is governed by the terms in [LICENSE](LICENSE) and requires an active CYBEXO subscription for production use.

## Support

- Website: https://www.cybexo.com
- Email: ios@cybexo.com

Copyright 2026 CYBEXO Inc. All rights reserved.
