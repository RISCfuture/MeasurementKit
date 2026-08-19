# ``MeasurementKit``

@Metadata {
    @DisplayName("MeasurementKit")
}

Arithmetic, units and dimensions that Foundation's `Measurement` leaves out, for aviation and
general physical work.

## Overview

Foundation gives a measurement addition, subtraction, scaling and comparison, and a format style
that localizes it properly. What it does not give is the arithmetic that crosses dimensions — a
distance over a time is a speed — nor the dimensions an aviation or engineering app reaches for
first: a force, a density, a fuel flow, a climb gradient.

MeasurementKit adds those, and it adds them so that the answer arrives in a unit you would have
written yourself:

```swift
let groundSpeed = Measurement(value: 120, unit: UnitSpeed.knots)
let leg = Measurement(value: 2, unit: UnitDuration.hours)
groundSpeed * leg          // 240 NM, exactly

let fuel = Measurement(value: 100, unit: UnitVolume.gallons)
let density = Measurement(value: 6.7, unit: UnitDensity.poundsPerGallon)
fuel * density             // 670 lb — the density names the unit
```

Nothing here conforms a Foundation type to a protocol this package owns, and nothing here
overloads an operator Foundation already defines. Both are deliberate; see
<doc:UnitPreservation> for why the second is not merely a style choice.

## Topics

### Essentials

- <doc:UnitPreservation>
- <doc:Arithmetic>

### Dimensions

- ``UnitForce``
- ``UnitSlope``
- ``UnitDensity``
- ``UnitAngularVelocity``
- ``UnitVolumetricFlowRate``
- ``UnitMassFlowRate``
- ``UnitTemperatureDifference``

### Extending the Unit System

- ``ProportionalDimension``
- ``DerivedDimension``
- ``derivedUnit(_:per:symbol:)``
- ``derivedCoefficient(_:per:)``

### Formatting

- ``Foundation/Measurement/affixes(format:in:)``
