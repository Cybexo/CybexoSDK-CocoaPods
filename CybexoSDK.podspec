Pod::Spec.new do |s|
  s.name             = 'CybexoSDK'
  s.version          = '2.0.3'
  s.summary          = 'CYBEXO consent-management SDK for iOS'
  s.description      = <<-DESC
    CybexoSDK provides native consent choices and preference controls for
    registered CYBEXO iOS apps, with IAB TCF signals, four explicit Google
    Consent Mode values, and durable consent reporting. Optional recipient
    SDKs are configured separately by the host app.
  DESC
  s.homepage         = 'https://www.cybexo.com'
  s.license          = { :type => 'Commercial', :file => 'LICENSE' }
  s.author           = { 'CYBEXO' => 'ios@cybexo.com' }
  s.source           = { :git => 'https://github.com/Cybexo/CybexoSDK-CocoaPods.git',
                         :tag => s.version.to_s }
  s.documentation_url = 'https://developer.cybexo.com/sdk/ios/'

  s.ios.deployment_target = '15.0'
  # Language mode, not a promise that an older Swift compiler can import the binary.
  s.swift_version         = '5.0'

  s.vendored_frameworks = 'CybexoSDK.xcframework'

  s.frameworks = 'UIKit', 'WebKit'
end
