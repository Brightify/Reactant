source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

def shared
    pod 'RxSwift', '~> 3.0'
    pod 'RxCocoa', '~> 3.0'
    pod 'RxDataSources', '~> 1.0'
    pod 'RxOptional', '~> 3.0'
    pod 'SnapKit', '~> 3.0'
    pod 'Kingfisher', '~> 3.0'
    pod 'Result', '~> 3.0'
end

target 'Reactant' do
    shared
end

target 'ReactantTests' do
    shared
    
    pod 'Quick', '~> 1.0'
    pod 'Nimble', '~> 5.0'
end

target 'ReactantPrototyping' do
    shared
end
