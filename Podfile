platform :ios, '14.0'

target 'Strafen' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Add the pods for any other Firebase products you want to use in your app
  # For example, to use Firebase Authentication and Cloud Firestore
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'
  pod 'Firebase/Database'
  pod 'Firebase/Functions'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'CodableFirebase'

  # AdMob
  pod 'Google-Mobile-Ads-SDK'

  # Braintree
  pod 'BraintreeDropIn'
  pod 'Braintree/DataCollector'

  # Support Docs
  pod 'SupportDocs'
  
  target 'StrafenWidgetExtension' do
    inherit! :search_paths
  end

  target 'StrafenNotificationService' do
    inherit! :search_paths
  end

  target 'StrafenTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'StrafenUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
