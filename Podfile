# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'PublicKey-Pinning_Swift' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PublicKey-Pinning_Swift
pod 'Alamofire', '~> 5.5'

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
	config.build_settings["SWIFT_VERSION"] = "5.0"
  end
end