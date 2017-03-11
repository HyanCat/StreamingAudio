
Pod::Spec.new do |s|
  s.name             = 'StreamingAudio'
  s.version          = '0.1.0'
  s.summary          = 'A simple player for streaming audio.'
  s.description      = 'A simple player for streaming audio, which based on `StreamingKit`.'
  s.homepage         = 'https://github.com/HyanCat'
  s.license          = { :type => 'Copyright', :text => 'Copyright HyanCat' }
  s.author           = { 'HyanCat' => 'hyancat@live.cn' }
  s.source           = { :git => 'https://github.com/HyanCat/StreamingAudio.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'

  s.source_files = 'StreamingAudio/**/*.{h,m}'
  s.frameworks = 'Foundation'
  s.dependency 'StreamingKit'

end
