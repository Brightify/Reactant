source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
inhibit_all_warnings!

def rxSwift
    pod 'RxSwift', '~> 4.0'
end

def rxCocoa
    pod 'RxCocoa', '~> 4.0'
end

def rxDataSources
    pod 'RxDataSources', '~> 3.0'
end

def rxOptional
    pod 'RxOptional', '~> 3.0'
end

def snapKit
    pod 'SnapKit', '~> 4.0'
end

def kingfisher
    pod 'Kingfisher', '~> 4.0'
end

def shared
    rxSwift
    rxCocoa
    rxDataSources
    rxOptional
    snapKit
    kingfisher
end

abstract_target 'Reactant-iOS' do
    platform :ios, '9.0'

    target 'Reactant' do
        snapKit
        kingfisher
    end

    target 'RxReactant' do
        shared
    end

    abstract_target 'Tests' do
        pod 'Quick', '~> 1.3'
        pod 'Nimble', '~> 7.1'
        pod 'Cuckoo', :git => 'https://github.com/Brightify/Cuckoo.git', :branch => 'master'
        pod 'RxNimble'
        pod 'RxTest'

        target 'ReactantTests' do
            snapKit
            kingfisher
        end

        target 'RxReactantTests' do
            shared
        end
    end
#
#    target 'ReactantTests' do
#        shared
#
#        pod 'Quick', '~> 1.3'
#        pod 'Nimble', '~> 7.1'
#        pod 'Cuckoo', :git => 'https://github.com/Brightify/Cuckoo.git', :branch => 'master'
#        pod 'RxNimble'
#        pod 'RxTest'
#    end

    target 'ReactantPrototyping' do
        shared
    end

end

abstract_target 'Reactant-tvOS' do
    platform :tvos, '9.2'

    target 'TVPrototyping' do
        shared

#        pod 'Reactant', :subspecs => ['All-tvOS', 'FallbackSafeAreaInsets'], :path => './'
    end
end

# Required until CocoaPods adds support for targets with multiple Swift versions or when all dependencies support Swift 4.2
post_install do |installer|
    installer.pods_project.targets.each do |target|
        unless target.name.start_with? 'Reactant'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.1'
            end
        end
    end
end
