# ``MeasurementKitUI``

@Metadata {
    @DisplayName("MeasurementKitUI")
}

SwiftUI controls for typing a measurement, with the unit set where the locale
puts it and the keypad the value actually needs.

## Overview

MeasurementKitUI is the entry half of MeasurementKit: the text fields an app
puts in front of somebody who has to type a runway length, an altimeter
setting, or a temperature, and read it back as a `Measurement` rather than as a
number that has to be remembered to mean feet.

A field edits the magnitude alone and names the unit it edits in:

```swift
@State private var elevation: Measurement<UnitLength>?

MeasurementField(
  "Feet MSL",
  value: $elevation,
  in: .feet,
  format: .measurement(width: .abbreviated, usage: .asProvided)
)
```

The unit is drawn beside the digits where that locale writes it — ahead of the
number in Sinhala, run onto it without a space in Nepali, inflected in
Faroese — and moves as the value being typed changes. The keypad follows from
the format style: a style that rounds to whole feet raises a pad with no
decimal separator on it, and one that keeps hundredths of an inch of mercury
raises a pad that has one.

The bound value is optional, and an empty field reads as `nil` rather than
zero. Where a caller drives a calculation from what was typed, that is the
difference between “nothing entered yet” and a confident answer computed from a
value nobody gave. A non-optional binding is supported too, and simply declines
to write when the field is emptied.

Where a value has no dimension, ``NumericField`` gives it the same entry
behavior without a unit beside it.

A control that has no measurement to bind to — a `Slider`, a `Stepper`, a
`Picker` over a range — gets one through `Binding`'s `scalar(in:)` and
`roundedScalar(in:)`, which set the dimension aside on the way in and put it
straight back on the way out:

```swift
Stepper(
  "Runway length",
  value: $length.roundedScalar(in: .feet),
  in: 1_000...15_000,
  step: 100
)
```

## Topics

### Entry Fields

- ``MeasurementField``
- ``NumericField``
- ``NumericKeypad``
