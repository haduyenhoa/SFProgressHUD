Pod::Spec.new do |s|
  s.name             = 'SFProgressHUD'
  s.version          = '0.0.3'
  s.summary      = "SFProgress, MBProgress by swift 2.0, with apple Effect view"
  s.homepage     = 'https://github.com/looseyi/SFProgressHUD.git'
  s.license      = 'MIT'
  s.author             = { 'looseyi' => '13615033587@126.com' }

  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/looseyi/SFProgressHUD.git", :tag => s.version }
  s.source_files = 'source/*.swift'
  s.exclude_files = "Classes/Demo"
  s.framework    = "CoreGraphics"
  s.requires_arc = true
end
