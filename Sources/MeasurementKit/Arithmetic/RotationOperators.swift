import Foundation

// swiftlint:disable static_operator

/// The rate at which `lhs` is swept in `rhs`, in the two operands' own units.
///
/// - Parameters:
///   - lhs: the angle swept.
///   - rhs: the time it took.
/// - Returns: the angular velocity.
public func / (
  lhs: Measurement<UnitAngle>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitAngularVelocity> {
  .init(value: lhs.value / rhs.value, unit: .init(angle: lhs.unit, per: rhs.unit))
}

/// The angle swept at `lhs` over `rhs`, in the angular velocity's own angle unit.
///
/// - Parameters:
///   - lhs: the angular velocity.
///   - rhs: how long it was held.
/// - Returns: the angle swept.
public func * (
  lhs: Measurement<UnitAngularVelocity>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitAngle> {
  let time = rhs.converted(to: lhs.unit.denominatorUnit).value
  return .init(value: lhs.value * time, unit: lhs.unit.numeratorUnit)
}

/// The angle swept at `rhs` over `lhs`.
///
/// - Parameters:
///   - lhs: the duration.
///   - rhs: the angular velocity held over it.
/// - Returns: the angle swept.
public func * (
  lhs: Measurement<UnitDuration>,
  rhs: Measurement<UnitAngularVelocity>
) -> Measurement<UnitAngle> {
  rhs * lhs
}

/// How long `lhs` takes to sweep at `rhs`, in the angular velocity's own duration unit.
///
/// - Parameters:
///   - lhs: the angle to sweep.
///   - rhs: the rate to sweep it at.
/// - Returns: the time taken.
public func / (
  lhs: Measurement<UnitAngle>,
  rhs: Measurement<UnitAngularVelocity>
) -> Measurement<UnitDuration> {
  let angle = lhs.converted(to: rhs.unit.numeratorUnit).value
  return .init(value: angle / rhs.value, unit: rhs.unit.denominatorUnit)
}

/// The radius of a turn flown at `lhs` at a rate of `rhs`, in the length unit of the speed's
/// family.
///
/// - Parameters:
///   - lhs: the speed around the turn.
///   - rhs: the rate of turn.
/// - Returns: the turn radius.
public func / (
  lhs: Measurement<UnitSpeed>,
  rhs: Measurement<UnitAngularVelocity>
) -> Measurement<UnitLength> {
  let speed = lhs.converted(to: .metersPerSecond).value
  let rate = rhs.converted(to: .radiansPerSecond).value
  return Measurement(value: speed / rate, unit: UnitLength.meters)
    .converted(to: lhs.unit.kinematicFamily.lengthUnit)
}

/// The rate of turn flying `lhs` around a radius of `rhs`.
///
/// - Parameters:
///   - lhs: the speed around the turn.
///   - rhs: the turn radius.
/// - Returns: the rate of turn.
public func / (
  lhs: Measurement<UnitSpeed>,
  rhs: Measurement<UnitLength>
) -> Measurement<UnitAngularVelocity> {
  let speed = lhs.converted(to: .metersPerSecond).value
  let radius = rhs.converted(to: .meters).value
  return Measurement(value: speed / radius, unit: UnitAngularVelocity.radiansPerSecond)
    .converted(to: .degreesPerSecond)
}

// swiftlint:enable static_operator
