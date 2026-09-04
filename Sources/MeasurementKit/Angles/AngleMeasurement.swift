public import Foundation

extension Measurement where UnitType == UnitAngle {
  /// The angle in radians, as the dimensionless number the trigonometric functions take.
  public var radians: Double { converted(to: .radians).value }

  /// The angle in degrees.
  public var degrees: Double { converted(to: .degrees).value }

  /// This angle brought into the range a compass direction lives in — zero up to but not including
  /// a full turn.
  ///
  /// Correct for a negative angle, which has to be folded twice to arrive in range.
  public var normalized: Self {
    let wrapped = degrees.truncatingRemainder(dividingBy: 360)
    let folded = wrapped < 0 ? wrapped + 360 : wrapped
    return Measurement(value: folded, unit: UnitAngle.degrees).converted(to: unit)
  }

  /// This angle brought into the range a signed offset or turn lives in — more than half a turn
  /// counterclockwise, up to and including half a turn clockwise.
  public var signedNormalized: Self {
    let folded = normalized.degrees
    let signed = folded > 180 ? folded - 360 : folded
    return Measurement(value: signed, unit: UnitAngle.degrees).converted(to: unit)
  }

  /// The angle opposite this one — the reciprocal course.
  public var reciprocal: Self {
    Measurement(value: degrees + 180, unit: UnitAngle.degrees).normalized.converted(to: unit)
  }

  /**
   This angle turned by `offset`, brought back into compass range.

   The datum-free form of a magnetic-to-true conversion. A bare angle records no north it is
   measured from, so this does not claim to change one; use `MeasurementKitLocation`'s `Bearing`
   where the datum matters.

   - Parameter offset: how far to turn, positive clockwise.
   - Returns: the turned angle.
   */
  public func rotated(by offset: Self) -> Self {
    Measurement(value: degrees + offset.degrees, unit: UnitAngle.degrees)
      .normalized
      .converted(to: unit)
  }
}
