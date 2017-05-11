source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
inhibit_all_warnings!

def shared
    pod 'RxSwift', '~> 3.0'
    pod 'RxCocoa', '~> 3.0'
    pod 'RxOptional', '~> 3.0'
    pod 'SnapKit', '~> 3.0'
    pod 'Kingfisher', '~> 3.0'
    pod 'Result', '~> 3.0'
end

target 'Reactant' do
    platform :ios, '9.0'
    shared

    # pod 'RxDataSources', '~> 1.0'
end

target 'ReactantTests' do
    platform :ios, '9.0'
    shared
    # pod 'RxDataSources', '~> 1.0'

    pod 'Quick', '~> 1.0'
    pod 'Nimble', '~> 5.0'
end

target 'ReactantPrototyping' do
    platform :ios, '9.0'
    shared
    # pod 'RxDataSources', '~> 1.0'

    pod 'Reactant', :path => './'
end

target 'ReactantMacOS' do
    platform :osx, '10.11'

    shared

    pod 'Reactant', :path => './'
end

target 'ReactantExample-macOS' do
    platform :osx, '10.11'
    pod 'RxSwift', '~> 3.0'
    pod 'RxCocoa', '~> 3.0'
    pod 'RxOptional', '~> 3.0'
    pod 'SnapKit', '~> 3.0'
    pod 'Kingfisher', '~> 3.0'
    pod 'Result', '~> 3.0'
    pod 'Reactant', :path => './', :subspecs => ['Core']
end
