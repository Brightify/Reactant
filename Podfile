source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
inhibit_all_warnings!

abstract_target 'Reactant' do
    podspec :path => './Reactant.podspec'

    target 'Reactant-iOS' do
        platform :ios, '9.0'
    end

    target 'Reactant-tvOS' do
        platform :tvos, '9.2'
    end

    target 'ReactantTests' do
        inherit! :search_paths

        platform :ios, '9.0'

        pod 'Quick', '~> 1.1'
        pod 'Nimble', '~> 7.0'
        pod 'Cuckoo'
        pod 'RxNimble'
        pod 'RxTest'
    end
end

# target 'Reactant' do
#     platform :ios, '9.0'
#
#     podspec :path => './Reactant.podspec'
#
#     target 'ReactantTests' do
#         inherit! :search_paths
#
#         platform :ios, '9.0'
#
#         pod 'Quick', '~> 1.1'
#         pod 'Nimble', '~> 7.0'
#         pod 'Cuckoo'
#         pod 'RxNimble'
#         pod 'RxTest'
#     end
# end

target 'ReactantPrototyping' do
    platform :ios, '8.0'

    pod 'Reactant', :subspecs => ['All-iOS'], :path => './'
end

target 'TVPrototyping' do
    platform :tvos, '9.2'

    pod 'Reactant', :subspecs => ['All-tvOS', 'FallbackSafeAreaInsets'], :path => './'
end

# Required until CocoaPods adds support for targets with multiple Swift versions or when all dependencies support Swift 4.0
#post_install do |installer|
#    installer.pods_project.targets.each do |target|
#        if target.name != 'Reactant'
#            target.build_configurations.each do |config|
#                config.build_settings['SWIFT_VERSION'] = '3.2'
#            end
#        end
#    end
#end
