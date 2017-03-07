source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

def common
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RxOptional'
    pod 'SnapKit'
    pod 'Kingfisher'
    pod 'Result', '~> 3.0.0'
end

target 'Reactant' do
    platform :ios, '9.0'

    common

    pod 'RxDataSources'
end

target 'ReactantTests' do
    platform :ios, '9.0'

    pod 'Quick', '~> 1.0'
    pod 'Nimble', '~> 5.0'
end

target 'ReactantMacOS' do
    platform :osx, '10.11'

    common
end
