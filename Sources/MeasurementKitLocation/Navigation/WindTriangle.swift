import Foundation

/**
 The wind triangle: what an aircraft pointed one way and pushed another actually does over the
 ground.

 Give it where the nose is pointed and how fast the aircraft moves through the air, plus where the
 wind is coming from and how hard it blows, and it answers the track made good and the speed made
 good over the ground.

 ```swift
 let triangle = WindTriangle(
   heading: TrueBearing(degrees: 360),
   trueAirspeed: .init(value: 100, unit: .knots),
   windFrom: TrueBearing(degrees: 90),
   windSpeed: .init(value: 20, unit: .knots)
 )
 triangle.track        // 348.69°T — blown left of the nose
 triangle.groundSpeed  // 101.98 kn
 ```

 Wind direction follows the meteorological convention the reports use: `windFrom` is the direction
 the wind blows *from*, so a `270` wind is a westerly and pushes the aircraft east.
 */
public struct WindTriangle: Hashable, Sendable {
  /// Where the nose is pointed.
  public let heading: TrueBearing

  /// How fast the aircraft moves through the air.
  public let trueAirspeed: Measurement<UnitSpeed>

  /// The direction the wind blows from.
  public let windFrom: TrueBearing

  /// How hard the wind blows.
  public let windSpeed: Measurement<UnitSpeed>

  /// The path made good over the ground.
  public var track: TrueBearing { .init(radians: atan2(eastward, northward)) }

  /// The speed made good over the ground, in the true airspeed's unit.
  public var groundSpeed: Measurement<UnitSpeed> {
    .init(
      value: (eastward * eastward + northward * northward).squareRoot(),
      unit: trueAirspeed.unit
    )
  }

  /// How far the wind sets the aircraft off the heading — positive when it drifts right of the
  /// nose.
  public var driftAngle: RelativeBearing { heading.shortestTurn(to: track) }

  /// The easterly component of the ground vector, in the true airspeed's unit.
  private var eastward: Double {
    airspeed * sin(heading.radians) + wind * sin(windTowardRadians)
  }

  /// The northerly component of the ground vector, in the true airspeed's unit.
  private var northward: Double {
    airspeed * cos(heading.radians) + wind * cos(windTowardRadians)
  }

  private var airspeed: Double { trueAirspeed.value }

  private var wind: Double { windSpeed.converted(to: trueAirspeed.unit).value }

  /// The direction the wind blows toward, in radians — the reciprocal of the direction it is
  /// reported from.
  private var windTowardRadians: Double { windFrom.reciprocal.radians }

  /// The triangle flown by an aircraft on `heading` at `trueAirspeed` in the given wind.
  ///
  /// - Parameters:
  ///   - heading: where the nose is pointed.
  ///   - trueAirspeed: how fast the aircraft moves through the air.
  ///   - windFrom: the direction the wind blows from.
  ///   - windSpeed: how hard the wind blows.
  public init(
    heading: TrueBearing,
    trueAirspeed: Measurement<UnitSpeed>,
    windFrom: TrueBearing,
    windSpeed: Measurement<UnitSpeed>
  ) {
    self.heading = heading
    self.trueAirspeed = trueAirspeed
    self.windFrom = windFrom
    self.windSpeed = windSpeed
  }
}
