import Foundation
import Numerics
import Testing

@testable import MeasurementKit

@Suite("Rounding Tests")
struct RoundingTests {

  private let hundredFeet = Measurement(value: 100, unit: UnitLength.feet)

  @Test("Rounding to a multiple keeps the receiver's unit")
  func roundingKeepsTheUnit() {
    let rounded = Measurement(value: 4_520, unit: UnitLength.feet).rounded(toMultipleOf: hundredFeet)

    #expect(rounded.value == 4_500)
    #expect(rounded.unit == .feet)
  }

  @Test("Rounding honours the rule it is given")
  func roundingHonoursTheRule() {
    let correction = Measurement(value: 4_520, unit: UnitLength.feet)

    #expect(correction.rounded(toMultipleOf: hundredFeet, rule: .up).value == 4_600)
    #expect(correction.rounded(toMultipleOf: hundredFeet, rule: .down).value == 4_500)
  }

  @Test("Rounding converts a step given in another unit")
  func roundingConvertsTheStep() {
    let step = Measurement(value: 30.48, unit: UnitLength.meters)
    let rounded = Measurement(value: 4_520, unit: UnitLength.feet).rounded(toMultipleOf: step)

    #expect(rounded.unit == .feet)
    #expect(rounded.value.isApproximatelyEqual(to: 4_500, absoluteTolerance: 1e-6))
  }

  @Test("Clamping pins to the nearer bound and keeps the receiver's unit")
  func clampingPins() {
    let coldest = Measurement(value: -50, unit: UnitTemperature.celsius),
      hottest = Measurement(value: 50, unit: UnitTemperature.celsius)
    let range = coldest...hottest

    #expect(Measurement(value: -80, unit: UnitTemperature.celsius).clamped(to: range).value == -50)
    #expect(Measurement(value: 80, unit: UnitTemperature.celsius).clamped(to: range).value == 50)
    #expect(Measurement(value: 20, unit: UnitTemperature.celsius).clamped(to: range).value == 20)
  }

  @Test("Clamping compares across units")
  func clampingComparesAcrossUnits() {
    let lowest = Measurement(value: 0, unit: UnitLength.feet),
      highest = Measurement(value: 1_000, unit: UnitLength.feet)
    let range = lowest...highest
    let tooHigh = Measurement(value: 1, unit: UnitLength.kilometers)

    #expect(tooHigh.clamped(to: range).unit == .kilometers)
    #expect(tooHigh.clamped(to: range).converted(to: .feet).value
      .isApproximatelyEqual(to: 1_000, absoluteTolerance: 1e-6))
  }
}
