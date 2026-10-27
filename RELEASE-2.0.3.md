# CybexoSDK 2.0.3

The existing `setTCFAdvertiserConsentMode(enabled:)` API now honors both true
and false. Its requested value persists as host integration configuration,
separately from visitor choices. Existing installations keep the default off.

The effective IAB flag is enabled only with a current valid CYBEXO TCF decision,
Google delivery enabled and GDPR applicable. Google-only mode, loading, reset,
unverified configuration and disabled Google delivery keep it off. Another CMP's
standard IAB storage is preserved. A rejected TC string may have the flag on:
enabling interpretation of that string never grants visitor consent.

Direct four-value Google delivery, independent Analytics choice, vendor veto,
consent storage format and the owned WebView API are retained. Integration-option
changes do not create a visitor decision or a consent receipt. The passive
snapshot exposes requested and effective integration states.

Firebase's TCF reader also depends on the host's Info.plist. An enabled IAB flag
alone is not proof of automatic inference or remote reception. See README for
startup defaults, optional TCF setup and collection gates. No provider account,
ATT authorization or Google/IAB certification is supplied by this patch.

The native suite passes 121 tests, including three focused public-option,
lifecycle and eligibility/ownership regressions. Package, consumer and live
recipient evidence are recorded separately in the release qualification packet.
Release 2.0.2 is preserved without replacing its source or package tag.
