// swift-tools-version: 6.2

import PackageDescription

let upcomingFeatures: [SwiftSetting] = [
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("ImmutableWeakCaptures"),
  .enableUpcomingFeature("MemberImportVisibility"),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("InternalImportsByDefault"),
  .strictMemorySafety()
]

// MeasurementKitLocation needs Core Location and MeasurementKitUI needs SwiftUI, neither of which
// exists on Linux; the Foundation-only core and its tests build and run everywhere.
//
// The three that build on the core are dynamic, so that they link it rather than absorb it. Left
// to link statically, each copies the core's object code into whatever links it, and an app using
// two of them registers the core's classes once per product. Two registrations of `UnitSlope` are
// two distinct classes to the Objective-C runtime, and `Measurement`'s comparison operators trap
// rather than convert when the units either side come from different ones.
//
// The core itself stays automatic: a dynamic library product cannot share a name with the target
// it vends, and renaming either would break every consumer's `import`.
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
    swiftSettings: upcomingFeatures
  ),
  .testTarget(
    name: "MeasurementKitTests",
    dependencies: [
      "MeasurementKit",
      .product(name: "Numerics", package: "swift-numerics")
    ],
    swiftSettings: upcomingFeatures
  )
]

#if !os(Linux)
  products += [
    .library(
      name: "MeasurementKitLocation",
      type: .dynamic,
      targets: ["MeasurementKitLocation"]
    ),
    .library(
      name: "MeasurementKitUI",
      type: .dynamic,
      targets: ["MeasurementKitUI"]
    ),
    .library(
      name: "MeasurementKitDefaults",
      type: .dynamic,
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
      swiftSettings: upcomingFeatures
    ),
    .target(
      name: "MeasurementKitUI",
      dependencies: ["MeasurementKit"],
      swiftSettings: upcomingFeatures
    ),
    .target(
      name: "MeasurementKitDefaults",
      dependencies: [
        "MeasurementKit",
        .product(name: "Defaults", package: "Defaults")
      ],
      swiftSettings: upcomingFeatures
    ),
    .testTarget(
      name: "MeasurementKitLocationTests",
      dependencies: [
        "MeasurementKitLocation",
        .product(name: "Numerics", package: "swift-numerics")
      ],
      swiftSettings: upcomingFeatures
    ),
    .testTarget(
      name: "MeasurementKitUITests",
      dependencies: ["MeasurementKitUI"],
      swiftSettings: upcomingFeatures
    ),
    .testTarget(
      name: "MeasurementKitDefaultsTests",
      dependencies: ["MeasurementKitDefaults"],
      swiftSettings: upcomingFeatures
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
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.5.0"),
    .package(url: "https://github.com/apple/swift-numerics", from: "1.1.1"),
    .package(url: "https://github.com/sindresorhus/Defaults", from: "9.0.9")
  ],
  targets: targets,
  swiftLanguageModes: [.v5, .v6]
)
