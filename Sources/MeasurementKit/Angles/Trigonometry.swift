import Foundation

/// The sine of `angle`.
public func sin(_ angle: Measurement<UnitAngle>) -> Double { sin(angle.radians) }

/// The cosine of `angle`.
public func cos(_ angle: Measurement<UnitAngle>) -> Double { cos(angle.radians) }

/// The tangent of `angle`.
public func tan(_ angle: Measurement<UnitAngle>) -> Double { tan(angle.radians) }

extension Measurement where UnitType == UnitAngle {
  /// The angle whose sine is `value`.
  ///
  /// - Parameter value: the sine.
  /// - Returns: the angle, in radians.
  public static func arcsin(_ value: Double) -> Self {
    .init(value: Foundation.asin(value), unit: .radians)
  }

  /// The angle whose cosine is `value`.
  ///
  /// - Parameter value: the cosine.
  /// - Returns: the angle, in radians.
  public static func arccos(_ value: Double) -> Self {
    .init(value: Foundation.acos(value), unit: .radians)
  }

  /// The angle whose tangent is `value`.
  ///
  /// - Parameter value: the tangent.
  /// - Returns: the angle, in radians.
  public static func arctan(_ value: Double) -> Self {
    .init(value: Foundation.atan(value), unit: .radians)
  }

  /// The angle from the positive x-axis to the point (`x`, `y`).
  ///
  /// - Parameters:
  ///   - y: the point's ordinate.
  ///   - x: the point's abscissa.
  /// - Returns: the angle, in radians, in the range a signed offset lives in.
  public static func arctan(y: Double, x: Double) -> Self {
    .init(value: Foundation.atan2(y, x), unit: .radians)
  }
}
