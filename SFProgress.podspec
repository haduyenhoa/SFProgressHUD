#
Pod::Spec.new do |s|
<<<<<<< HEAD
  s.name             = "SFProgress"
  s.version          = "0.0.2"
<<<<<<< HEAD
  s.summary          = "MBProgressHUD with swift"
  s.homepage         = "https://github.com/looseyi/SFProgressHUD.git"
=======
  s.homepage         = "git@github.com:looseyi/SFProgressHUD.git"
>>>>>>> update podspec
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Edmond" => "chun574271939@gmail.com" }
  s.source           = { :git => "https://github.com/looseyi/SFProgressHUD.git", :tag => s.version }
  s.social_media_url = 'https://twitter.com/looseyi'
=======
  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "SFProgress"
  s.version      = "0.0.2"
  s.summary      = "SFProgress, MBProgress by swift 2.0"
>>>>>>> reset podspce

<<<<<<< HEAD
  s.description  = <<-DESC
  MBProgressHUD for swift, you can use by specifiy tag 0.0.2
  DESC

  s.homepage     = "https://github.com/looseyi/SFProgressHUD.git"
  s.license      = "MIT"
  s.author             = { "looseyi" => "13615033587@126.com" }
  s.social_media_url   = "http://twitter.com/looseyi"

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/looseyi/SFProgressHUD.git", :tag => "0.0.2" }
  s.source_files  = "source", "source/**/*.{swift}"
  s.exclude_files = "Classes/Demo"
=======
  s.platform     = :ios, '8.0'
  s.source_files = '*.{swift}'
  s.framework    = "CoreGraphics"
  s.requires_arc = true
>>>>>>> update podspec
end
