// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let composable = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")

let package = Package(
    name: "Packages",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Application",
            targets: ["Application"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.33.1"),
        .package(name: "SWLogger", url: "https://github.com/coodly/swlogger.git", from: "0.4.3"),
    ],
    targets: [
        .target(
            name: "Application",
            dependencies: [
                "CloudClient",
                "PersistenceClient",
                
                composable
            ]
        ),
        .target(
            name: "CloudClient",
            dependencies: [
                "Logging"
            ]
        ),
        .target(
            name: "Logging",
            dependencies: [
                "SWLogger"
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
                "ObjectModel"
            ]
        )
    ]
)
