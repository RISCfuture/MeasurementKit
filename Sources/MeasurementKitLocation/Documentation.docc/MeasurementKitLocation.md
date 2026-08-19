# ``MeasurementKitLocation``

@Metadata {
    @DisplayName("MeasurementKitLocation")
}

Bearings that know which north they were measured from, great-circle geodesy,
and Core Location readings as measurements.

## Overview

MeasurementKitLocation is the navigation half of MeasurementKit. It builds three
things on the Foundation core: a ``Bearing`` whose datum is part of its type, a
``Coordinate`` and ``GreatCircleSegment`` that answer the questions a moving map
asks, and a set of Core Location extensions that turn `CLLocation`'s bare
`Double`s into measurements — and its negative “no reading” sentinels into
`nil`.

A bearing names the north it is measured from in its own type, so a true bearing
and a magnetic bearing cannot be added, compared, or passed for one another:

```swift
let published = TrueBearing(degrees: 10).toMagnetic(variation: .east(16))  // 354°M
let turn = TrueBearing(degrees: 350).shortestTurn(to: .init(degrees: 10))  // +20°
```

Coordinates measure and walk great circles, and a segment answers the deviation
questions behind a course deviation indicator:

```swift
let route = GreatCircleSegment(
  from: .init(latitude: 37.62, longitude: -122.38),
  to: .init(latitude: 40.64, longitude: -73.78)
)
route.length                        // 2 242 NM
route.initialBearing                // 70°T
route.crossTrackDistance(to: fix)   // positive when the fix is right of course
```

Core Location's accessors come back as measurements, and as optionals where Core
Location uses a negative number to mean it has nothing to report:

```swift
guard let groundSpeed = location.groundSpeed,
      let track = location.courseTrue
else { return }  // -1 kn and -1° would have flown the aircraft backwards
```

## Topics

### Bearings

- <doc:BearingDatums>
- ``Bearing``
- ``TrueBearing``
- ``MagneticBearing``
- ``RelativeBearing``
- ``MagneticVariation``

### Bearing Datums

- ``BearingDatum``
- ``True``
- ``Magnetic``

### Geodesy

- ``Coordinate``
- ``GreatCircleSegment``
- ``Earth``

### Navigation

- ``WindTriangle``
