import Foundation

// swiftlint:disable static_operator

/// The measurement negated, in the same unit.
///
/// - Parameter measurement: the measurement to negate.
/// - Returns: the measurement with its sign flipped.
public prefix func - <UnitType: Dimension>(
  measurement: Measurement<UnitType>
) -> Measurement<UnitType> {
  .init(value: -measurement.value, unit: measurement.unit)
}

// swiftlint:enable static_operator

extension Measurement where UnitType: Dimension {
  /// The absolute value, in the same unit.
  public var magnitude: Self { .init(value: value.magnitude, unit: unit) }
}
