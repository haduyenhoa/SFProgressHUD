Pod::Spec.new do |s|
  s.name             = "SFProgress"
  s.version          = "0.0.1"
  s.homepage         = "git@github.com:looseyi/SFProgressHUD.git"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Edmond" => "chun574271939@gmail.com" }
  s.source           = { :git => "git@github.com:looseyi/SFProgressHUD.git", :tag => s.version }
  s.social_media_url = 'https://twitter.com/looseyi'

  s.platform     = :ios, '8.0'
  s.source_files = '*.{h,m}'
  s.framework    = "CoreGraphics"
  s.requires_arc = true
end
