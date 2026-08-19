import Foundation
import Numerics
import Testing

@testable import MeasurementKit

@Suite("Angle Tests")
struct AngleTests {

  private func degrees(_ value: Double) -> Measurement<UnitAngle> {
    .init(value: value, unit: .degrees)
  }

  // MARK: - Normalization

  @Test(
    "Normalizing brings an angle into compass range",
    arguments: [(370.0, 10.0), (-10.0, 350.0), (0.0, 0.0), (360.0, 0.0), (-370.0, 350.0)]
  )
  func normalizes(input: Double, expected: Double) {
    #expect(
      degrees(input).normalized.degrees.isApproximatelyEqual(
        to: expected,
        absoluteTolerance: 1e-9
      )
    )
  }

  @Test(
    "Signed normalizing brings an angle into offset range",
    arguments: [(190.0, -170.0), (180.0, 180.0), (-190.0, 170.0), (0.0, 0.0), (350.0, -10.0)]
  )
  func signedNormalizes(input: Double, expected: Double) {
    #expect(
      degrees(input).signedNormalized.degrees.isApproximatelyEqual(
        to: expected,
        absoluteTolerance: 1e-9
      )
    )
  }

  /// A negative angle has to be folded twice to arrive in range. Folding once answers −20° here,
  /// which reads as a course rather than failing.
  @Test(
    "The reciprocal of a negative angle is still a compass course",
    arguments: [(-200.0, 340.0), (200.0, 20.0), (0.0, 180.0), (180.0, 0.0), (90.0, 270.0)]
  )
  func reciprocalHandlesNegatives(input: Double, expected: Double) {
    #expect(
      degrees(input).reciprocal.degrees.isApproximatelyEqual(
        to: expected,
        absoluteTolerance: 1e-9
      )
    )
  }

  @Test("Normalizing preserves the unit it was given")
  func normalizingKeepsTheUnit() {
    let angle = Measurement(value: 7, unit: UnitAngle.radians)

    #expect(angle.normalized.unit == .radians)
    #expect(angle.reciprocal.unit == .radians)
  }

  @Test("Rotating turns and folds back into compass range")
  func rotates() {
    #expect(
      degrees(350).rotated(by: degrees(20)).degrees
        .isApproximatelyEqual(to: 10, absoluteTolerance: 1e-9)
    )
    #expect(
      degrees(10).rotated(by: degrees(-20)).degrees
        .isApproximatelyEqual(to: 350, absoluteTolerance: 1e-9)
    )
  }

  // MARK: - Trigonometry

  @Test("The trigonometric functions read an angle rather than a bare number")
  func trigonometryTakesAnAngle() {
    #expect(sin(degrees(30)).isApproximatelyEqual(to: 0.5, absoluteTolerance: 1e-12))
    #expect(cos(degrees(60)).isApproximatelyEqual(to: 0.5, absoluteTolerance: 1e-12))
    #expect(tan(degrees(45)).isApproximatelyEqual(to: 1, absoluteTolerance: 1e-12))
  }

  @Test("The inverse functions answer with an angle")
  func inverseTrigonometryAnswersAnAngle() {
    let fromSine = Measurement<UnitAngle>.arcsin(0.5).degrees,
      fromTangent = Measurement<UnitAngle>.arctan(y: 1, x: 1).degrees

    #expect(fromSine.isApproximatelyEqual(to: 30, absoluteTolerance: 1e-9))
    #expect(fromTangent.isApproximatelyEqual(to: 45, absoluteTolerance: 1e-9))
  }

  /// The measurement overloads must not shadow the ones that take a bare number.
  @Test("Foundation's own trigonometric functions still resolve")
  func foundationTrigonometrySurvives() {
    #expect(sin(0.0) == 0)
    #expect(cos(0.0) == 1)
  }
}
