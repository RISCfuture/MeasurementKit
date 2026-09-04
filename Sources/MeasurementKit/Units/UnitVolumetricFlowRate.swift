public import Foundation

/**
 A volume flowing per unit time, such as the fuel flow a piston engine is leaned by.

 The flow rate carries the volume and duration units it was built from, so running one for a
 duration answers in that flow rate's own volume unit.
 */
public final class UnitVolumetricFlowRate: Dimension, ProportionalDimension, DerivedDimension,
  @unchecked Sendable
{
  /// Litres per second (L/s) — the base unit.
  public static let litersPerSecond = UnitVolumetricFlowRate(volume: .liters, per: .seconds)

  /// Litres per minute (L/min).
  public static let litersPerMinute = UnitVolumetricFlowRate(volume: .liters, per: .minutes)

  /// Gallons per hour (gal/hr), the unit a piston fuel flow is quoted in.
  public static let gallonsPerHour = UnitVolumetricFlowRate(volume: .gallons, per: .hours)

  /// Cubic metres per second (m³/s).
  public static let cubicMetersPerSecond = UnitVolumetricFlowRate(
    volume: .cubicMeters,
    per: .seconds
  )

  public let numeratorUnit: UnitVolume
  public let denominatorUnit: UnitDuration

  /// A flow of one `volume` per one `duration`.
  ///
  /// - Parameters:
  ///   - volume: the volume unit on top.
  ///   - duration: the duration unit underneath.
  ///   - symbol: the symbol for the unit; defaults to the two symbols separated by a solidus.
  public init(volume: UnitVolume, per duration: UnitDuration, symbol: String? = nil) {
    numeratorUnit = volume
    denominatorUnit = duration
    super.init(
      symbol: symbol ?? "\(volume.symbol)/\(duration.symbol)",
      converter: UnitConverterLinear(coefficient: derivedCoefficient(volume, per: duration))
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

  override public static func baseUnit() -> UnitVolumetricFlowRate { .litersPerSecond }
}
