#
# Be sure to run `pod lib lint ProjectBase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Reactant'
  s.version          = '0.2.0'
  s.summary          = 'Imagine React Native in Swift and you get Reactant'

  s.description      = <<-DESC
                        We combined the strength of RxSwift with pure swift and
                        made a framework for highly reusable and clean views.
                       DESC

  s.homepage         = 'https://github.com/SwiftKit/Reactant.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tadeas Kriz' => 'tadeas@brightify.org', 'Matous Hybl' => 'matous@brightify.org' }
  s.source           = { :git => 'http://source.tmspark.com/scm/base/projectbase-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/Classes/**/*'

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
  s.dependency 'HanekeSwift'
end
