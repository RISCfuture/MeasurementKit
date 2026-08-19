import Foundation
import Numerics
import Testing

@testable import MeasurementKit

@Suite("Accumulation Tests")
struct AccumulationTests {

  private let legs = [
    Measurement(value: 100, unit: UnitLength.nauticalMiles),
    Measurement(value: 50, unit: UnitLength.nauticalMiles),
    Measurement(value: 25, unit: UnitLength.nauticalMiles)
  ]

  /// The trap the accumulation API exists to avoid. Foundation keeps the left operand's unit only
  /// when both units are identical, so a total seeded with a base-unit zero drifts into metres on
  /// the first addition.
  @Test("Foundation's addition drifts to the base unit when the units differ")
  func foundationAdditionDrifts() {
    let mixed =
      Measurement(value: 1, unit: UnitLength.feet) + Measurement(value: 1, unit: UnitLength.meters)

    #expect(mixed.unit == .meters)
    #expect(mixed.value.isApproximatelyEqual(to: 1.3048, absoluteTolerance: 1e-9))
  }

  @Test("Totalling a sequence keeps the unit it was asked for")
  func sumStaysInItsUnit() {
    let total = legs.sum(in: .nauticalMiles)

    #expect(total.value == 175)
    #expect(total.unit == .nauticalMiles)
  }

  @Test("Totalling converts every element rather than assuming they agree")
  func sumConvertsElements() {
    let mixed = [
      Measurement(value: 1, unit: UnitLength.nauticalMiles),
      Measurement(value: 1852, unit: UnitLength.meters)
    ]

    #expect(
      mixed.sum(in: .nauticalMiles).value.isApproximatelyEqual(to: 2, absoluteTolerance: 1e-9)
    )
  }

  @Test("Totalling an empty sequence is zero in the requested unit")
  func emptySumIsZero() {
    let total = [Measurement<UnitLength>]().sum(in: .feet)

    #expect(total.value == 0)
    #expect(total.unit == .feet)
  }

  @Test("Adding keeps the receiver's unit where Foundation's operator would not")
  func addingKeepsTheReceiversUnit() {
    let total = Measurement(value: 1, unit: UnitLength.feet)
      .adding(.init(value: 1, unit: .meters))

    #expect(total.unit == .feet)
    #expect(total.value.isApproximatelyEqual(to: 4.2808398950131235, absoluteTolerance: 1e-9))
  }

  @Test("Subtracting keeps the receiver's unit")
  func subtractingKeepsTheReceiversUnit() {
    let remaining = Measurement(value: 100, unit: UnitLength.nauticalMiles)
      .subtracting(.init(value: 1852, unit: .meters))

    #expect(remaining.unit == .nauticalMiles)
    #expect(remaining.value.isApproximatelyEqual(to: 99, absoluteTolerance: 1e-9))
  }

  @Test("A zero seeded in a unit stays in it")
  func seededZeroKeepsItsUnit() {
    #expect(Measurement<UnitLength>.zero(in: .feet).unit == .feet)
    #expect(Measurement<UnitLength>.zero.unit == UnitLength.baseUnit())
  }

  @Test("A base-unit zero still compares correctly against any unit")
  func zeroComparesAcrossUnits() {
    #expect(Measurement(value: -500, unit: UnitSpeed.feetPerMinute) < .zero)
    #expect(Measurement(value: 500, unit: UnitSpeed.feetPerMinute) > .zero)
  }

  @Test("Magnitude keeps the unit and drops the sign")
  func magnitudeKeepsTheUnit() {
    let descent = Measurement(value: -700, unit: UnitSpeed.feetPerMinute)

    #expect(descent.magnitude.value == 700)
    #expect(descent.magnitude.unit == .feetPerMinute)
    #expect((-descent).value == 700)
  }
}
