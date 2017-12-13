Pod::Spec.new do |s|
  s.name = 'CloudFeedback'
  s.version = '0.1.0'
  s.license = 'Apache 2'
  s.summary = 'User feedback on top of CloudKit'
  s.homepage = 'https://github.com/coodly/CloudFeedback'
  s.authors = { 'Jaanus Siim' => 'jaanus@coodly.com' }
  s.source = { :git => 'git@github.com:coodly/CloudFeedback.git', :tag => s.version }
  s.default_subspec = 'Client'

  s.ios.deployment_target = '10.0'
  #s.tvos.deployment_target = '9.0'
  #s.osx.deployment_target = '10.11'

  s.subspec 'Core' do |core|
    core.source_files = 'Source/Core/*.swift'
    core.dependency 'CoreDataPersistence', '0.1.5'
    core.dependency 'Puff', '0.1.0'
  end
  
  s.subspec 'Client' do |client|
    client.source_files = "Source/Client"
    client.dependency "CloudFeedback/Core"
  end


  s.source_files = 'Sources/*.swift'
  #s.tvos.exclude_files = ['Sources/ShakeWindow.swift']
  #s.osx.exclude_files = ['Sources/ShakeWindow.swift']

  s.requires_arc = true
end
