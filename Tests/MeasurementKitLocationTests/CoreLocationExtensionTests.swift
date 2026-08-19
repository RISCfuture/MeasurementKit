import CoreLocation
import Foundation
import MeasurementKit
import Numerics
import Testing

@testable import MeasurementKitLocation

@Suite("Core Location Extension Tests")
struct CoreLocationExtensionTests {

  private static func location(
    latitude: Double = 37.62,
    longitude: Double = -122.38,
    altitude: Double = 100,
    horizontalAccuracy: Double = 5,
    verticalAccuracy: Double = 5,
    course: Double = 90,
    courseAccuracy: Double = 2,
    speed: Double = 50,
    speedAccuracy: Double = 1
  ) -> CLLocation {
    .init(
      coordinate: .init(latitude: latitude, longitude: longitude),
      altitude: altitude,
      horizontalAccuracy: horizontalAccuracy,
      verticalAccuracy: verticalAccuracy,
      course: course,
      courseAccuracy: courseAccuracy,
      speed: speed,
      speedAccuracy: speedAccuracy,
      timestamp: .init()
    )
  }

  @Test("A fix carries its position and altitude across")
  func positionAndAltitude() {
    let location = Self.location()

    #expect(
      location.geoCoordinate.latitude.degrees
        .isApproximatelyEqual(to: 37.62, absoluteTolerance: 1e-9)
    )
    #expect(
      location.geoCoordinate.longitude.degrees
        .isApproximatelyEqual(to: -122.38, absoluteTolerance: 1e-9)
    )
    #expect(
      location.altitudeMSL.converted(to: .meters).value
        .isApproximatelyEqual(to: 100, absoluteTolerance: 1e-9)
    )
  }

  @Test("Readings a fix has are measurements")
  func availableReadings() throws {
    let location = Self.location()

    #expect(
      try #require(location.groundSpeed).converted(to: .metersPerSecond).value
        .isApproximatelyEqual(to: 50, absoluteTolerance: 1e-9)
    )
    #expect(
      try #require(location.courseTrue).degrees.isApproximatelyEqual(
        to: 90,
        absoluteTolerance: 1e-9
      )
    )
    #expect(
      try #require(location.horizontalAccuracyDistance).converted(to: .meters).value
        .isApproximatelyEqual(to: 5, absoluteTolerance: 1e-9)
    )
    #expect(
      try #require(location.verticalAccuracyDistance).converted(to: .meters).value
        .isApproximatelyEqual(to: 5, absoluteTolerance: 1e-9)
    )
    #expect(
      try #require(location.courseAccuracyAngle).degrees
        .isApproximatelyEqual(to: 2, absoluteTolerance: 1e-9)
    )
    #expect(
      try #require(location.speedAccuracyMeasurement).converted(to: .metersPerSecond).value
        .isApproximatelyEqual(to: 1, absoluteTolerance: 1e-9)
    )
  }

  /// Core Location signals "unavailable" with a negative number rather than an optional. Taken at
  /// face value, a speed of −1 m/s dead-reckons the aircraft backwards and a course of −1° points
  /// a degree west of north.
  @Test("The negative sentinels read as nothing at all")
  func negativeSentinels() {
    let location = Self.location(
      horizontalAccuracy: -1,
      verticalAccuracy: -1,
      course: -1,
      courseAccuracy: -1,
      speed: -1,
      speedAccuracy: -1
    )

    #expect(location.groundSpeed == nil)
    #expect(location.courseTrue == nil)
    #expect(location.horizontalAccuracyDistance == nil)
    #expect(location.verticalAccuracyDistance == nil)
    #expect(location.courseAccuracyAngle == nil)
    #expect(location.speedAccuracyMeasurement == nil)
  }

  /// The boundary the sentinel check gets written wrong at: an aircraft holding short is stopped,
  /// not unmeasured, and a course of north is a course.
  @Test("Zero is a reading, not a sentinel")
  func zeroIsAReading() throws {
    let location = Self.location(course: 0, speed: 0)

    #expect(
      try #require(location.groundSpeed).converted(to: .metersPerSecond).value
        .isApproximatelyEqual(to: 0, absoluteTolerance: 1e-9)
    )
    #expect(
      try #require(location.courseTrue).degrees.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-9)
    )
  }

  @Test("Coordinates cross into Core Location and back unchanged")
  func coordinateBridging() {
    let coordinate = Coordinate(latitude: 37.62, longitude: -122.38)
    let bridged = CLLocationCoordinate2D(coordinate)

    #expect(bridged.latitude.isApproximatelyEqual(to: 37.62, absoluteTolerance: 1e-9))
    #expect(bridged.longitude.isApproximatelyEqual(to: -122.38, absoluteTolerance: 1e-9))
    #expect(bridged.geoCoordinate == coordinate)
    #expect(
      coordinate.clCoordinate.latitude
        .isApproximatelyEqual(to: bridged.latitude, absoluteTolerance: 1e-9)
    )
  }
}
