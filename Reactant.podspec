#
# Be sure to run `pod lib lint ProjectBase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Reactant'
  s.version          = '0.6.0'
  s.summary          = 'Imagine React Native in Swift and you get Reactant'

  s.description      = <<-DESC
                        We combined the strength of RxSwift with pure swift and
                        made a framework for highly reusable and clean views.
                       DESC
  spec.homepage         = 'https://github.com/Brightify/Reactant'
  spec.license          = 'MIT'
  spec.author           = { 'Tadeas Kriz' => 'tadeas@brightify.org', 'Matous Hybl' => 'matous@brightify.org', "Filip Dolnik" => "filip@brightify.org" }
  spec.source           = {
      :git => 'https://github.com/Brightify/Reactant.git',
      :tag => spec.version.to_s
  }
  spec.social_media_url = 'https://twitter.com/BrightifyOrg'
  spec.requires_arc = true

  spec.ios.deployment_target = '8.0'

  def rxSwift do |subspec|
      subspec.dependency 'RxSwift', '~> 3.0'
  end
  def snapKit do |subspec|
      subspec.dependency 'SnapKit', '~> 3.0'
  end
  def result do |subspec|
      subspec.dependency 'Result', '~> 3.0'
  end
  def rxCocoa do |subspec|
      subspec.dependency 'RxCocoa', '~> 3.0'
  end
  def rxDataSources do |subspec|
      subspec.dependency 'RxDataSources', '~> 1.0'
  end
  def rxOptional do |subspec|
      subspec.dependency 'RxOptional', '~> 3.0'
  end

  spec.subspec 'Core' do |subspec|
      subspec.frameworks = 'UIKit'
      rxSwift(subspec)
      snapKit(subspec)
      subspec.source_files = 'Source/Core/**/*.swift'
  end

  spec.subspec 'Result' do |subspec|
      result(subspec)
      rxSwift(subspec)
      rxOptional(subspec)
      subspec.source_files = 'Source/Result/**/*.swift'
  end

  spec.subspec 'Validation' do |subspec|
      result(subspec)
      subspec.source_files = 'Source/Validation/**/*.swift'
  end

  spec.subspec 'TableView' do |subspec|
      subspec.frameworks = 'UIKit'
      subspec.dependency 'Reactant/Core'
      rxCocoa(subspec)
      rxDataSources(subspec)
      subspec.source_files = ['Source/TableView/**/*.swift', 'Source/CollectionView/CollectionViewState.swift', 'Source/CollectionView/Properties+CollectionView.swift']
  end

  spec.subspec 'CollectionView' do |subspec|
      subspec.frameworks = 'UIKit'
      subspec.dependency 'Reactant/Core'
      rxCocoa(subspec)
      rxDataSources(subspec)
      subspec.source_files = 'Source/CollectionView/**/*.swift'
  end

  spec.default_subspec = 'Core', 'Result'
end
