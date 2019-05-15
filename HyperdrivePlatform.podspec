#
# Be sure to run `pod lib lint ProjectBase.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
    spec.name             = 'HyperdrivePlatform'
    spec.version          = '2.0.0-alpha.1'
    spec.summary          = 'Hyperdrive is a reactive architecture for iOS, tvOS and macOS'

    spec.description      = <<-DESC
                            Hyperdrive is a foundation for rapid and safe iOS, tvOS and macOS development. It allows you to cut down your development costs by improving reusability, testability and safety of your code, especially your UI.
                            DESC
    spec.homepage         = 'https://www.reactant.tech'
    spec.license          = 'MIT'
    spec.author           = {
        'Tadeas Kriz' => 'tadeas@brightify.org',
        'Matous Hybl' => 'matous@brightify.org',
        'Filip Dolnik' => 'filip@brightify.org',
        'Matyas Kriz' => 'matyas@brightify.org'
    }
    spec.source           = {
        :git => 'https://github.com/Brightify/Reactant.git',
        :tag => spec.version.to_s
    }
    spec.social_media_url = 'https://twitter.com/BrightifyOrg'
    spec.requires_arc = true

    spec.module_name = 'Hyperdrive'
    spec.ios.deployment_target = '11.0'
    spec.tvos.deployment_target = '11.0'
    spec.default_subspec = 'Core'

    def self.rxSwift(subspec)
        subspec.dependency 'RxSwift', '~> 4.0'
    end
    def self.snapKit(subspec)
        subspec.dependency 'SnapKit', '~> 4.0'
    end
    def self.rxCocoa(subspec)
        subspec.dependency 'RxCocoa', '~> 4.0'
    end
    def self.rxDataSources(subspec)
        subspec.dependency 'RxDataSources', '~> 3.0'
    end
    def self.rxOptional(subspec)
        subspec.dependency 'RxOptional', '~> 3.0'
    end
    def self.kingfisher(subspec)
        subspec.dependency 'Kingfisher', '~> 4.0'
    end

    spec.subspec 'Core' do |subspec|
        subspec.frameworks = 'UIKit'
        subspec.dependency 'HyperdrivePlatform/Configuration'

        snapKit(subspec)

        subspec.source_files = [
            'Source/_Core/**/*.swift',
            'Source/Core/**/*.swift',
            'Source/Interface/**/*.swift',
            'Source/Utils/**/*.swift'
        ]
        subspec.exclude_files = [
            'Source/_Core/Styling/Extensions/**/*.swift'
        ]
    end

    spec.subspec 'Core+RxSwift' do |rxcore|
        rxcore.dependency 'HyperdrivePlatform/Core'
        rxcore.pod_target_xcconfig = {
            'OTHER_SWIFT_FLAGS' => '-DENABLE_RXSWIFT'
        }
        rxcore.source_files = [
            'Source/Core+RxSwift/**/*.swift',
            'Source/Utils+RxSwift/**/*.swift'
        ]

        rxOptional(rxcore)
        rxSwift(rxcore)
        rxCocoa(rxcore)
    end

    spec.subspec 'Configuration' do |subspec|
        subspec.frameworks = 'UIKit'
        subspec.source_files = 'Source/Configuration/**/*.swift'
    end

    spec.subspec 'Validation' do |subspec|
        subspec.source_files = 'Source/Validation/**/*.swift'
    end

    spec.subspec 'TableView' do |subspec|
        subspec.frameworks = 'UIKit'
        subspec.dependency 'HyperdrivePlatform/Core'
        rxCocoa(subspec)
        rxDataSources(subspec)
        subspec.source_files = [
            'Source/TableView/**/*.swift',
            'Source/CollectionView/CollectionViewState.swift'
        ]
    end

    spec.subspec 'CollectionView' do |subspec|
        subspec.frameworks = 'UIKit'
        subspec.dependency 'HyperdrivePlatform/Core'
        subspec.source_files = 'Source/CollectionView/**/*.swift'
    end

    spec.subspec 'ActivityIndicator' do |subspec|
        subspec.frameworks = 'UIKit'
        rxCocoa(subspec)
        subspec.source_files = 'Source/ActivityIndicator/**/*.swift'
    end

    spec.subspec 'StaticMap' do |subspec|
        subspec.frameworks = ['UIKit', 'MapKit']
        subspec.dependency 'HyperdrivePlatform/Core'
        kingfisher(subspec)
        subspec.source_files = 'Source/StaticMap/**/*.swift'
    end

    spec.subspec 'FallbackSafeAreaInsets' do |subspec|
        subspec.ios.deployment_target = '11.0'
        subspec.tvos.deployment_target = '11.0'

        subspec.dependency 'HyperdrivePlatform/Core'
        subspec.pod_target_xcconfig = {
            'OTHER_SWIFT_FLAGS' => '-DENABLE_SAFEAREAINSETS_FALLBACK'
        }
    end

    spec.subspec 'All-iOS' do |subspec|
        subspec.dependency 'HyperdrivePlatform/Core'
        subspec.dependency 'HyperdrivePlatform/Configuration'
        subspec.dependency 'HyperdrivePlatform/Validation'
        subspec.dependency 'HyperdrivePlatform/TableView'
        subspec.dependency 'HyperdrivePlatform/CollectionView'
        subspec.dependency 'HyperdrivePlatform/StaticMap'
        subspec.dependency 'HyperdrivePlatform/ActivityIndicator'
    end

    spec.subspec 'All-tvOS' do |subspec|
        subspec.dependency 'HyperdrivePlatform/Core'
        subspec.dependency 'HyperdrivePlatform/Configuration'
        subspec.dependency 'HyperdrivePlatform/Validation'
        subspec.dependency 'HyperdrivePlatform/TableView'
        subspec.dependency 'HyperdrivePlatform/CollectionView'
        subspec.dependency 'HyperdrivePlatform/StaticMap'
        subspec.dependency 'HyperdrivePlatform/ActivityIndicator'
    end
end
