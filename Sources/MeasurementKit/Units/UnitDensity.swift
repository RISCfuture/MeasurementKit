import Foundation

/**
 A density — mass per unit volume.

 Because a density knows the mass and volume units it was built from, weighing a volume by one
 answers in that density's own mass unit: gallons at pounds per gallon weigh pounds.
 */
public final class UnitDensity: Dimension, ProportionalDimension, DerivedDimension,
  @unchecked Sendable
{
  /// Kilograms per litre (kg/L) — the base unit, since Foundation measures mass in kilograms and
  /// volume in litres.
  public static let kilogramsPerLiter = UnitDensity(mass: .kilograms, per: .liters)

  /// Kilograms per cubic metre (kg/m³), the unit an air density is quoted in.
  public static let kilogramsPerCubicMeter = UnitDensity(mass: .kilograms, per: .cubicMeters)

  /// Pounds per gallon (lb/gal), the unit a fuel density is quoted in.
  public static let poundsPerGallon = UnitDensity(mass: .pounds, per: .gallons)

  /// Pounds per cubic foot (lb/ft³).
  public static let poundsPerCubicFoot = UnitDensity(mass: .pounds, per: .cubicFeet)

  public let numeratorUnit: UnitMass
  public let denominatorUnit: UnitVolume

  /// A density of one `mass` per one `volume`.
  ///
  /// - Parameters:
  ///   - mass: the mass unit on top.
  ///   - volume: the volume unit underneath.
  ///   - symbol: the symbol for the unit; defaults to the two symbols separated by a solidus.
  public init(mass: UnitMass, per volume: UnitVolume, symbol: String? = nil) {
    numeratorUnit = mass
    denominatorUnit = volume
    super.init(
      symbol: symbol ?? "\(mass.symbol)/\(volume.symbol)",
      converter: UnitConverterLinear(coefficient: derivedCoefficient(mass, per: volume))
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

  override public static func baseUnit() -> UnitDensity { .kilogramsPerLiter }
}
