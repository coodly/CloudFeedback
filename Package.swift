// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CloudFeedback",
    platforms: [.iOS(.v14), .macOS(.v11)],
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
            name: "CloudFeedback"
        ),
        
        .testTarget(
            name: "CloudFeedbackTests",
            dependencies: [
                "CloudFeedback"
            ]
        ),
    ]
)
