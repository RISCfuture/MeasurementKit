public import Foundation
import MeasurementKit

/**
 A turn or an offset — an angle from one direction to another, with no north of its own.

 A relative bearing is what subtracting two ``Bearing``s answers, and what ``Bearing`` adds to
 arrive at another bearing. It is signed: positive is clockwise, negative counterclockwise, so
 `-30°` is a thirty-degree left turn and `+30°` the right turn back. It has no datum, because it is
 measured from wherever the aircraft is pointed rather than from a north, and for the same reason
 it has no reciprocal: the direction opposite a turn is just its negation.

 A relative bearing normalizes to the range a turn lives in — more than half a turn
 counterclockwise, up to and including half a turn clockwise — at initialization, so `+270°` and
 `-90°` are the same quarter turn to the left.
 */
public struct RelativeBearing: Hashable, Codable, Sendable, Comparable, CustomStringConvertible {
  /// The angle turned, in (−180°, 180°], positive clockwise.
  public let angle: Measurement<UnitAngle>

  /// The turn in degrees, positive clockwise.
  public var degrees: Double { angle.degrees }

  /// The turn in radians, positive clockwise.
  public var radians: Double { angle.radians }

  /// How far the turn is, without regard to which way it goes.
  public var magnitude: Measurement<UnitAngle> { angle.magnitude }

  public var description: String {
    "\(degrees.formatted(.number.precision(.fractionLength(0...1))))°"
  }

  /// A turn of `angle`, folded into (−180°, 180°].
  ///
  /// - Parameter angle: how far to turn, positive clockwise.
  public init(_ angle: Measurement<UnitAngle>) {
    self.angle = angle.signedNormalized
  }

  /// A turn of `degrees`, positive clockwise.
  ///
  /// - Parameter degrees: how far to turn, in degrees.
  public init(degrees: Double) {
    self.init(Measurement(value: degrees, unit: .degrees))
  }

  /// A turn of `radians`, positive clockwise.
  ///
  /// - Parameter radians: how far to turn, in radians.
  public init(radians: Double) {
    self.init(Measurement(value: radians, unit: .radians))
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(degrees: try container.decode(Double.self))
  }

  /// The turn the other way.
  public static prefix func - (turn: Self) -> Self { .init(-turn.angle) }

  /// The two turns taken in sequence.
  ///
  /// - Parameters:
  ///   - lhs: the first turn.
  ///   - rhs: the turn made after it.
  /// - Returns: the net turn.
  public static func + (lhs: Self, rhs: Self) -> Self { .init(lhs.angle + rhs.angle) }

  /// The turn that `lhs` exceeds `rhs` by.
  ///
  /// - Parameters:
  ///   - lhs: the turn to take from.
  ///   - rhs: the turn to remove.
  /// - Returns: the difference.
  public static func - (lhs: Self, rhs: Self) -> Self { .init(lhs.angle - rhs.angle) }

  public static func < (lhs: Self, rhs: Self) -> Bool { lhs.angle < rhs.angle }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(degrees)
  }
}
