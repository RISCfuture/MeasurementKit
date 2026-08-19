import Foundation

/**
 A force.

 Foundation ships no force dimension, so the relations that produce one — a mass under an
 acceleration, a pressure over an area, a power delivered at a speed — have nowhere to answer
 without it.
 */
public final class UnitForce: Dimension, ProportionalDimension, @unchecked Sendable {
  /// Newtons (N) — the base unit.
  public static let newtons = UnitForce(
    symbol: "N",
    converter: UnitConverterLinear(coefficient: 1)
  )

  /// Pounds-force (lbf), the unit a thrust rating is published in.
  ///
  /// Derived from Foundation's own pound rather than from the SI definition, so that a mass in
  /// pounds under standard gravity weighs exactly that many pounds-force. Foundation rounds the
  /// pound to 0.453592 kg, and taking the exact 4.4482216152605 N here instead would leave that
  /// identity off by a part in a million.
  public static let poundsForce = UnitForce(
    symbol: "lbf",
    converter: UnitConverterLinear(
      coefficient: UnitMass.pounds.converter.baseUnitValue(fromValue: 1) * standardGravity
    )
  )

  /// Kilograms-force (kgf), also called a kilopond.
  public static let kilogramsForce = UnitForce(
    symbol: "kgf",
    converter: UnitConverterLinear(coefficient: standardGravity)
  )

  /// Standard gravity in metres per second squared, as the standard defines it exactly.
  private static let standardGravity = 9.806_65

  override public static func baseUnit() -> UnitForce { .newtons }
}
