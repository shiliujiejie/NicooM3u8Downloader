

Pod::Spec.new do |s|
  s.name             = 'NicooM3u8Downloader'
  s.version          = '0.1.1'
  s.summary          = 'NicooM3u8Downloader for .m3u8 video Download.'
  s.description      = <<-DESC
   .m3u8 parse , ts video Download.  local ts list play.
                       DESC

  s.homepage         = 'https://github.com/yangxina/NicooM3u8Downloader'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yangxina' => '504672006@qq.com' }
  s.source           = { :git => 'https://github.com/yangxina/NicooM3u8Downloader.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_version = '4.2'

  s.ios.deployment_target = '8.0'
  s.source_files = 'NicooM3u8Downloader/Classes/**/*'
  
end
