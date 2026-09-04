import Foundation
import Numerics
import Testing

@testable import MeasurementKit

@Suite
struct `Unit Preservation Tests` {

  // MARK: - Coherent families

  private static let families = [
    Family(name: "SI", length: .meters, duration: .seconds, speed: .metersPerSecond),
    Family(name: "nautical", length: .nauticalMiles, duration: .hours, speed: .knots),
    Family(name: "statute", length: .miles, duration: .hours, speed: .milesPerHour),
    Family(name: "metric road", length: .kilometers, duration: .hours, speed: .kilometersPerHour),
    Family(name: "vertical", length: .feet, duration: .minutes, speed: .feetPerMinute)
  ]

  /// The invariant the family table exists to hold. Foundation's knot is the truncated 0.514444, so
  /// a product routed through metres arrives at 239.99979 NM instead of 240; staying inside the
  /// family keeps it exact.
  @Test
  func `One speed held for one duration covers exactly one length, in every family`() {
    for family in Self.families {
      let covered =
        Measurement(value: 1, unit: family.speed) * Measurement(value: 1, unit: family.duration)

      #expect(covered.value == 1, "\(family.name) was not exact")
      #expect(covered.unit == family.length, "\(family.name) answered in the wrong unit")
    }
  }

  @Test
  func `A speed divided out of a length returns that family's speed unit`() {
    for family in Self.families {
      let speed =
        Measurement(value: 1, unit: family.length) / Measurement(value: 1, unit: family.duration)

      #expect(speed.value == 1, "\(family.name) was not exact")
      #expect(speed.unit == family.speed, "\(family.name) answered in the wrong unit")
    }
  }

  @Test
  func `120 knots for two hours is exactly 240 nautical miles`() {
    let covered =
      Measurement(value: 120, unit: UnitSpeed.knots)
      * Measurement(value: 2, unit: UnitDuration.hours)

    #expect(covered.value == 240)
    #expect(covered.unit == .nauticalMiles)
  }

  // MARK: - Units naming no family

  /// A centimetre belongs to no coherent family, so the relation converts into SI rather than
  /// assuming the unit it was handed is part of one.
  @Test
  func `A unit naming no family converts to SI rather than assuming one`() {
    let speed =
      Measurement(value: 5, unit: UnitLength.centimeters)
      / Measurement(value: 2, unit: UnitDuration.seconds)

    #expect(speed.unit == .metersPerSecond)
    #expect(speed.value.isApproximatelyEqual(to: 0.025, absoluteTolerance: 1e-12))
  }

  /// A duration carries no family of its own, so the other operand governs and the two orders agree
  /// in unit as well as in value.
  @Test
  func `Multiplication by a duration commutes in unit as well as value`() {
    let speed = Measurement(value: 120, unit: UnitSpeed.knots)
    let time = Measurement(value: 30, unit: UnitDuration.minutes)

    #expect((speed * time).unit == (time * speed).unit)
    #expect((speed * time).value == (time * speed).value)
    #expect((speed * time).unit == .nauticalMiles)
  }

  // MARK: - Derived dimensions name their own result units

  /// The relation that would silently answer in kilograms if the density stopped carrying its
  /// component units.
  @Test
  func `A volume weighed by a density answers in the density's own mass unit`() {
    let weight =
      Measurement(value: 100, unit: UnitVolume.gallons)
      * Measurement(value: 6.7, unit: UnitDensity.poundsPerGallon)

    #expect(weight.value == 670)
    #expect(weight.unit == .pounds)
  }

  @Test
  func `A mass divided by a density answers in the density's own volume unit`() {
    let volume =
      Measurement(value: 670, unit: UnitMass.pounds)
      / Measurement(value: 6.7, unit: UnitDensity.poundsPerGallon)

    #expect(volume.value == 100)
    #expect(volume.unit == .gallons)
  }

  @Test
  func `A flow rate run for a duration answers in the flow rate's own volume unit`() {
    let burned =
      Measurement(value: 20, unit: UnitVolumetricFlowRate.gallonsPerHour)
      * Measurement(value: 3, unit: UnitDuration.hours)

    #expect(burned.value == 60)
    #expect(burned.unit == .gallons)
  }

  @Test
  func `A volume flow carrying a density answers in that density's mass unit per hour`() {
    let flow =
      Measurement(value: 20, unit: UnitVolumetricFlowRate.gallonsPerHour)
      * Measurement(value: 6.7, unit: UnitDensity.poundsPerGallon)

    #expect(flow.value == 134)
    #expect(flow.unit.numeratorUnit == .pounds)
    #expect(flow.unit.denominatorUnit == .hours)
  }

  @Test
  func `An angle swept over a time answers in both operands' own units`() {
    let rate =
      Measurement(value: 90, unit: UnitAngle.degrees)
      / Measurement(value: 30, unit: UnitDuration.seconds)

    #expect(rate.value == 3)
    #expect(rate.unit.numeratorUnit == .degrees)
    #expect(rate.unit.denominatorUnit == .seconds)
  }

  // MARK: - Companion units

  /// Standard gravity is exactly 9.80665 m/s² and pounds-force is derived from Foundation's own
  /// pound, so a mass in pounds weighs the same number of pounds-force. Foundation's own
  /// `UnitAcceleration.gravity` rounds to 9.81 and would break this by a part in three thousand.
  @Test
  func `A mass in pounds under standard gravity weighs that many pounds-force`() {
    let weight = Measurement(value: 3550, unit: UnitMass.pounds) * Measurement.standardGravity

    #expect(weight.value.isApproximatelyEqual(to: 3550, absoluteTolerance: 1e-9))
    #expect(weight.unit == .poundsForce)
  }

  @Test
  func `A rectangle in feet has its area in square feet`() {
    let area =
      Measurement(value: 10, unit: UnitLength.feet) * Measurement(value: 3, unit: UnitLength.feet)

    #expect(area.value == 30)
    #expect(area.unit == .squareFeet)
  }

  /// Every Foundation acceleration is stated per second squared, so the acceleration names the time
  /// unit rather than the speed's family — an acceleration measured in hours would read strangely.
  @Test
  func `A speed divided by an acceleration answers in seconds`() {
    let time =
      Measurement(value: 30, unit: UnitSpeed.knots)
      / Measurement(value: 3, unit: UnitAcceleration.knotsPerSecond)

    #expect(time.value.isApproximatelyEqual(to: 10, absoluteTolerance: 1e-9))
    #expect(time.unit == .seconds)
  }

  /// A set of units that measure each other coherently, so that one speed held for one duration
  /// covers exactly one length.
  private struct Family {
    let name: String
    let length: UnitLength
    let duration: UnitDuration
    let speed: UnitSpeed
  }
}
