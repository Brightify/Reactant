Pod::Spec.new do |spec|
  spec.name             = 'ReactantLiveUI'
  spec.version          = '0.0.1'
  spec.summary          = 'Imagine React Native in Swift and you get Reactant.'
  spec.description      = <<-DESC
                        We combined the strength of RxSwift with pure Swift and
                        made a framework for highly reusable and clean views.
                       DESC
  spec.homepage         = 'https://github.com/Brightify/Reactant'
  spec.license          = 'MIT'
  spec.author           = { 'Tadeas Kriz' => 'tadeas@brightify.org', 'Matous Hybl' => 'matous@brightify.org', "Filip Dolnik" => "filip@brightify.org" }
  spec.source           = {
      :git => 'https://github.com/Brightify/Reactant.git',
      :tag => spec.version.to_s
  }
  spec.social_media_url = 'https://twitter.com/BrightifyOrg'
  spec.requires_arc = true
#spec.preserve_paths = ['ReactantUI/**/*']
#  spec.prepare_command = <<-CMD
#    cd ReactantUI
#    swift build
#    cp ./.build/debug/reactant-ui ./
#  CMD

  spec.ios.deployment_target = '9.0'
  spec.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS[config=Debug]' => '-D ReactantRuntime'
  }
  spec.dependency 'SWXMLHash'
  spec.dependency 'FileKit'
  spec.dependency 'SnapKit'
  spec.dependency 'Reactant'
  spec.dependency 'KZFileWatchers'
  spec.source_files = ['Source/LiveUI/**/*.swift', 'ReactantUI/Sources/ReactantUITokenizer/**/*.swift']

end
