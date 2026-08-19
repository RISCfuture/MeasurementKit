import Foundation
import SwiftUI

extension Binding {
  /**
   This measurement binding as a binding to its magnitude in `unit`.

   A control that edits a number rather than a measurement — a `Slider`, a `Stepper`, a `Picker`
   over a range — needs a number to bind to, and this is the one place the dimension has to be set
   aside. It is set aside on the way in and put straight back on the way out, in the same unit, so
   the value's own storage unit is whatever the binding already had.

   - Parameter unit: the unit the magnitude is read and written in.
   - Returns: a binding to the magnitude.
   */
  public func scalar<UnitType: Dimension>(in unit: UnitType) -> Binding<Double>
  where Value == Measurement<UnitType> {
    .init(
      get: { wrappedValue.converted(to: unit).value },
      set: { wrappedValue = .init(value: $0, unit: unit) }
    )
  }

  /**
   This measurement binding as a binding to its magnitude in `unit`, rounded to a whole number.

   The magnitude is rounded rather than truncated: a `Stepper` over feet that turns 2.6 into 2 has
   lost a foot the pilot never gave away.

   - Parameter unit: the unit the magnitude is read and written in.
   - Returns: a binding to the whole-number magnitude.
   */
  public func roundedScalar<UnitType: Dimension>(in unit: UnitType) -> Binding<Int>
  where Value == Measurement<UnitType> {
    .init(
      get: { Int(wrappedValue.converted(to: unit).value.rounded()) },
      set: { wrappedValue = .init(value: Double($0), unit: unit) }
    )
  }

  /**
   This optional measurement binding as a binding to its magnitude in `unit`.

   Absence travels through unchanged in both directions: no value has no magnitude, and clearing
   the magnitude clears the value.

   - Parameter unit: the unit the magnitude is read and written in.
   - Returns: a binding to the magnitude, `nil` where there is no value.
   */
  public func scalar<UnitType: Dimension>(in unit: UnitType) -> Binding<Double?>
  where Value == Measurement<UnitType>? {
    .init(
      get: { wrappedValue?.converted(to: unit).value },
      set: { wrappedValue = $0.map { .init(value: $0, unit: unit) } }
    )
  }

  /**
   This optional measurement binding as a binding to its magnitude in `unit`, rounded to a whole
   number.

   Absence travels through unchanged in both directions, and a magnitude that is there is rounded
   rather than truncated.

   - Parameter unit: the unit the magnitude is read and written in.
   - Returns: a binding to the whole-number magnitude, `nil` where there is no value.
   */
  public func roundedScalar<UnitType: Dimension>(in unit: UnitType) -> Binding<Int?>
  where Value == Measurement<UnitType>? {
    .init(
      get: { wrappedValue.map { Int($0.converted(to: unit).value.rounded()) } },
      set: { wrappedValue = $0.map { .init(value: Double($0), unit: unit) } }
    )
  }
}
