import Foundation

/**
 A mass flowing per unit time, such as the fuel flow a turbine engine is set by.

 The flow rate carries the mass and duration units it was built from, so running one for a duration
 answers in that flow rate's own mass unit.
 */
public final class UnitMassFlowRate: Dimension, ProportionalDimension, DerivedDimension,
  @unchecked Sendable
{
  /// Kilograms per second (kg/s) — the base unit.
  public static let kilogramsPerSecond = UnitMassFlowRate(mass: .kilograms, per: .seconds)

  /// Kilograms per hour (kg/hr).
  public static let kilogramsPerHour = UnitMassFlowRate(mass: .kilograms, per: .hours)

  /// Pounds per hour (lb/hr), the unit a turbine fuel flow is quoted in.
  public static let poundsPerHour = UnitMassFlowRate(mass: .pounds, per: .hours)

  public let numeratorUnit: UnitMass
  public let denominatorUnit: UnitDuration

  /// A flow of one `mass` per one `duration`.
  ///
  /// - Parameters:
  ///   - mass: the mass unit on top.
  ///   - duration: the duration unit underneath.
  ///   - symbol: the symbol for the unit; defaults to the two symbols separated by a solidus.
  public init(mass: UnitMass, per duration: UnitDuration, symbol: String? = nil) {
    numeratorUnit = mass
    denominatorUnit = duration
    super.init(
      symbol: symbol ?? "\(mass.symbol)/\(duration.symbol)",
      converter: UnitConverterLinear(coefficient: derivedCoefficient(mass, per: duration))
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

  override public static func baseUnit() -> UnitMassFlowRate { .kilogramsPerSecond }
}
