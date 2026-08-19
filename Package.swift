// swift-tools-version: 6.2

import PackageDescription

let approachableConcurrency: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances")
]

// MeasurementKitLocation needs Core Location and MeasurementKitUI needs SwiftUI, neither of which
// exists on Linux; the Foundation-only core and its tests build and run everywhere.
var products: [Product] = [
  .library(
    name: "MeasurementKit",
    targets: ["MeasurementKit"]
  )
]

var targets: [Target] = [
  .target(
    name: "MeasurementKit",
    dependencies: [.product(name: "Numerics", package: "swift-numerics")],
    swiftSettings: approachableConcurrency
  ),
  .testTarget(
    name: "MeasurementKitTests",
    dependencies: [
      "MeasurementKit",
      .product(name: "Numerics", package: "swift-numerics")
    ],
    swiftSettings: approachableConcurrency
  )
]

#if !os(Linux)
  products += [
    .library(
      name: "MeasurementKitLocation",
      targets: ["MeasurementKitLocation"]
    ),
    .library(
      name: "MeasurementKitUI",
      targets: ["MeasurementKitUI"]
    ),
    .library(
      name: "MeasurementKitDefaults",
      targets: ["MeasurementKitDefaults"]
    )
  ]

  targets += [
    .target(
      name: "MeasurementKitLocation",
      dependencies: [
        "MeasurementKit",
        .product(name: "Numerics", package: "swift-numerics")
      ],
      swiftSettings: approachableConcurrency
    ),
    .target(
      name: "MeasurementKitUI",
      dependencies: ["MeasurementKit"],
      swiftSettings: approachableConcurrency
    ),
    .target(
      name: "MeasurementKitDefaults",
      dependencies: [
        "MeasurementKit",
        .product(name: "Defaults", package: "Defaults")
      ],
      swiftSettings: approachableConcurrency
    ),
    .testTarget(
      name: "MeasurementKitLocationTests",
      dependencies: [
        "MeasurementKitLocation",
        .product(name: "Numerics", package: "swift-numerics")
      ],
      swiftSettings: approachableConcurrency
    ),
    .testTarget(
      name: "MeasurementKitUITests",
      dependencies: ["MeasurementKitUI"],
      swiftSettings: approachableConcurrency
    ),
    .testTarget(
      name: "MeasurementKitDefaultsTests",
      dependencies: ["MeasurementKitDefaults"],
      swiftSettings: approachableConcurrency
    )
  ]
#endif

let package = Package(
  name: "MeasurementKit",
  platforms: [
    .macOS(.v15),
    .iOS(.v18),
    .tvOS(.v18),
    .watchOS(.v11),
    .visionOS(.v2)
  ],
  products: products,
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3"),
    .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    .package(url: "https://github.com/sindresorhus/Defaults", from: "9.0.0")
  ],
  targets: targets,
  swiftLanguageModes: [.v5, .v6]
)
