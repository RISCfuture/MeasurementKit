import Foundation
import MeasurementKit

/**
 A point on the Earth, as a latitude and a longitude.

 Both components are angles, not bare `Double`s, so the unit they were measured in travels with
 them and a coordinate built from radians is the same coordinate as one built from degrees.

 A coordinate puts itself in range at initialization: latitude is clamped to ±90°, since there is
 no point beyond a pole to name, and longitude is wrapped into [−180°, 180°), since a meridian
 comes back around. Arithmetic that runs off the end of the world therefore lands somewhere real.
 */
public struct Coordinate: Hashable, Codable, Sendable, CustomStringConvertible {
  /// The equator.
  public static let zero = Self(latitude: 0, longitude: 0)

  /// Degrees north of the equator, in [−90°, 90°].
  public let latitude: Measurement<UnitAngle>

  /// Degrees east of the prime meridian, in [−180°, 180°).
  public let longitude: Measurement<UnitAngle>

  var latitudeRadians: Double { latitude.radians }

  var longitudeRadians: Double { longitude.radians }

  public var description: String {
    let format = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(0...6))
    return "\(latitude.degrees.formatted(format))°, \(longitude.degrees.formatted(format))°"
  }

  /// The point at `latitude` and `longitude`, brought into range.
  ///
  /// - Parameters:
  ///   - latitude: how far north of the equator, clamped to ±90°.
  ///   - longitude: how far east of the prime meridian, wrapped into [−180°, 180°).
  public init(latitude: Measurement<UnitAngle>, longitude: Measurement<UnitAngle>) {
    self.latitude = latitude.clampedToPole
    self.longitude = longitude.wrappedToMeridian
  }

  /// The point at `latitude` and `longitude`, brought into range.
  ///
  /// - Parameters:
  ///   - latitude: how far north of the equator.
  ///   - longitude: how far east of the prime meridian.
  ///   - unit: the unit both are measured in; degrees unless said otherwise.
  public init(latitude: Double, longitude: Double, unit: UnitAngle = .degrees) {
    self.init(
      latitude: Measurement(value: latitude, unit: unit),
      longitude: Measurement(value: longitude, unit: unit)
    )
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.init(
      latitude: try container.decode(Double.self, forKey: .latitude),
      longitude: try container.decode(Double.self, forKey: .longitude)
    )
  }

  /**
   The great-circle distance to `other` — the shortest distance over the surface.

   - Parameter other: the point to measure to.
   - Returns: the distance, in metres.
   */
  public func distance(to other: Self) -> Measurement<UnitLength> {
    Earth.meanRadius * angularDistance(to: other)
  }

  /**
   The bearing to steer on departure to fly the great circle to `other`.

   A great circle other than a meridian or the equator crosses each meridian at a different angle,
   so the bearing changes continuously along the route; this is the one at this end of it. See
   ``finalBearing(to:)`` for the one at the other end.

   - Parameter other: the point being flown to.
   - Returns: the initial bearing, true.
   */
  public func initialBearing(to other: Self) -> TrueBearing {
    let deltaLongitude = other.longitudeRadians - longitudeRadians
    let y = sin(deltaLongitude) * cos(other.latitudeRadians)
    let x =
      cos(latitudeRadians) * sin(other.latitudeRadians)
      - sin(latitudeRadians) * cos(other.latitudeRadians) * cos(deltaLongitude)
    return .init(radians: atan2(y, x))
  }

  /**
   The bearing the great circle to `other` arrives on.

   - Parameter other: the point being flown to.
   - Returns: the bearing at arrival, true.
   */
  public func finalBearing(to other: Self) -> TrueBearing {
    other.initialBearing(to: self).reciprocal
  }

  /**
   The point reached by flying `distance` from here along the great circle that departs on
   `bearing`.

   - Parameters:
     - bearing: the true bearing to depart on.
     - distance: how far to fly.
   - Returns: the point arrived at.
   */
  public func offset(bearing: TrueBearing, distance: Measurement<UnitLength>) -> Self {
    let travelled = distance / Earth.meanRadius
    let latitude = asin(
      sin(latitudeRadians) * cos(travelled)
        + cos(latitudeRadians) * sin(travelled) * cos(bearing.radians)
    )
    let longitude =
      longitudeRadians
      + atan2(
        sin(bearing.radians) * sin(travelled) * cos(latitudeRadians),
        cos(travelled) - sin(latitudeRadians) * sin(latitude)
      )
    return .init(latitude: latitude, longitude: longitude, unit: .radians)
  }

  /**
   The point `fraction` of the way along the great circle to `other`.

   Interpolation follows the great circle, not the latitude and longitude separately. Averaging the
   two components instead would leave the route on neither the short way round nor any other real
   path — at high latitudes it can miss by hundreds of miles, and across the antimeridian it goes
   the wrong way round the world.

   - Parameters:
     - other: the far end of the route.
     - fraction: how far along, zero at this point and one at `other`; values outside [0, 1]
       extrapolate along the same great circle.
   - Returns: the point on the route.
   */
  public func interpolated(to other: Self, fraction: Double) -> Self {
    let travelled = angularDistance(to: other)
    guard travelled > 0 else { return self }

    let fromWeight = sin((1 - fraction) * travelled) / sin(travelled)
    let toWeight = sin(fraction * travelled) / sin(travelled)
    let x =
      fromWeight * cos(latitudeRadians) * cos(longitudeRadians)
      + toWeight * cos(other.latitudeRadians) * cos(other.longitudeRadians)
    let y =
      fromWeight * cos(latitudeRadians) * sin(longitudeRadians)
      + toWeight * cos(other.latitudeRadians) * sin(other.longitudeRadians)
    let z = fromWeight * sin(latitudeRadians) + toWeight * sin(other.latitudeRadians)

    return .init(
      latitude: atan2(z, (x * x + y * y).squareRoot()),
      longitude: atan2(y, x),
      unit: .radians
    )
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(latitude.degrees, forKey: .latitude)
    try container.encode(longitude.degrees, forKey: .longitude)
  }

  /// The angle this point and `other` subtend at the centre of the Earth, in radians.
  ///
  /// The haversine form, which keeps its precision for the short distances a navigation display
  /// spends its time on where the law of cosines loses it.
  func angularDistance(to other: Self) -> Double {
    let deltaLatitude = other.latitudeRadians - latitudeRadians
    let deltaLongitude = other.longitudeRadians - longitudeRadians
    let haversine =
      pow(sin(deltaLatitude / 2), 2)
      + cos(latitudeRadians) * cos(other.latitudeRadians) * pow(sin(deltaLongitude / 2), 2)
    return 2 * atan2(haversine.squareRoot(), (1 - haversine).squareRoot())
  }

  private enum CodingKeys: String, CodingKey {
    case latitude, longitude
  }
}

extension Measurement where UnitType == UnitAngle {
  /// This angle held to a latitude the globe has, ±90°.
  fileprivate var clampedToPole: Self {
    let pole = Measurement(value: 90, unit: UnitAngle.degrees).converted(to: unit)
    return clamped(to: -pole...pole)
  }

  /// This angle wrapped to the longitude naming the same meridian, in [−180°, 180°).
  fileprivate var wrappedToMeridian: Self {
    let folded = normalized.degrees
    let wrapped = folded >= 180 ? folded - 360 : folded
    return Measurement(value: wrapped, unit: UnitAngle.degrees).converted(to: unit)
  }
}
