import Foundation

/**
 A dimension expressing one quantity per another, such as a density or a flow rate.

 Carrying the two component units lets an operator answer in the unit the caller was already
 working in rather than in the dimension's base unit: gallons weighed by a density in pounds per
 gallon come back as pounds, not kilograms. Every relation that consumes or produces a derived
 quantity reads its result unit from these two properties.
 */
public protocol DerivedDimension: Dimension {
  /// The dimension of the quantity on top.
  associatedtype Numerator: Dimension
  /// The dimension of the quantity underneath.
  associatedtype Denominator: Dimension

  /// The unit of the quantity on top — the unit a product of this dimension answers in.
  var numeratorUnit: Numerator { get }

  /// The unit of the quantity underneath — the unit a quotient by this dimension answers in.
  var denominatorUnit: Denominator { get }
}

/**
 The conversion coefficient for a unit of `numerator` per a unit of `denominator`.

 The ratio of the two units' own coefficients, so a unit built from it converts in agreement with
 the units it was built from.

 - Parameters:
   - numerator: the unit on top.
   - denominator: the unit underneath.
 - Returns: the coefficient, relative to the derived dimension's base unit.
 */
public func derivedCoefficient(_ numerator: Dimension, per denominator: Dimension) -> Double {
  precondition(
    numerator.converter.value(fromBaseUnitValue: 0) == 0
      && denominator.converter.value(fromBaseUnitValue: 0) == 0,
    "A unit whose scale is displaced from zero has no meaningful ratio."
  )
  return numerator.converter.baseUnitValue(fromValue: 1)
    / denominator.converter.baseUnitValue(fromValue: 1)
}

/**
 A unit of one dimension per a unit of another.

 Builds a unit for a dimension this package does not define — an illuminance, a fuel efficiency —
 without having to work out the coefficient by hand.

 Only units whose scale passes through zero can be combined this way. A scale displaced from zero,
 such as a temperature, has no meaningful ratio, and passing one is a programmer error rather than
 a runtime condition to recover from.

 - Parameters:
   - numerator: the unit on top.
   - denominator: the unit underneath.
   - symbol: the symbol for the result; defaults to the two symbols separated by a solidus.
 - Returns: the derived unit.
 */
public func derivedUnit<Derived: Dimension>(
  _ numerator: Dimension,
  per denominator: Dimension,
  symbol: String? = nil
) -> Derived {
  .init(
    symbol: symbol ?? "\(numerator.symbol)/\(denominator.symbol)",
    converter: UnitConverterLinear(coefficient: derivedCoefficient(numerator, per: denominator))
  )
}
