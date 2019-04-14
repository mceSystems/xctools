// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "xctools",
    dependencies: [
      .package(url: "https://github.com/kylef/Commander.git", .exact("0.8.0")),
      .package(url: "https://github.com/kareman/SwiftShell.git", .exact("4.1.2")),
      .package(url: "https://github.com/kylef/PathKit.git", .exact("0.9.2")),
      .package(url: "https://github.com/xcodeswift/xcproj.git", .exact("1.8.0"))
    ],
    targets: [
      .target(
        name: "Core",
        dependencies: [
          "PathKit",
          "SwiftShell"
        ]
      ),
      .testTarget(name: "CoreTests", dependencies: ["Core", "TestsFoundation"]),
      .target(
        name: "Version",
        dependencies: [
          "xcproj",
          "PathKit",
          .target(name: "Core"),
        ]
      ),
      .testTarget(name: "VersionTests", dependencies: ["Version", "TestsFoundation"]),
      .target(
        name: "Frameworks",
        dependencies: [
          "SwiftShell",
          .target(name: "Core")
        ]
      ),
      .target(
        name: "BuildSettings",
        dependencies: [
          "xcproj",
          .target(name: "Core"),
        ]
      ),
      .testTarget(name: "BuildSettingsTests", dependencies: ["BuildSettings"]),
      .testTarget(name: "FrameworksTests", dependencies: ["Frameworks", "PathKit", "TestsFoundation"]),
      .target(
        name: "xctools",
        dependencies: [
          "Commander",
          .target(name: "Core"),
          .target(name: "Frameworks"),
          .target(name: "Version"),
          .target(name: "BuildSettings")
        ]
      ),
      .target(name: "TestsFoundation", dependencies: ["PathKit"] )
    ],
    swiftLanguageVersions: [4]
)
