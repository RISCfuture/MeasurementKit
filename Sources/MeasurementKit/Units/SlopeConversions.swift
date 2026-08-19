import Foundation

extension Measurement where UnitType == UnitSlope {
  /// The flight path angle a path at this slope climbs at.
  public var angle: Measurement<UnitAngle> {
    .init(value: Foundation.atan(converted(to: .ratio).value), unit: .radians)
  }
}

extension Measurement where UnitType == UnitAngle {
  /// The slope a path at this angle climbs.
  public var slope: Measurement<UnitSlope> {
    .init(value: Foundation.tan(radians), unit: .ratio)
  }
}

extension Measurement where UnitType == UnitLength {
  /**
   The slope of a path rising by this measurement over `run`.

   Spelled as a method rather than as a division, because dividing two lengths already answers how
   many of one fit in the other, and one expression cannot mean both.

   - Parameter run: the horizontal distance the rise is spread over.
   - Returns: the slope.
   */
  public func slope(over run: Self) -> Measurement<UnitSlope> {
    .init(value: value / run.converted(to: unit).value, unit: .ratio)
  }
}
