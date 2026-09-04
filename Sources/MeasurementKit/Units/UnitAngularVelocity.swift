public import Foundation

/**
 An angle swept per unit time — a rate of turn, or a rotational speed.

 The base unit is degrees per second, following Foundation's choice of the degree as the base unit
 of angle.
 */
public final class UnitAngularVelocity: Dimension, ProportionalDimension, DerivedDimension,
  @unchecked Sendable
{
  /// Degrees per second (°/s) — the base unit, and the unit a rate of turn is flown by.
  ///
  /// A standard-rate turn is three degrees per second.
  public static let degreesPerSecond = UnitAngularVelocity(angle: .degrees, per: .seconds)

  /// Radians per second (rad/s).
  public static let radiansPerSecond = UnitAngularVelocity(angle: .radians, per: .seconds)

  /// Degrees per minute (°/min).
  public static let degreesPerMinute = UnitAngularVelocity(angle: .degrees, per: .minutes)

  /// Revolutions per minute (rpm).
  ///
  /// A revolution is not a Foundation angle unit, so the coefficient is stated: a revolution is
  /// three hundred sixty degrees, and a minute is sixty seconds.
  public static let revolutionsPerMinute = UnitAngularVelocity(
    symbol: "rpm",
    converter: UnitConverterLinear(coefficient: 360.0 / 60.0)
  )

  public let numeratorUnit: UnitAngle
  public let denominatorUnit: UnitDuration

  /// An angular velocity of one `angle` per one `duration`.
  ///
  /// - Parameters:
  ///   - angle: the angle unit on top.
  ///   - duration: the duration unit underneath.
  ///   - symbol: the symbol for the unit; defaults to the two symbols separated by a solidus.
  public init(angle: UnitAngle, per duration: UnitDuration, symbol: String? = nil) {
    numeratorUnit = angle
    denominatorUnit = duration
    super.init(
      symbol: symbol ?? "\(angle.symbol)/\(duration.symbol)",
      converter: UnitConverterLinear(coefficient: derivedCoefficient(angle, per: duration))
    )
  }

  override public required init(symbol: String, converter: UnitConverter) {
    numeratorUnit = .baseUnit()
    denominatorUnit = .baseUnit()
    super.init(symbol: symbol, converter: converter)
  }

  public required init?(coder: NSCoder) {
    numeratorUnit = .baseUnit()
    denominatorUnit = .baseUnit()
    super.init(coder: coder)
  }

  override public static func baseUnit() -> UnitAngularVelocity { .degreesPerSecond }
}
