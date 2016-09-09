source 'https://github.com/CocoaPods/Specs.git'
source 'http://source.tmspark.com/scm/base/private-specs.git'

use_frameworks!

target 'Reactant' do
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'SwiftKit', '0.9.0'
    pod 'RxDataSources'
    pod 'RxOptional'
    pod 'Lipstick'
    pod 'TZStackView'
    pod 'SnapKit'
    pod 'HTTPStatusCodes'
    pod 'HanekeSwift'
end

target 'ReactantExample' do
  pod 'Reactant', :path => './'


  target 'ReactantTests' do
    inherit! :search_paths

    pod 'Quick', '~> 0.8'
    pod 'Nimble', '~> 3.0'
  end
end
