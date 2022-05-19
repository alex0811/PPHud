Pod::Spec.new do |s|
  s.name             = 'PPHud'
  s.version          = '0.1.6'
  s.summary          = 'A simple Hud'
  s.homepage         = 'https://github.com/alex0811/PPHud'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'alex0811' => 'alex_zhangfan@hotmail.com' }
  s.source           = { :git => 'https://github.com/alex0811/PPHud.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'PPHud/Classes/**/*'
  s.swift_version = '5.0'
end
