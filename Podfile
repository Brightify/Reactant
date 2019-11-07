source 'https://cdn.cocoapods.org/'
use_frameworks!
inhibit_all_warnings!

def shared
    pod 'RxSwift', '~> 5.0'
    pod 'RxCocoa', '~> 5.0'
    pod 'RxDataSources', '~> 4.0'
    pod 'RxOptional', '~> 4.0'
    pod 'SnapKit', '~> 5.0'
    pod 'Kingfisher', '~> 5.0'
end

target 'Reactant' do
    platform :ios, '10.0'

    shared
end

target 'ReactantTests' do
    platform :ios, '10.0'

    shared

    pod 'Quick', '~> 2.0'
    pod 'Nimble', '~> 7.0'
    pod 'Cuckoo', :git => 'https://github.com/Brightify/Cuckoo.git', :branch => 'master'
    pod 'RxNimble'
    pod 'RxTest'
end

target 'ReactantPrototyping' do
    platform :ios, '10.0'

    shared

    pod 'Reactant', :subspecs => ['All-iOS'], :path => './'
end

target 'TVPrototyping' do
    platform :tvos, '10.0'
    shared

    pod 'Reactant', :subspecs => ['All-tvOS', 'FallbackSafeAreaInsets'], :path => './'
end
