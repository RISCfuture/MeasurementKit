import Foundation
import MeasurementKit
import Numerics
import Testing

@testable import MeasurementKitLocation

@Suite("Coordinate Tests")
struct CoordinateTests {

  @Test("A degree of latitude is a degree of latitude wherever it is measured")
  func distance() {
    let equator = Coordinate.zero.distance(to: .init(latitude: 1, longitude: 0))
    #expect(
      equator.converted(to: .nauticalMiles).value.isApproximatelyEqual(
        to: 60,
        absoluteTolerance: 0.1
      )
    )

    let highLatitude = Coordinate(latitude: 60, longitude: 0)
      .distance(to: .init(latitude: 61, longitude: 0))
    #expect(
      highLatitude.converted(to: .nauticalMiles).value
        .isApproximatelyEqual(to: 60, absoluteTolerance: 0.1)
    )
  }

  @Test("A degree of longitude shrinks with the cosine of the latitude")
  func longitudeConverges() {
    let equator = Coordinate.zero.distance(to: .init(latitude: 0, longitude: 1))
    let sixtyNorth = Coordinate(latitude: 60, longitude: 0)
      .distance(to: .init(latitude: 60, longitude: 1))

    #expect(
      (sixtyNorth / equator).isApproximatelyEqual(to: 0.5, absoluteTolerance: 1e-3)
    )
  }

  @Test("initialBearing points at the cardinal it should")
  func initialBearing() {
    let origin = Coordinate.zero

    #expect(
      origin.initialBearing(to: .init(latitude: 0, longitude: 1)).degrees
        .isApproximatelyEqual(to: 90, absoluteTolerance: 1e-6)
    )
    #expect(
      origin.initialBearing(to: .init(latitude: 1, longitude: 0)).degrees
        .isApproximatelyEqual(to: 0, absoluteTolerance: 1e-6)
    )
    #expect(
      origin.initialBearing(to: .init(latitude: -1, longitude: 0)).degrees
        .isApproximatelyEqual(to: 180, absoluteTolerance: 1e-6)
    )
    #expect(
      origin.initialBearing(to: .init(latitude: 0, longitude: -1)).degrees
        .isApproximatelyEqual(to: 270, absoluteTolerance: 1e-6)
    )
  }

  /// A great circle crosses each meridian at a different angle, so an easterly leg at latitude
  /// leaves north of due east and arrives south of it, symmetrically.
  @Test("finalBearing differs from the initial bearing away from the equator")
  func finalBearing() {
    let start = Coordinate(latitude: 60, longitude: 0)
    let end = Coordinate(latitude: 60, longitude: 30)

    let initial = start.initialBearing(to: end).degrees
    let final = start.finalBearing(to: end).degrees

    #expect(initial < 90)
    #expect(final > 90)
    #expect((90 - initial).isApproximatelyEqual(to: final - 90, absoluteTolerance: 1e-6))
  }

  @Test("offset walks the distance it is given on the bearing it is given")
  func offset() {
    let start = Coordinate.zero
    let sixtyMiles = Measurement(value: 60, unit: UnitLength.nauticalMiles)

    let north = start.offset(bearing: .init(degrees: 0), distance: sixtyMiles)
    #expect(north.latitude.degrees.isApproximatelyEqual(to: 1, absoluteTolerance: 0.01))
    #expect(north.longitude.degrees.isApproximatelyEqual(to: 0, absoluteTolerance: 0.01))

    let east = start.offset(bearing: .init(degrees: 90), distance: sixtyMiles)
    #expect(east.latitude.degrees.isApproximatelyEqual(to: 0, absoluteTolerance: 0.01))
    #expect(east.longitude.degrees.isApproximatelyEqual(to: 1, absoluteTolerance: 0.01))
  }

  @Test("offset and distance are inverses")
  func offsetRoundTrip() {
    let start = Coordinate(latitude: 37.62, longitude: -122.38)
    let leg = Measurement(value: 250, unit: UnitLength.nauticalMiles)
    let end = start.offset(bearing: .init(degrees: 42), distance: leg)

    let flown = start.distance(to: end).converted(to: .nauticalMiles).value
    #expect(flown.isApproximatelyEqual(to: 250, absoluteTolerance: 1e-6))
    #expect(
      start.initialBearing(to: end).degrees.isApproximatelyEqual(to: 42, absoluteTolerance: 1e-6)
    )
  }

  /// Two points at 60°N either side of the prime meridian: the great circle between them bulges
  /// poleward, so the halfway point is at 63.43°N. Averaging the latitudes would answer 60°N and
  /// put the route more than two hundred miles south of where it goes.
  @Test("interpolated follows the great circle, not the latitude and longitude")
  func interpolatedBulgesPoleward() {
    let start = Coordinate(latitude: 60, longitude: -30)
    let end = Coordinate(latitude: 60, longitude: 30)

    let midpoint = start.interpolated(to: end, fraction: 0.5)
    #expect(midpoint.latitude.degrees.isApproximatelyEqual(to: 63.4349, absoluteTolerance: 1e-3))
    #expect(midpoint.longitude.degrees.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-6))
  }

  @Test("interpolated hits both ends and the point it should in between")
  func interpolatedEndpoints() {
    let start = Coordinate.zero
    let end = Coordinate(latitude: 0, longitude: 90)

    #expect(
      start.interpolated(to: end, fraction: 0).longitude.degrees
        .isApproximatelyEqual(to: 0, absoluteTolerance: 1e-6)
    )
    #expect(
      start.interpolated(to: end, fraction: 1).longitude.degrees
        .isApproximatelyEqual(to: 90, absoluteTolerance: 1e-6)
    )
    #expect(
      start.interpolated(to: end, fraction: 0.5).longitude.degrees
        .isApproximatelyEqual(to: 45, absoluteTolerance: 1e-6)
    )
  }

  @Test("Interpolating between a point and itself stays put")
  func interpolatedDegenerate() {
    let point = Coordinate(latitude: 12, longitude: 34)
    #expect(point.interpolated(to: point, fraction: 0.5) == point)
  }

  @Test("Latitude clamps at the poles and longitude comes back around")
  func rangeAtInitialization() {
    #expect(
      Coordinate(latitude: 95, longitude: 0).latitude.degrees
        .isApproximatelyEqual(to: 90, absoluteTolerance: 1e-9)
    )
    #expect(
      Coordinate(latitude: -95, longitude: 0).latitude.degrees
        .isApproximatelyEqual(to: -90, absoluteTolerance: 1e-9)
    )
    #expect(
      Coordinate(latitude: 0, longitude: 190).longitude.degrees
        .isApproximatelyEqual(to: -170, absoluteTolerance: 1e-9)
    )
    #expect(
      Coordinate(latitude: 0, longitude: -190).longitude.degrees
        .isApproximatelyEqual(to: 170, absoluteTolerance: 1e-9)
    )
    #expect(
      Coordinate(latitude: 0, longitude: 180).longitude.degrees
        .isApproximatelyEqual(to: -180, absoluteTolerance: 1e-9)
    )
  }

  @Test("Coordinates round trip through JSON as plain degrees")
  func codable() throws {
    let coordinate = Coordinate(latitude: 37.62, longitude: -122.38)
    let encoded = try JSONEncoder().encode(coordinate)
    let fields = try #require(try JSONSerialization.jsonObject(with: encoded) as? [String: Double])

    #expect(fields["latitude"]?.isApproximatelyEqual(to: 37.62, absoluteTolerance: 1e-9) == true)
    #expect(try JSONDecoder().decode(Coordinate.self, from: encoded) == coordinate)
  }
}
