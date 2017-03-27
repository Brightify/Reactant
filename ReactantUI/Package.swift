// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "ReactantUI",
    targets: [
        Target(name: "ReactantUIGeneratorFramework", dependencies: []),

        Target(name: "reactant-ui", dependencies: [
            .Target(name: "ReactantUIGeneratorFramework")]),
    ],
    dependencies: [
        .Package(url: "https://github.com/Carthage/Commandant.git", versions: Version(0, 11, 3)..<Version(0, 11, .max)),
        .Package(url: "https://github.com/drmohundro/SWXMLHash.git", versions: Version(3, 0, 0)..<Version(3, .max, .max)),
        //.Package(url: "https://github.com/jpsim/SourceKitten.git", versions: Version(0, 15, 0)..<Version(0, 17, .max)),
        .Package(url: "https://github.com/TadeasKriz/FileKit.git", Version(4, 0, 2)),
        //.Package(url: "https://github.com/kylef/Stencil.git", majorVersion: 0, minor: 8),
    ]
)
