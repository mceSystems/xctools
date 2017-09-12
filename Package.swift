// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "xcode",
    dependencies: [
      .package(url: "https://github.com/kylef/Commander.git", .upToNextMinor(from: "0.6.0")),
      .package(url: "https://github.com/kareman/SwiftShell.git", .upToNextMinor(from: "3.0.1")),
      .package(url: "https://github.com/kylef/PathKit.git", .upToNextMinor(from: "0.8.0")),
      .package(url: "https://github.com/carambalabs/xcodeproj.git", .upToNextMinor(from: "0.1.2"))
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
          "xcodeproj",
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
          "xcodeproj",
          .target(name: "Core"),
        ]
      ),
      .testTarget(name: "BuildSettingsTests", dependencies: ["BuildSettings"]),
      .testTarget(name: "FrameworksTests", dependencies: ["Frameworks", "PathKit", "TestsFoundation"]),
      .target(
        name: "xcode",
        dependencies: [
          "Commander",
          .target(name: "Core"),
          .target(name: "Frameworks"),
          .target(name: "Version"),
          .target(name: "BuildSettings")
        ]
      ),
      .testTarget(name: "TestsFoundation")
    ],
    swiftLanguageVersions: [3]
)
