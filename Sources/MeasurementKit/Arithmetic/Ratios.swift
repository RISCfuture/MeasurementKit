import Foundation

// Operators are declared at module scope rather than as static members so that overload resolution
// sees every relation at once. A static member is looked up on one of the operand types, which is
// the wrong shape for a relation between two different dimensions.
// swiftlint:disable static_operator

/**
 The ratio of two measurements of the same proportional dimension.

 Answered in the left measurement's unit, so no conversion happens when the two already agree.

 - Parameters:
   - lhs: the quantity being divided.
   - rhs: the quantity to divide by.
 - Returns: how many `rhs` fit in `lhs`, a dimensionless number.
 */
public func / <UnitType: ProportionalDimension>(
  lhs: Measurement<UnitType>,
  rhs: Measurement<UnitType>
) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

// Foundation's own dimensions cannot be conformed to `ProportionalDimension` here without imposing
// a retroactive conformance on every consumer, so the ones that sit on a proportional scale get the
// relation directly. `UnitTemperature` is deliberately absent: dividing two readings divides their
// kelvin values, which answers a number that means nothing, so the ratio does not compile for it.
/// The ratio of two length measurements, in the left measurement's unit.
///
/// - Parameters:
///   - lhs: the quantity being divided.
///   - rhs: the quantity to divide by.
/// - Returns: how many `rhs` fit in `lhs`.
public func / (lhs: Measurement<UnitLength>, rhs: Measurement<UnitLength>) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

/// The ratio of two duration measurements, in the left measurement's unit.
///
/// - Parameters:
///   - lhs: the quantity being divided.
///   - rhs: the quantity to divide by.
/// - Returns: how many `rhs` fit in `lhs`.
public func / (lhs: Measurement<UnitDuration>, rhs: Measurement<UnitDuration>) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

/// The ratio of two mass measurements, in the left measurement's unit.
///
/// - Parameters:
///   - lhs: the quantity being divided.
///   - rhs: the quantity to divide by.
/// - Returns: how many `rhs` fit in `lhs`.
public func / (lhs: Measurement<UnitMass>, rhs: Measurement<UnitMass>) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

/// The ratio of two volume measurements, in the left measurement's unit.
///
/// - Parameters:
///   - lhs: the quantity being divided.
///   - rhs: the quantity to divide by.
/// - Returns: how many `rhs` fit in `lhs`.
public func / (lhs: Measurement<UnitVolume>, rhs: Measurement<UnitVolume>) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

/// The ratio of two area measurements, in the left measurement's unit.
///
/// - Parameters:
///   - lhs: the quantity being divided.
///   - rhs: the quantity to divide by.
/// - Returns: how many `rhs` fit in `lhs`.
public func / (lhs: Measurement<UnitArea>, rhs: Measurement<UnitArea>) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

/// The ratio of two speed measurements, in the left measurement's unit.
///
/// - Parameters:
///   - lhs: the quantity being divided.
///   - rhs: the quantity to divide by.
/// - Returns: how many `rhs` fit in `lhs`.
public func / (lhs: Measurement<UnitSpeed>, rhs: Measurement<UnitSpeed>) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

/// The ratio of two acceleration measurements, in the left measurement's unit.
///
/// - Parameters:
///   - lhs: the quantity being divided.
///   - rhs: the quantity to divide by.
/// - Returns: how many `rhs` fit in `lhs`.
public func / (lhs: Measurement<UnitAcceleration>, rhs: Measurement<UnitAcceleration>) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

/// The ratio of two angle measurements, in the left measurement's unit.
///
/// - Parameters:
///   - lhs: the quantity being divided.
///   - rhs: the quantity to divide by.
/// - Returns: how many `rhs` fit in `lhs`.
public func / (lhs: Measurement<UnitAngle>, rhs: Measurement<UnitAngle>) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

/// The ratio of two pressure measurements, in the left measurement's unit.
///
/// - Parameters:
///   - lhs: the quantity being divided.
///   - rhs: the quantity to divide by.
/// - Returns: how many `rhs` fit in `lhs`.
public func / (lhs: Measurement<UnitPressure>, rhs: Measurement<UnitPressure>) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

/// The ratio of two energy measurements, in the left measurement's unit.
///
/// - Parameters:
///   - lhs: the quantity being divided.
///   - rhs: the quantity to divide by.
/// - Returns: how many `rhs` fit in `lhs`.
public func / (lhs: Measurement<UnitEnergy>, rhs: Measurement<UnitEnergy>) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

/// The ratio of two power measurements, in the left measurement's unit.
///
/// - Parameters:
///   - lhs: the quantity being divided.
///   - rhs: the quantity to divide by.
/// - Returns: how many `rhs` fit in `lhs`.
public func / (lhs: Measurement<UnitPower>, rhs: Measurement<UnitPower>) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

/// The ratio of two frequency measurements, in the left measurement's unit.
///
/// - Parameters:
///   - lhs: the quantity being divided.
///   - rhs: the quantity to divide by.
/// - Returns: how many `rhs` fit in `lhs`.
public func / (lhs: Measurement<UnitFrequency>, rhs: Measurement<UnitFrequency>) -> Double {
  lhs.value / rhs.converted(to: lhs.unit).value
}

// swiftlint:enable static_operator
