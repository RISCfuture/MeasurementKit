# MeasurementKit

[![CI](https://github.com/RISCfuture/MeasurementKit/actions/workflows/ci.yml/badge.svg)](https://github.com/RISCfuture/MeasurementKit/actions/workflows/ci.yml)
[![Documentation](https://github.com/RISCfuture/MeasurementKit/actions/workflows/documentation.yml/badge.svg)](https://riscfuture.github.io/MeasurementKit/)
[![Swift 6.2+](https://img.shields.io/badge/Swift-6.2+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS%20|%20visionOS-blue.svg)](https://swift.org)

Arithmetic, units and dimensions that Foundation's `Measurement` leaves out, for aviation and
general physical work.

## Features

- **Cross-dimensional arithmetic**: sixty concrete operators covering kinematics, geometry,
  density and flow, force and energy, rotation, and Ohm's law
- **Results in the unit you would have written**: 120 knots for two hours is exactly 240 nautical
  miles, and a hundred gallons at 6.7 lb/gal weighs 670 pounds — not 303.9 kilograms
- **Dimensions Foundation omits**: force, slope, density, angular velocity, volumetric and mass
  flow rate, and temperature difference
- **Temperature safety**: dividing two temperature readings does not compile, because an interval
  scale has no meaningful ratio; a difference gets its own dimension instead
- **Datum-safe bearings**: a magnetic bearing and a true one are different types, so mixing them
  is a compile error rather than a navigation error
- **A SwiftUI measurement field** that places the unit the way the locale actually writes it,
  including locales that lead with it or write it without a number at all
- **Core Location interop** whose optionals encode the negative sentinels `CLLocation` uses for an
  unavailable speed or course
- **Composes with Foundation**: no replacement `Measurement` type, no retroactive conformance
  imposed on your app, and no overload of an operator Foundation already defines

## Requirements

- Swift 6.2+
- macOS 15+, iOS 18+, tvOS 18+, watchOS 11+, or visionOS 2+

## Installation

### Swift Package Manager

Add MeasurementKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/RISCfuture/MeasurementKit.git", from: "1.0.0")
]
```

Then add the products you need to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: ["MeasurementKit", "MeasurementKitUI"]
)
```

Or in Xcode: File > Add Package Dependencies > Enter the repository URL.

The package ships four products so a widget or watch app can link only what it needs:

| Product | Adds | Depends on |
| --- | --- | --- |
| `MeasurementKit` | operators, dimensions, formatting | Foundation only |
| `MeasurementKitLocation` | bearings, geodesy, `CLLocation` interop | Core Location |
| `MeasurementKitUI` | `MeasurementField`, binding projections | SwiftUI |
| `MeasurementKitDefaults` | `UserDefaults` persistence | sindresorhus/Defaults |

## Quick Start

### Crossing dimensions

```swift
import MeasurementKit

let groundSpeed = Measurement(value: 120, unit: UnitSpeed.knots)
let leg = Measurement(value: 2, unit: UnitDuration.hours)

groundSpeed * leg                       // 240 NM, exactly
leg * groundSpeed                       // the same, in the same unit
```

### Fuel

```swift
let fuel = Measurement(value: 100, unit: UnitVolume.gallons)
let density = Measurement(value: 6.7, unit: UnitDensity.poundsPerGallon)
let flow = Measurement(value: 20, unit: UnitVolumetricFlowRate.gallonsPerHour)

fuel * density                          // 670 lb
fuel / flow                             // 5 hr
flow * density                          // 134 lb/hr
```

### Temperature differences

```swift
let standard = Measurement(value: 15, unit: UnitTemperature.celsius)
let deviation = Measurement(value: 10, unit: UnitTemperatureDifference.celsius)

standard.deviated(by: deviation)        // 25 °C
// standard / standard                  // does not compile, and should not
```

### Totalling without drifting

```swift
let legs = [
    Measurement(value: 100, unit: UnitLength.nauticalMiles),
    Measurement(value: 50, unit: UnitLength.nauticalMiles)
]

legs.sum(in: .nauticalMiles)            // 150 NM
```

### Editing a measurement

```swift
import MeasurementKitUI

MeasurementField(
    "Empty Weight",
    value: $emptyWeight,
    in: .pounds,
    format: .measurement(width: .abbreviated, usage: .asProvided),
    minimum: .init(value: 0, unit: .pounds)
)
```

## Running Tests

```bash
swift test
```

## Building Documentation

Generate documentation locally with:

```bash
swift package generate-documentation --target MeasurementKit
```

Preview it in a browser:

```bash
swift package --disable-sandbox preview-documentation --target MeasurementKit
```

## Documentation

Full documentation is available at
[riscfuture.github.io/MeasurementKit](https://riscfuture.github.io/MeasurementKit/).

## License

MeasurementKit is released under the MIT License. See
[LICENSE.md](LICENSE.md) for details.
