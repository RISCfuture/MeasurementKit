import Foundation
import MeasurementKit
import Numerics
import Testing

@testable import MeasurementKitLocation

@Suite("Great Circle Segment Tests")
struct GreatCircleSegmentTests {

  /// A degree of longitude on the equator, the course every test in this suite flies.
  private static let course = GreatCircleSegment(
    from: .zero,
    to: .init(latitude: 0, longitude: 1)
  )

  @Test("A segment reports its own length and departure bearing")
  func lengthAndBearing() {
    #expect(
      Self.course.length.converted(to: .nauticalMiles).value
        .isApproximatelyEqual(to: 60, absoluteTolerance: 0.1)
    )
    #expect(
      Self.course.initialBearing.degrees.isApproximatelyEqual(to: 90, absoluteTolerance: 1e-6)
    )
  }

  /// Flying east along the equator, a position to the south is off the right wing. The sign is the
  /// whole point of the method: a display that gets it backwards steers the pilot further off
  /// course.
  @Test("Cross-track distance is positive to the right of course")
  func crossTrackSignConvention() {
    let toTheRight = Self.course.crossTrackDistance(to: .init(latitude: -0.1, longitude: 0.5))
    let toTheLeft = Self.course.crossTrackDistance(to: .init(latitude: 0.1, longitude: 0.5))

    #expect(toTheRight.value > 0)
    #expect(toTheLeft.value < 0)
    #expect(
      toTheRight.converted(to: .nauticalMiles).value
        .isApproximatelyEqual(to: 6, absoluteTolerance: 0.05)
    )
    #expect(
      toTheLeft.converted(to: .nauticalMiles).value
        .isApproximatelyEqual(to: -6, absoluteTolerance: 0.05)
    )
  }

  @Test("A position on the course line has no cross-track distance")
  func onCourse() {
    let deviation = Self.course.crossTrackDistance(to: .init(latitude: 0, longitude: 0.5))
    #expect(
      deviation.converted(to: .meters).value.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-6)
    )
  }

  @Test("Along-track distance measures progress down the course, and goes negative behind it")
  func alongTrackDistance() {
    let halfway = Self.course.alongTrackDistance(to: .init(latitude: -0.1, longitude: 0.5))
    #expect(
      halfway.converted(to: .nauticalMiles).value
        .isApproximatelyEqual(to: 30, absoluteTolerance: 0.05)
    )

    let behind = Self.course.alongTrackDistance(to: .init(latitude: 0, longitude: -0.5))
    #expect(
      behind.converted(to: .nauticalMiles).value
        .isApproximatelyEqual(to: -30, absoluteTolerance: 0.05)
    )
  }

  @Test("The closest point is abeam the position")
  func closestPoint() {
    let abeam = Self.course.closestPoint(to: .init(latitude: -0.1, longitude: 0.5))

    #expect(abeam.latitude.degrees.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-4))
    #expect(abeam.longitude.degrees.isApproximatelyEqual(to: 0.5, absoluteTolerance: 1e-4))
  }

  @Test("The closest point is held to the ends of the segment")
  func closestPointClampsToSegment() {
    let behind = Self.course.closestPoint(to: .init(latitude: 0, longitude: -0.5))
    #expect(behind.longitude.degrees.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-6))

    let beyond = Self.course.closestPoint(to: .init(latitude: 0, longitude: 1.5))
    #expect(beyond.longitude.degrees.isApproximatelyEqual(to: 1, absoluteTolerance: 1e-4))
  }
}
