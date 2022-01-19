// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CloudFeedback",
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
