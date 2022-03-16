

Pod::Spec.new do |s|


  s.name         = "UBARViewer"
  s.version      = "0.1.3"
  s.summary      = "Urbanbase AR library that represented with augmented reality."

  s.description  = <<-DESC
                     Hello, We are Urbanbase.
                     We invent the next world.
                     UBARViewer is the framework that helps to adapt easily your apps.
                   DESC

  s.homepage     = "https://urbanbase.com"
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.authors      = { 'Urbanbase Inc.' => 'dev@urbanbase.com' }
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/urbanbase/ar-viewer-ios.git", :tag => "#{s.version}" }

  s.vendored_frameworks = 'UBARViewer.framework'

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.dependency 'UICircularProgressRing', '~>6.1.0'
  s.dependency 'lottie-ios'

  s.swift_version = "5.5"
end
