# CybexoSDK for iOS

`CybexoSDK` is the CYBEXO iOS consent-management SDK package for CocoaPods and manual XCFramework distribution.

## Package

- Pod name: `CybexoSDK`
- Vendored framework: `CybexoSDK.xcframework`
- Swift import: `import CybexoSDK`
- Minimum iOS target: `13.0`
- Current version: `1.0.0`

## Installation

```ruby
pod 'CybexoSDK', '~> 1.0'
```

## Quick Start

```swift
import CybexoSDK

CybexoCMP.shared.initialize(settingsId: "YOUR_SETTINGS_ID")
CybexoCMP.shared.showBanner(force: true)
```

Legacy source-compatibility aliases remain available for migration inside the `CybexoSDK` module. They do not mean that an already-linked legacy binary can be swapped without rebuilding against `CybexoSDK`.

## Runtime Storage Policy

CYBEXO-owned durable keys use the `cybexo_cmp_*` prefix.

Standards keys are intentionally unchanged:

- `IABTCF_TCString`
- `IABTCF_EnableAdvertiserConsentMode`
- `IABGPP_*`
- `IABUSPrivacy_String`

## Validation

Run from this repository:

```bash
pod lib lint CybexoSDK.podspec --allow-warnings --skip-tests --verbose
```

## Support

- Website: https://www.cybexo.com
- Email: ios@cybexo.com

Copyright 2026 CYBEXO Inc. All rights reserved.
