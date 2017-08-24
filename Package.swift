// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "xcode",
    dependencies: [
    .Package(url: "https://github.com/kylef/Commander.git", majorVersion: 0, minor: 6),
    .Package(url: "https://github.com/kareman/SwiftShell", majorVersion: 3, minor: 0),
    .Package(url: "https://github.com/kylef/PathKit", majorVersion: 0, minor: 8)
  ]
)
