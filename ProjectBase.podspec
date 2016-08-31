#
# Be sure to run `pod lib lint ProjectBase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ProjectBase'
  s.version          = '0.1.13'
  s.summary          = 'A short description of ProjectBase.'

  s.description      = <<-DESC
                        A base for new project of Brightify.
                       DESC

  s.homepage         = 'http://source.tmspark.com/scm/base/private-specs.git'
  #s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tadeas Kriz' => 'tadeas@brightify.org' }
  s.source           = { :git => 'http://source.tmspark.com/scm/base/projectbase-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'ProjectBase/Classes/**/*'

  # s.resource_bundles = {
  #   'ProjectBase' => ['ProjectBase/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'SwiftKit', '0.9.0'
  s.dependency 'RxDataSources'
  s.dependency 'RxOptional'
  s.dependency 'Lipstick'
  s.dependency 'TZStackView'
  s.dependency 'SnapKit'
  s.dependency 'HTTPStatusCodes'
end
