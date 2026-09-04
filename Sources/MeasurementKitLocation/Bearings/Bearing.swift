public import Foundation
import MeasurementKit

/**
 A compass direction measured clockwise from the north that ``BearingDatum`` names.

 The datum rides along in the type, so a true bearing and a magnetic bearing are different types
 and the compiler rejects the arithmetic that mixes them. Converting between the two is not an
 accident you can have: `toMagnetic(variation:)` exists only on a ``TrueBearing``
 and `toTrue(variation:)` only on a ``MagneticBearing``, and each of them takes the variation to
 apply.

 A bearing normalizes into [0°, 360°) at initialization, so there is no normalization step to
 forget downstream — `Bearing(degrees: 370)` and `Bearing(degrees: -350)` are both 10°.

 ```swift
 let runway = TrueBearing(degrees: 10)
 let published = runway.toMagnetic(variation: .east(16))  // 354°M
 ```
 */
public struct Bearing<Datum: BearingDatum>: Hashable, Codable, Sendable, Comparable,
  CustomStringConvertible
{
  /// The angle clockwise from the datum's north, always in [0°, 360°).
  public let angle: Measurement<UnitAngle>

  /// The bearing in degrees, in [0, 360).
  public var degrees: Double { angle.degrees }

  /// The bearing in radians, in [0, 2π).
  public var radians: Double { angle.radians }

  /// The bearing opposite this one — the reciprocal course, in the same datum.
  public var reciprocal: Self { .init(angle.reciprocal) }

  public var description: String {
    "\(degrees.formatted(.number.precision(.fractionLength(0...1))))°\(Datum.abbreviation)"
  }

  /// A bearing of `angle`, folded into [0°, 360°).
  ///
  /// - Parameter angle: the direction, measured clockwise from the datum's north.
  public init(_ angle: Measurement<UnitAngle>) {
    self.angle = angle.normalized
  }

  /// A bearing of `degrees`, folded into [0, 360).
  ///
  /// - Parameter degrees: the direction in degrees, clockwise from the datum's north.
  public init(degrees: Double) {
    self.init(Measurement(value: degrees, unit: .degrees))
  }

  /// A bearing of `radians`, folded into [0, 2π).
  ///
  /// - Parameter radians: the direction in radians, clockwise from the datum's north.
  public init(radians: Double) {
    self.init(Measurement(value: radians, unit: .radians))
  }

  /**
   Decodes a bearing, checking that the encoded datum is the one this type was asked for.

   The check is the reason the conformance is written by hand. A synthesized `Codable` would encode
   the angle alone, and a `Bearing<True>` would then decode without complaint from data a
   `Bearing<Magnetic>` wrote — the exact confusion the type parameter exists to prevent, sneaking
   back in through the file format.

   - Parameter decoder: the decoder to read from.
   - Throws: `DecodingError.dataCorrupted` when the encoded datum is not this bearing's.
   */
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let datum = try container.decode(String.self, forKey: .datum)
    guard datum == Datum.abbreviation else {
      throw DecodingError.dataCorruptedError(
        forKey: .datum,
        in: container,
        debugDescription:
          "Expected a bearing in datum \(Datum.abbreviation), but the data is in datum \(datum)."
      )
    }
    self.init(degrees: try container.decode(Double.self, forKey: .degrees))
  }

  /// The signed turn from `rhs` to `lhs`, in (−180°, 180°].
  ///
  /// - Parameters:
  ///   - lhs: the bearing turned to.
  ///   - rhs: the bearing turned from.
  /// - Returns: the turn, positive clockwise.
  public static func - (lhs: Self, rhs: Self) -> RelativeBearing {
    .init(lhs.angle - rhs.angle)
  }

  /// The bearing arrived at by turning `turn` from `bearing`.
  ///
  /// - Parameters:
  ///   - bearing: the bearing turned from.
  ///   - turn: how far to turn, positive clockwise.
  /// - Returns: the bearing rolled out on, in the same datum.
  public static func + (bearing: Self, turn: RelativeBearing) -> Self {
    .init(bearing.angle + turn.angle)
  }

  /// The bearing arrived at by turning `turn` the other way from `bearing`.
  ///
  /// - Parameters:
  ///   - bearing: the bearing turned from.
  ///   - turn: how far to turn, positive counterclockwise.
  /// - Returns: the bearing rolled out on, in the same datum.
  public static func - (bearing: Self, turn: RelativeBearing) -> Self {
    .init(bearing.angle - turn.angle)
  }

  public static func < (lhs: Self, rhs: Self) -> Bool { lhs.angle < rhs.angle }

  /// The shorter of the two turns that roll out on `other`.
  ///
  /// - Parameter other: the bearing to turn to.
  /// - Returns: the turn, positive to the right and negative to the left, never more than half a
  ///   turn either way.
  public func shortestTurn(to other: Self) -> RelativeBearing { other - self }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(degrees, forKey: .degrees)
    try container.encode(Datum.abbreviation, forKey: .datum)
  }

  private enum CodingKeys: String, CodingKey {
    case degrees, datum
  }
}

/// A bearing measured from geographic north.
public typealias TrueBearing = Bearing<True>

/// A bearing measured from magnetic north.
public typealias MagneticBearing = Bearing<Magnetic>
