import Foundation

/**
 A slope — rise over run.

 Both a runway gradient and a climb gradient are slopes, published in different units: a runway in
 percent, a climb in feet per nautical mile.
 */
public final class UnitSlope: Dimension, ProportionalDimension, @unchecked Sendable {
  /// A plain decimal ratio of rise to run — the base unit.
  ///
  /// The symbol is the SI spelling for a ratio of like quantities. It is deliberately not `m`,
  /// which is a metre.
  public static let ratio = UnitSlope(
    symbol: "m/m",
    converter: UnitConverterLinear(coefficient: 1)
  )

  /// Hundredths of a ratio (%), the unit a runway gradient is published in.
  public static let percent = UnitSlope(
    symbol: "%",
    converter: UnitConverterLinear(coefficient: 0.01)
  )

  /// Feet per nautical mile (ft/NM), the unit a climb gradient is published in.
  public static let feetPerNauticalMile = UnitSlope(
    symbol: "ft/NM",
    converter: UnitConverterLinear(
      coefficient: derivedCoefficient(UnitLength.feet, per: UnitLength.nauticalMiles)
    )
  )

  override public static func baseUnit() -> UnitSlope { .ratio }
}
