import Foundation
import Numerics
import Testing

@testable import MeasurementKit

@Suite
struct `Rounding Tests` {

  private let hundredFeet = Measurement(value: 100, unit: UnitLength.feet)

  @Test
  func `Rounding to a multiple keeps the receiver's unit`() {
    let rounded = Measurement(value: 4_520, unit: UnitLength.feet).rounded(
      toMultipleOf: hundredFeet
    )

    #expect(rounded.value == 4_500)
    #expect(rounded.unit == .feet)
  }

  @Test
  func `Rounding honours the rule it is given`() {
    let correction = Measurement(value: 4_520, unit: UnitLength.feet)

    #expect(correction.rounded(toMultipleOf: hundredFeet, rule: .up).value == 4_600)
    #expect(correction.rounded(toMultipleOf: hundredFeet, rule: .down).value == 4_500)
  }

  @Test
  func `Rounding converts a step given in another unit`() {
    let step = Measurement(value: 30.48, unit: UnitLength.meters)
    let rounded = Measurement(value: 4_520, unit: UnitLength.feet).rounded(toMultipleOf: step)

    #expect(rounded.unit == .feet)
    #expect(rounded.value.isApproximatelyEqual(to: 4_500, absoluteTolerance: 1e-6))
  }

  @Test
  func `Clamping pins to the nearer bound and keeps the receiver's unit`() {
    let coldest = Measurement(value: -50, unit: UnitTemperature.celsius),
      hottest = Measurement(value: 50, unit: UnitTemperature.celsius)
    let range = coldest...hottest

    #expect(Measurement(value: -80, unit: UnitTemperature.celsius).clamped(to: range).value == -50)
    #expect(Measurement(value: 80, unit: UnitTemperature.celsius).clamped(to: range).value == 50)
    #expect(Measurement(value: 20, unit: UnitTemperature.celsius).clamped(to: range).value == 20)
  }

  @Test
  func `Clamping compares across units`() {
    let lowest = Measurement(value: 0, unit: UnitLength.feet),
      highest = Measurement(value: 1_000, unit: UnitLength.feet)
    let range = lowest...highest
    let tooHigh = Measurement(value: 1, unit: UnitLength.kilometers)

    #expect(tooHigh.clamped(to: range).unit == .kilometers)
    let clampedInFeet = tooHigh.clamped(to: range).converted(to: .feet).value

    #expect(clampedInFeet.isApproximatelyEqual(to: 1_000, absoluteTolerance: 1e-6))
  }
}
