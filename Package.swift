// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HTMLAttributor",
  platforms: [
      .iOS(.v13)
  ],
  products: [
    .library(
      name: "HTMLAttributor",
      targets: ["HTMLAttributor"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "HTMLAttributor",
      dependencies: []),
    .testTarget(
      name: "HTMLAttributorTests",
      dependencies: ["HTMLAttributor"],
      resources: [.process("./missingLink.html")])
  ]
)
