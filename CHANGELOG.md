# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-09-09

### Changed

- `MeasurementKitLocation`, `MeasurementKitUI` and `MeasurementKitDefaults` are dynamic library
  products, so each links the core rather than absorbing a copy of it. **An Xcode target that links
  one of these products must also embed it**, as must any target that embeds a framework of your own
  which links one. Xcode builds these products without embedding them, so an app that skips this
  builds without a warning and passes its simulator tests, then dies at launch on a device with
  `Library not loaded: @rpath/MeasurementKitUI.framework/MeasurementKitUI`. See "Embedding in an
  Xcode app" in the README. A SwiftPM executable linking one of them now has a dynamic library to
  find at run time.

### Fixed

- A unit class is registered once per process rather than once per product linked. Linking two
  products that build on the core — `MeasurementKit` and `MeasurementKitUI`, say — used to give
  the process two registrations of every class the core declares, and two registrations of
  `UnitSlope` are two distinct classes to the Objective-C runtime. Comparing a measurement made
  against one with a measurement made against the other trapped in Foundation with "Attempt to
  compare measurements with non-equal dimensions" instead of converting.

## [1.0.0] - 2026-08-19

### Added

- Initial release of MeasurementKit
- Sixty cross-dimensional operators across kinematics, geometry, density and flow, force and
  energy, rotation, and Ohm's law, each answering in a unit derived from the left operand rather
  than in the dimension's base unit
- Dimensions Foundation omits: `UnitForce`, `UnitSlope`, `UnitDensity`, `UnitAngularVelocity`,
  `UnitVolumetricFlowRate`, `UnitMassFlowRate`, and `UnitTemperatureDifference`
- `ProportionalDimension`, which gates the same-dimension ratio so that dividing two temperature
  readings does not compile, and `DerivedDimension`, which lets a density or flow rate report the
  units it was built from so a product answers in them
- Accumulation that does not drift into the base unit: `zero(in:)`, `adding(_:)`,
  `subtracting(_:)`, and `Sequence.sum(in:)`
- Angle normalization, reciprocals correct for negative angles, and trigonometric overloads that
  take an angle rather than a bare number
- `Measurement.affixes(format:in:)`, which recovers the text a locale writes around a measurement's
  number under the caller's own format style, resolving every locale including those that write a
  unit without a number at some magnitudes
- `MeasurementKitLocation`: datum-parameterized `Bearing`, great-circle geodesy, and Core Location
  interop whose optionals encode the negative sentinels for an unavailable speed or course
- `MeasurementKitUI`: `MeasurementField`, `NumericField`, and `Binding` projections to `Double` and
  `Int`. A field takes its own text as the source of truth for as long as it holds focus and reads
  the value again the moment focus leaves, so a binding whose write is echoed back asynchronously —
  `@Default`, `@AppStorage`, anything backed by a store — cannot rewrite what is being typed with
  the keystroke before last
- `MeasurementKitDefaults`: canonical-unit persistence, and a dependency-free `RawRepresentable`
  representation in the core for `@AppStorage`
