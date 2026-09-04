public import Foundation

/**
 A difference between two temperatures.

 A difference is not a reading. Readings sit on interval scales with displaced zeros, so they
 neither divide nor meaningfully add; differences sit on a proportional scale, so they do both, and
 a difference of ten Celsius degrees is ten Celsius degrees whatever absolute scale it is carried
 on. Keeping the two in separate types is what stops a deviation from standard temperature being
 added to a temperature as though it were one.
 */
public final class UnitTemperatureDifference: Dimension, ProportionalDimension, @unchecked Sendable
{
  /// Kelvin degrees (ΔK) — the base unit, and the same size as a Celsius degree.
  public static let kelvin = UnitTemperatureDifference(
    symbol: "ΔK",
    converter: UnitConverterLinear(coefficient: 1)
  )

  /// Celsius degrees (Δ°C), the same size as a kelvin.
  public static let celsius = UnitTemperatureDifference(
    symbol: "Δ°C",
    converter: UnitConverterLinear(coefficient: 1)
  )

  /// Fahrenheit degrees (Δ°F), five ninths of a kelvin.
  public static let fahrenheit = UnitTemperatureDifference(
    symbol: "Δ°F",
    converter: UnitConverterLinear(coefficient: 5.0 / 9.0)
  )

  override public static func baseUnit() -> UnitTemperatureDifference { .kelvin }
}
