public import Foundation
import MeasurementKit

/**
 The angle between true north and magnetic north at a place — what a chart prints as `16°E` and
 nav data records as a signed number.

 The sign convention is the one the charts use: variation is positive to the east. East variation
 means magnetic north lies clockwise of true north, so a magnetic bearing is the smaller of the
 pair and true is arrived at by adding.

 Read the value off a chart with ``east(_:)`` or ``west(_:)`` rather than remembering which way the
 sign runs.
 */
public struct MagneticVariation: Hashable, Codable, Sendable, CustomStringConvertible {
  /// The angle from true north to magnetic north, positive east.
  public let angle: Measurement<UnitAngle>

  /// The variation in degrees, positive east.
  public var degrees: Double { angle.degrees }

  /// Whether magnetic north lies east of true north.
  public var isEasterly: Bool { degrees > 0 }

  /// Whether magnetic north lies west of true north.
  public var isWesterly: Bool { degrees < 0 }

  public var description: String {
    let hemisphere = isWesterly ? "W" : "E"
    let magnitude = angle.magnitude.degrees
    return "\(magnitude.formatted(.number.precision(.fractionLength(0...1))))°\(hemisphere)"
  }

  /// A variation of `angle`, positive east.
  ///
  /// - Parameter angle: the angle from true north to magnetic north.
  public init(_ angle: Measurement<UnitAngle>) {
    self.angle = angle.signedNormalized
  }

  /// A variation of `degrees`, positive east.
  ///
  /// - Parameter degrees: the angle from true north to magnetic north, in degrees.
  public init(degrees: Double) {
    self.init(Measurement(value: degrees, unit: .degrees))
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(degrees: try container.decode(Double.self))
  }

  /// An easterly variation of `degrees` — magnetic north clockwise of true north.
  ///
  /// - Parameter degrees: how far east, as printed on the chart.
  /// - Returns: the variation.
  public static func east(_ degrees: Double) -> Self { .init(degrees: degrees) }

  /// A westerly variation of `degrees` — magnetic north counterclockwise of true north.
  ///
  /// - Parameter degrees: how far west, as printed on the chart.
  /// - Returns: the variation.
  public static func west(_ degrees: Double) -> Self { .init(degrees: -degrees) }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(degrees)
  }
}
