#
# Be sure to run `pod lib lint ProjectBase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Reactant'
  s.version          = '0.5.10'
  s.summary          = 'Imagine React Native in Swift and you get Reactant'

  s.description      = <<-DESC
                        We combined the strength of RxSwift with pure swift and
                        made a framework for highly reusable and clean views.
                       DESC

  s.homepage         = 'https://github.com/Brightify/Reactant.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tadeas Kriz' => 'tadeas@brightify.org', 'Matous Hybl' => 'matous@brightify.org' }
  s.source           = { :git => 'https://github.com/Brightify/Reactant.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.default_subspec = 'Core', 'Result', 'Staging'

  s.subspec 'Core' do |core|
    core.frameworks = 'UIKit'
    core.source_files = 'Source/Classes/Core/**/*'
    core.dependency 'RxSwift', '~> 3.0.0'
    core.dependency 'RxCocoa', '~> 3.0.0'
    core.dependency 'RxOptional', '~> 3.1'
    core.dependency 'SnapKit', '~> 3.0'
  end

  s.subspec 'Result' do |result|
    result.source_files = 'Source/Classes/Result/**/*'
    s.dependency 'Result', '~> 3.0.0'
    s.dependency 'RxSwift', '~> 3.0.0'
    s.dependency 'RxOptional', '~> 3.1'
  end

  s.subspec 'Staging' do |staging|
    staging.frameworks = 'UIKit'
    staging.source_files = 'Source/Classes/Staging/**/*'
    staging.dependency 'Reactant/Core'
    staging.dependency 'RxSwift', '~> 3.0.0'
    staging.dependency 'RxCocoa', '~> 3.0.0'
    staging.dependency 'Kingfisher', '~> 3.1'
    staging.dependency 'SnapKit', '~> 3.0'
  end

  s.subspec 'Validation' do |validation|
    validation.source_files = 'Source/Classes/Validation/**/*'
    validation.frameworks = 'Foundation'
  end

  s.subspec 'TableView' do |tableView|
    tableView.frameworks = 'UIKit'
    tableView.source_files = 'Source/Classes/TableView/**/*'
    tableView.dependency 'Reactant/Core'
    tableView.dependency 'RxSwift', '~> 3.0.0'
    tableView.dependency 'RxCocoa', '~> 3.0.0'
    tableView.dependency 'RxDataSources', '~> 1.0.0'

  end

  s.subspec 'CollectionView' do |collectionView|
    collectionView.frameworks = 'UIKit'
    collectionView.source_files = 'Source/Classes/CollectionView/**/*'
    collectionView.dependency 'Reactant/Core'
    collectionView.dependency 'Reactant/TableView'
    collectionView.dependency 'RxSwift', '~> 3.0.0'
    collectionView.dependency 'RxCocoa', '~> 3.0.0'
    collectionView.dependency 'RxDataSources', '~> 1.0.0'
  end
end
