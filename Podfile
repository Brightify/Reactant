source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'Reactant' do
    pod 'RxSwift', '3.0.0-beta.1'
    pod 'RxCocoa', '3.0.0-beta.1'
    pod 'SwiftKit', '0.10.0'
    pod 'RxDataSources', '1.0.0-beta.2'
    pod 'RxOptional', '3.0.0'
    pod 'Lipstick', '0.4.0'
    pod 'SnapKit', '3.0.1'
    pod 'HTTPStatusCodes', '3.1.0'
    pod 'HanekeSwift', :git => 'https://github.com/Haneke/HanekeSwift.git', :branch => 'feature/swift-3'
end

target 'ReactantExample' do
  pod 'Reactant', :path => './'
end

target 'ReactantTests' do
    pod 'Quick', :git => 'https://github.com/Quick/Quick.git', :branch => 'master'
    pod 'Nimble', '~> 5.0'
end
