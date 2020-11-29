source 'https://github.com/coodly/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

project 'FeedbackAdmin.xcodeproj/'

# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'
use_frameworks!

target 'FeedbackAdmin' do

end

target 'AdminCore' do
    pod 'CloudFeedback/Admin', :path => '.'

    pod 'CoreDataPersistence', '0.2.3'
    pod 'SWLogger', :git => 'git@github.com:coodly/swlogger.git', tag: '0.3.4'
    pod 'Puff', '0.6.2'
end
