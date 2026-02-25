// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CloudFeedback",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    .library(
      name: "CloudFeedback",
      targets: [
        "CloudFeedback"
      ]
    ),
  ],
  dependencies: [

  ],
  targets: [
    .target(
      name: "CloudFeedback",
      swiftSettings: [.swiftLanguageMode(.v5)]
    ),

    .testTarget(
      name: "CloudFeedbackTests",
      dependencies: [
        "CloudFeedback"
      ]
    ),
  ]
)
