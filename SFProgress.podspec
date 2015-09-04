Pod::Spec.new do |s|
  s.name             = "SFProgress"
  s.version          = "0.0.1"
  s.summary          = "The open source fonts for Artsy apps + UIFont categories."
  s.homepage         = "git@github.com:looseyi/SFProgressHUD.git"
  s.license          = 'Code is MIT, then custom font licenses.'
  s.author           = { "Edmond" => "chun574271939@gmail.com" }
  s.source           = { :git => "git@github.com:looseyi/SFProgressHUD.git", :tag => s.version }
  s.social_media_url = 'https://twitter.com/looseyi'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resources = 'Pod/Assets/*'

  s.frameworks = 'UIKit', 'CoreGraphic'
  s.module_name = 'SFProgressHUD'
end
