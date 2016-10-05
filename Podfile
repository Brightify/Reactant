source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'Reactant' do
    pod 'RxSwift', '3.0.0-beta.2'
    pod 'RxCocoa', '3.0.0-beta.2'
    pod 'SwiftKit', '0.10.0'
    pod 'RxDataSources', '1.0.0-beta.2'
    pod 'RxOptional', :git => 'https://github.com/ivanbruel/RxOptional.git', :commit => '93d12b3c3bfc1886ebd038149b24a8d7d6ef1ea4'
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
