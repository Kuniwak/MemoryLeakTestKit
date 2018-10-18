Pod::Spec.new do |s|
  s.name         = "MemoryLeakTestKit"
  s.version      = "0.0.1"
  s.summary      = "A testing library to detect memory leaks for Swift."
  s.description  = <<-DESC
    A testing library to detect memory leaks for Swift. This library can report many information such as leaked object's type/string representation/location/circular reference paths.
  DESC
  s.homepage     = "https://github.com/Kuniwak/MemoryLeakTestKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.swift_version = "4.2"
  s.ios.deployment_target     = "8.0"
  s.osx.deployment_target     = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target    = "9.0"
  s.author       = { "Kuniwak" => "orga.chem.job@gmail.com" }
  s.source       = { :git => "https://github.com/Kuniwak/MemoryLeakTestKit.git", :tag => "#{s.version}" }
  s.source_files = "Sources/**/*.swift"
  s.exclude_files = "Sources/**/*.gyb"
  s.framework    = "Foundation"
end
