// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let composable = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
private let dependencies = Target.Dependency.product(name: "Dependencies", package: "swift-dependencies")
private let dependenciesMacros = Target.Dependency.product(name: "DependenciesMacros", package: "swift-dependencies")

private let withConcurrencyFlags: [SwiftSetting] = [
  .enableUpcomingFeature("BareSlashRegexLiterals"),
  .enableUpcomingFeature("ConciseMagicFile"),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("ForwardTrailingClosures"),
  .enableUpcomingFeature("ImplicitOpenExistentials"),
  .enableUpcomingFeature("StrictConcurrency"),
  SwiftSetting.unsafeFlags(
    [
      "-Xfrontend",
      "-warn-long-function-bodies=100",
      "-Xfrontend",
      "-warn-long-expression-type-checking=100",
      "-Xfrontend",
      "-warn-concurrency",
      "-Xfrontend",
      "-enable-actor-data-race-checks"
    ]
  ),
  .swiftLanguageMode(.v5)
]

let package = Package(
  name: "Packages",
  platforms: [.iOS(.v17)],
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
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "1.24.1"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", exact: "1.11.0"),
        
    .package(url: "https://github.com/coodly/swlogger.git", branch: "feature/concurrency-experiment"),
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
                
        dependencies
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
        dependenciesMacros
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
  .map { (target: Target) in
    guard target.swiftSettings == nil else {
      return target
    }
        
    target.swiftSettings = withConcurrencyFlags
    return target
  }
)
