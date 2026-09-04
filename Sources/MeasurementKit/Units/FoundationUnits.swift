public import Foundation

extension UnitSpeed {
  /// Feet per minute (ft/min), the unit a vertical speed is flown by.
  ///
  /// Exactly one foot per minute: 0.3048 metres over sixty seconds.
  public static let feetPerMinute = UnitSpeed(
    symbol: "ft/min",
    converter: UnitConverterLinear(coefficient: 0.3048 / 60)
  )
}

extension UnitAcceleration {
  /// Knots per second (kn/s), the unit an acceleration along a runway is quoted in.
  public static let knotsPerSecond = UnitAcceleration(
    symbol: "kn/s",
    converter: UnitConverterLinear(
      coefficient: UnitSpeed.knots.converter.baseUnitValue(fromValue: 1)
    )
  )
}

extension Measurement where UnitType == UnitAcceleration {
  /// Standard gravity — the acceleration a free-falling body picks up at the Earth's surface.
  ///
  /// Stated in metres per second squared rather than as one `UnitAcceleration.gravity`, because
  /// Foundation rounds its gravity to 9.81 m/s² while the standard defines it as exactly
  /// 9.80665 m/s². The rounding is enough to make a mass in pounds weigh a different number of
  /// pounds-force.
  public static var standardGravity: Self { .init(value: 9.806_65, unit: .metersPerSecondSquared) }
}
