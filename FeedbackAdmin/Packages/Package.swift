// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let composable = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
private let dependencies = Target.Dependency.product(name: "Dependencies", package: "swift-dependencies")
private let testOverlay = Target.Dependency.product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")

let package = Package(
    name: "Packages",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Application",
            targets: [
                "Application",
                "CloudClientLive"
            ]
        ),
        .library(
            name: "DemoPackages",
            targets: [
                "Demo"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "0.57.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.6.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.8.4"),
        
        .package(url: "https://github.com/coodly/swlogger.git", exact: "0.4.3"),
        .package(name: "CloudFeedback", path: "../../")
    ],
    targets: [
        .target(
            name: "Application",
            dependencies: [
                "CloudClient",
                "ConversationsFeature",
                "Logging",
                "MessagesFeature",
                "PersistenceClient",
                
                composable
            ]
        ),
        .target(
            name: "CloudClient",
            dependencies: [
                "Logging",
                
                dependencies,
                testOverlay
            ]
        ),
        .target(
            name: "CloudClientLive",
            dependencies: [
                "CloudClient",
                "Logging"
            ]
        ),
        .target(
            name: "ConversationsFeature",
            dependencies: [
                "MessagesFeature",
                "ObjectModel",
                "UIComponents",
                
                composable
            ]
        ),
        .target(
            name: "Demo",
            dependencies: [
                "CloudFeedback"
            ]
        ),
        .target(
            name: "Extensions"
        ),
        .target(
            name: "Logging",
            dependencies: [
                .product(name: "SWLogger", package: "swlogger")
            ]
        ),
        .target(
            name: "MessagesFeature",
            dependencies: [
                "ObjectModel",
                "UIComponents",
                "WriteMessageFeature",
                
                "CloudFeedback",
                composable
            ]
        ),
        .target(
            name: "ObjectModel",
            dependencies: [
                "Logging"
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "PersistenceClient",
            dependencies: [
                "ObjectModel",
                
                dependencies,
                testOverlay
            ]
        ),
        .target(
            name: "UIComponents"
        ),
        .target(
            name: "WriteMessageFeature",
            dependencies: [
                "Extensions",
                
                composable
            ]
        )
    ]
)
