# Bearings and Their Datums

Why the north a bearing is measured from belongs in its type.

## Overview

A bearing on its own is half a number. `010` is a runway heading, a course to
steer, or an obstruction bearing — but until you know whether it was measured
from true north or magnetic north, you cannot compare it to another bearing, and
at O22, where the variation is 16° east, acting on the wrong one puts you 16°
off.

The confusion is not hypothetical: nav data publishes runway bearings in true,
the chart prints them in magnetic, the compass reads magnetic, and the GPS
reports course over the ground in true. Any real navigation calculation moves
between all four.

### The datum as a type parameter

MeasurementKitLocation makes the datum a type parameter:

```swift
public struct Bearing<Datum: BearingDatum> { ... }
public typealias TrueBearing = Bearing<True>
public typealias MagneticBearing = Bearing<Magnetic>
```

``True`` and ``Magnetic`` are caseless enums — types with no values, existing
only to be named. The consequences are all at compile time:

- A `TrueBearing` cannot be passed where a `MagneticBearing` is expected, or the
  reverse. Mixing the two is a build error rather than a plausible-looking
  number that nothing downstream can tell apart from a correct one.
- Subtracting bearings requires both sides to share a datum, so the difference
  is meaningful.
- ``Bearing/toTrue(variation:)-(MagneticVariation)`` is declared in an extension
  constrained to `Datum == Magnetic`, and
  ``Bearing/toMagnetic(variation:)-(MagneticVariation)`` to `Datum == True`.
  Converting a bearing to the datum it is already in is not an operation that
  fails at runtime; it is an operation that does not exist.

``RelativeBearing`` is a separate type rather than a third datum, because it is
a different kind of quantity: a turn, not a direction. It may be negative, it
has a magnitude, and it has no reciprocal — the opposite of a turn is its
negation. It is what ``Bearing`` subtraction answers and what ``Bearing``
addition takes, so the two types compose without either one needing a runtime
check.

### What the datum requires

``BearingDatum`` requires `Sendable` and an abbreviation, and nothing else.
`Codable` is the requirement it conspicuously does not have, and cannot: a
caseless enum has no values, so the compiler cannot synthesize a `Decodable`
conformance that would have to produce one.

``Bearing`` therefore writes its own `Codable` conformance and encodes the
abbreviation as data:

```json
{ "degrees": 90, "datum": "T" }
```

Decoding checks it. A synthesized conformance would encode the angle alone, and
a `Bearing<True>` would then decode without complaint from data a
`Bearing<Magnetic>` wrote — the datum confusion the type parameter exists to
prevent, coming back in through the file format. Feeding a bearing the wrong
datum's data throws `DecodingError.dataCorrupted` instead.

### Variation is a parameter, not a model

``MagneticVariation`` is a value the caller supplies. This module ships no
magnetic model: a World Magnetic Model implementation is a large table with an
expiry date on it, and where the variation comes from — a chart, an airport
record, `CLHeading`, or a model — is the application's business. The sign
convention is the chart's, positive east, and ``MagneticVariation/east(_:)`` and
``MagneticVariation/west(_:)`` exist so it never has to be remembered.
