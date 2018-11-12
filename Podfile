source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
inhibit_all_warnings!

def shared
    pod 'RxSwift', '~> 4.0'
    pod 'RxCocoa', '~> 4.0'
    pod 'RxOptional', '~> 3.0'
    pod 'SnapKit', '~> 4.0'
    pod 'Kingfisher', '~> 4.0'
    pod 'Result', '~> 3.0'
end

def shared_ios
    shared
    pod 'RxDataSources', '~> 3.0'
end

target 'Reactant' do
    platform :ios, '9.0'
    shared_ios
end

target 'ReactantTests' do
    platform :ios, '9.0'
    shared_ios

    pod 'Quick', '~> 1.1'
    pod 'Nimble', '~> 7.0'
    pod 'Cuckoo', :git => 'https://github.com/Brightify/Cuckoo.git', :branch => 'master'
    pod 'RxNimble'
    pod 'RxTest'
end

target 'ReactantPrototyping' do
    platform :ios, '9.0'
    shared_ios

    pod 'Reactant', :subspecs => ['All-iOS'], :path => './'
end

target 'TVPrototyping' do
    platform :tvos, '9.2'
    shared_ios

    pod 'Reactant', :subspecs => ['All-tvOS', 'FallbackSafeAreaInsets'], :path => './'
end

target 'ReactantMacOS' do
    platform :osx, '10.11'
    shared
    
    pod 'Reactant', :path => './'
end

target 'ReactantExample-macOS' do
    platform :osx, '10.11'
    shared
    
    pod 'Reactant', :path => './', :subspecs => ['Core']
end
