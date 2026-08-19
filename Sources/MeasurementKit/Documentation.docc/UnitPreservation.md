# Unit Preservation

Why an operator answers in the unit it does, and why this package adds no `+`.

## Overview

Every operator MeasurementKit adds reports its result in a unit derived from the **left** operand,
never in the dimension's base unit. That is a correctness requirement rather than a convenience: a
cockpit app formats with `usage: .asProvided`, which prints whatever unit the measurement happens
to carry, so an operator that quietly answered in metres would put metres on the screen of an
aircraft flown in feet.

## Coherent families

Length, duration and speed units come in families that measure each other exactly. One nautical
mile is what one knot covers in one hour; one foot is what one foot per minute covers in one
minute. A relation that crosses dimensions answers inside the left operand's family.

| Family | Length | Duration | Speed |
| --- | --- | --- | --- |
| SI | metres | seconds | metres per second |
| Nautical | nautical miles | hours | knots |
| Statute | miles | hours | miles per hour |
| Metric road | kilometres | hours | kilometres per hour |
| Vertical | feet | minutes | feet per minute |

Staying inside a family is what keeps the arithmetic exact. Foundation's knot carries the truncated
coefficient 0.514444, so routing a product through metres arrives at 239.99979 nautical miles where
the answer is 240:

```swift
Measurement(value: 120, unit: UnitSpeed.knots)
  * Measurement(value: 2, unit: UnitDuration.hours)   // exactly 240 NM
```

A unit that names no family — a centimetre, a fathom — resolves to SI, and the relation converts
into it rather than assuming the unit it was handed belongs to a family it does not.

A bare duration carries no family of its own, so where a duration is on the left the other operand
governs. `time * speed` and `speed * time` agree in unit as well as in value.

## Derived dimensions name their own units

A density, a flow rate and an angular velocity each know the two units they were built from, so a
relation that consumes one answers in those units rather than in a base unit:

```swift
let flow = Measurement(value: 20, unit: UnitVolumetricFlowRate.gallonsPerHour)
flow * Measurement(value: 3, unit: UnitDuration.hours)     // 60 gal
flow * Measurement(value: 6.7, unit: UnitDensity.poundsPerGallon)  // 134 lb/hr
```

## There is no `+`

MeasurementKit deliberately ships no `+`, `-`, `+=` or `-=` for `Measurement`. An overload of an
operator Foundation already defines is ambiguous at every use site in another module, and inside a
function body it silently resolves to Foundation's instead — so a unit-preserving `+` cannot be
shipped at all, only *appear* to have been.

What Foundation's `+` does is worth knowing, because it is the reason the accumulation API exists:
it keeps the left operand's unit only when both units are **identical**, and falls back to the base
unit otherwise.

```swift
Measurement(value: 1, unit: UnitLength.feet)
  + Measurement(value: 1, unit: UnitLength.meters)        // 1.3048 m, not 4.28 ft
```

So a running total seeded with ``Foundation/Measurement/zero`` drifts into metres on its first
addition. Seed with ``Foundation/Measurement/zero(in:)``, add with
``Foundation/Measurement/adding(_:)``, or total a sequence with ``Swift/Sequence/sum(in:)`` — each
of which keeps the unit you asked for.

## Ratios, and the one dimension that has none

Dividing two measurements of the same dimension answers how many of one fit in the other. That is
only meaningful on a scale whose zero is a genuine absence of the quantity, which is what
``ProportionalDimension`` marks.

Temperature is the exception the protocol exists to exclude. Degrees Celsius and degrees Fahrenheit
are interval scales with displaced zeros, so dividing two readings divides their kelvin values and
answers a number that means nothing. `t1 / t2` therefore does not compile for
`Measurement<UnitTemperature>`, and a difference between two temperatures gets its own dimension,
``UnitTemperatureDifference``, which does divide and does add.

```swift
let standard = Measurement(value: 15, unit: UnitTemperature.celsius)
let deviation = Measurement(value: 10, unit: UnitTemperatureDifference.celsius)
standard.deviated(by: deviation)                          // 25 °C
```
