# iOS SDK 2.0.2

This release adds `CybexoWebViewBridge` for HTTPS content owned by your app. It shares the app's current native privacy choice with embedded pages, sets denied Google consent defaults at document start, updates the page after native choices change, and lets the page reopen the same native privacy controls.

Attach the bridge before loading, retain it for the view's lifetime, and close it when finished. Use exact owned origins and a dedicated user-content controller. Other origins and child frames cannot read native consent. A page cannot submit grants or replace the native decision. The bridge supports the iOS 15 deployment minimum.

Native TCF and independent Google choices retain their existing behavior. The app's TC string represents the app's disclosed purposes and partners; the bridge is not a separate website CMP. Public native APIs and saved-choice formats remain compatible with 2.0.1.

See the [setup guide](https://developer.cybexo.com/sdk/ios/) and [API reference](https://developer.cybexo.com/sdk/ios-api-reference/). Integration and release testing do not constitute Google or IAB certification.
