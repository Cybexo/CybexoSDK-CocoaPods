Pod::Spec.new do |s|
  s.name             = 'CybexoSDK'
  s.version          = '1.0.0'
  s.summary          = 'CYBEXO consent-management SDK for iOS'
  s.description      = <<-DESC
    CybexoSDK provides a drop-in consent-management runtime for iOS apps,
    including CMP banner UI, second-layer preferences, device-storage
    disclosure surfaces, IAB TCF/GPP/USP signaling, and CYBEXO-owned runtime
    storage compatibility for migrated installs.
  DESC
  s.homepage         = 'https://www.cybexo.com'
  s.license          = { :type => 'Commercial', :file => 'LICENSE' }
  s.author           = { 'CYBEXO' => 'ios@cybexo.com' }
  s.source           = { :git => 'https://github.com/Cybexo/CybexoSDK-CocoaPods.git',
                         :tag => s.version.to_s }
  s.documentation_url = 'https://www.cybexo.com'

  s.ios.deployment_target = '13.0'
  s.swift_version         = '5.10'

  s.vendored_frameworks = 'CybexoSDK.xcframework'

  s.frameworks = 'UIKit', 'WebKit'
end
