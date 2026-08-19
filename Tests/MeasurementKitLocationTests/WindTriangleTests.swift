import Foundation
import Numerics
import Testing

@testable import MeasurementKitLocation

@Suite("Wind Triangle Tests")
struct WindTriangleTests {

  private static let trueAirspeed = Measurement(value: 100, unit: UnitSpeed.knots)

  private static func triangle(windFrom: Double, windSpeed: Double) -> WindTriangle {
    .init(
      heading: .init(degrees: 0),
      trueAirspeed: trueAirspeed,
      windFrom: .init(degrees: windFrom),
      windSpeed: .init(value: windSpeed, unit: .knots)
    )
  }

  @Test("Calm air makes good the heading and the true airspeed")
  func calm() {
    let triangle = Self.triangle(windFrom: 270, windSpeed: 0)

    #expect(triangle.track.degrees.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-9))
    #expect(triangle.groundSpeed.value.isApproximatelyEqual(to: 100, absoluteTolerance: 1e-9))
  }

  @Test("A headwind subtracts from the ground speed and a tailwind adds to it")
  func alignedWind() {
    let headwind = Self.triangle(windFrom: 0, windSpeed: 20)
    #expect(headwind.groundSpeed.value.isApproximatelyEqual(to: 80, absoluteTolerance: 1e-9))
    #expect(headwind.track.degrees.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-9))

    let tailwind = Self.triangle(windFrom: 180, windSpeed: 20)
    #expect(tailwind.groundSpeed.value.isApproximatelyEqual(to: 120, absoluteTolerance: 1e-9))
    #expect(tailwind.track.degrees.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-9))
  }

  @Test("A wind from the right drifts the track to the left of the heading")
  func crosswindDrift() {
    let triangle = Self.triangle(windFrom: 90, windSpeed: 20)

    #expect(triangle.track.degrees.isApproximatelyEqual(to: 348.6901, absoluteTolerance: 1e-4))
    #expect(triangle.groundSpeed.value.isApproximatelyEqual(to: 101.9804, absoluteTolerance: 1e-4))
    #expect(triangle.driftAngle.degrees.isApproximatelyEqual(to: -11.3099, absoluteTolerance: 1e-4))
  }

  @Test("The wind is converted into the true airspeed's unit")
  func mixedUnits() {
    let triangle = WindTriangle(
      heading: .init(degrees: 0),
      trueAirspeed: Self.trueAirspeed,
      windFrom: .init(degrees: 180),
      windSpeed: .init(value: 37.04, unit: .kilometersPerHour)
    )

    #expect(triangle.groundSpeed.unit == .knots)
    #expect(triangle.groundSpeed.value.isApproximatelyEqual(to: 120, absoluteTolerance: 1e-3))
  }
}
