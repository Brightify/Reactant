#
# Be sure to run `pod lib lint ProjectBase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
    spec.name             = 'Reactant'
    spec.version          = '1.0.3'
    spec.summary          = 'Reactant is a reactive architecture for iOS'

    spec.description      = <<-DESC
                            Reactant is a foundation for rapid and safe iOS development. It allows you to cut down your development costs by improving reusability, testability and safety of your code, especially your UI.
                            DESC
    spec.homepage         = 'https://www.reactant.tech'
    spec.license          = 'MIT'
    spec.author           = {
        'Tadeas Kriz' => 'tadeas@brightify.org',
        'Matous Hybl' => 'matous@brightify.org',
        'Filip Dolnik' => 'filip@brightify.org'
    }
    spec.source           = {
        :git => 'https://github.com/Brightify/Reactant.git',
        :tag => spec.version.to_s
    }
    spec.social_media_url = 'https://twitter.com/BrightifyOrg'
    spec.requires_arc = true

    spec.ios.deployment_target = '9.0'
    spec.osx.deployment_target = '10.11'
    spec.default_subspec = 'Core', 'Result'

    def self.rxSwift(subspec)
        subspec.dependency 'RxSwift', '~> 3.0'
    end
    def self.snapKit(subspec)
        subspec.dependency 'SnapKit', '~> 3.0'
    end
    def self.result(subspec)
        subspec.dependency 'Result', '~> 3.0'
    end
    def self.rxCocoa(subspec)
        subspec.dependency 'RxCocoa', '~> 3.0'
    end
    def self.rxDataSources(subspec)
        subspec.dependency 'RxDataSources', '~> 1.0'
    end
    def self.rxOptional(subspec)
        subspec.dependency 'RxOptional', '~> 3.0'
    end
    def self.kingfisher(subspec)
        subspec.dependency 'Kingfisher', '~> 3.0'
    end

    spec.subspec 'Core' do |subspec|
        subspec.dependency 'Reactant/Configuration'
        rxSwift(subspec)
        rxCocoa(subspec)
        rxOptional(subspec)
        snapKit(subspec)
        subspec.source_files = [
            'Source/Core/**/*.swift',
            'Source/Utils/**/*.swift'
        ]
        subspec.osx.source_files = 'SourceMacOS/Core/**/*.swift'
    end

    spec.subspec 'Configuration' do |subspec|
        rxSwift(subspec)
        snapKit(subspec)
        subspec.source_files = 'Source/Configuration/**/*.swift'
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
        subspec.ios.deployment_target = '9.0'
        subspec.frameworks = 'UIKit'
        subspec.dependency 'Reactant/Core'
        rxCocoa(subspec)
        rxDataSources(subspec)
        subspec.source_files = [
            'Source/TableView/**/*.swift',
            'Source/CollectionView/CollectionViewState.swift'
        ]
    end

    spec.subspec 'CollectionView' do |subspec|
        subspec.ios.deployment_target = '9.0'
        subspec.frameworks = 'UIKit'
        subspec.dependency 'Reactant/Core'
        rxCocoa(subspec)
        rxDataSources(subspec)
        subspec.source_files = 'Source/CollectionView/**/*.swift'
    end

    spec.subspec 'ActivityIndicator' do |subspec|
        rxCocoa(subspec)
        subspec.source_files = 'Source/ActivityIndicator/**/*.swift'
    end

    spec.subspec 'StaticMap' do |subspec|
        subspec.ios.deployment_target = '9.0'
        subspec.frameworks = ['UIKit', 'MapKit']
        subspec.dependency 'Reactant/Core'
        rxCocoa(subspec)
        kingfisher(subspec)
        subspec.source_files = 'Source/StaticMap/**/*.swift'
    end
end
