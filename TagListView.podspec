Pod::Spec.new do |s|
  s.name         = "TagListView"
  s.version      = "1.4.2"
  s.summary      = "Simple but highly customizable iOS tag list view, in Swift."
  s.homepage     = "https://github.com/ElaWorkshop/TagListView"
  s.social_media_url = "http://twitter.com/elabuild"

  s.license      = "MIT"
  s.author       = { "LIU Dongyuan" => "liu.dongyuan@gmail.com" }
  
  s.swift_version = '5.0'

  s.platform     = :ios, "14.0"
  s.source       = { :git => "https://github.com/benbahrenburg/TagListView.git", :tag => s.version }
  s.source_files = "TagListView/*.swift"
  s.requires_arc = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
end
