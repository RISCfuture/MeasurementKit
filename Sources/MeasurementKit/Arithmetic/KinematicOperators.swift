public import Foundation

// swiftlint:disable static_operator

/// The speed that covers `lhs` in `rhs`, in the speed unit of the distance's family.
///
/// - Parameters:
///   - lhs: the distance covered.
///   - rhs: the time it took.
/// - Returns: the speed.
public func / (
  lhs: Measurement<UnitLength>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitSpeed> {
  let family = lhs.unit.kinematicFamily
  let distance = lhs.converted(to: family.lengthUnit).value
  let time = rhs.converted(to: family.durationUnit).value
  return .init(value: distance / time, unit: family.speedUnit)
}

/// The time `lhs` takes at `rhs`, in the duration unit of the distance's family.
///
/// - Parameters:
///   - lhs: the distance to cover.
///   - rhs: the speed to cover it at.
/// - Returns: the time taken.
public func / (
  lhs: Measurement<UnitLength>,
  rhs: Measurement<UnitSpeed>
) -> Measurement<UnitDuration> {
  let family = lhs.unit.kinematicFamily
  let distance = lhs.converted(to: family.lengthUnit).value
  let speed = rhs.converted(to: family.speedUnit).value
  return .init(value: distance / speed, unit: family.durationUnit)
}

/// The distance covered at `lhs` for `rhs`, in the length unit of the speed's family.
///
/// - Parameters:
///   - lhs: the speed travelled at.
///   - rhs: how long it was held.
/// - Returns: the distance covered.
public func * (
  lhs: Measurement<UnitSpeed>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitLength> {
  let family = lhs.unit.kinematicFamily
  let speed = lhs.converted(to: family.speedUnit).value
  let time = rhs.converted(to: family.durationUnit).value
  return .init(value: speed * time, unit: family.lengthUnit)
}

/// The distance covered at `rhs` for `lhs`.
///
/// A duration names no family of its own, so the speed governs the unit the distance comes back in.
///
/// - Parameters:
///   - lhs: how long the speed was held.
///   - rhs: the speed travelled at.
/// - Returns: the distance covered.
public func * (
  lhs: Measurement<UnitDuration>,
  rhs: Measurement<UnitSpeed>
) -> Measurement<UnitLength> {
  rhs * lhs
}

/// The acceleration that changes speed by `lhs` over `rhs`, in the acceleration unit of the
/// speed's family.
///
/// - Parameters:
///   - lhs: the change in speed.
///   - rhs: the time it took.
/// - Returns: the acceleration.
public func / (
  lhs: Measurement<UnitSpeed>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitAcceleration> {
  let family = lhs.unit.kinematicFamily
  let speed = lhs.converted(to: family.speedUnit).value
  let time = rhs.converted(to: family.durationUnit).value
  let perSecond =
    speed * family.speedUnit.converter.baseUnitValue(fromValue: 1)
    / (time * family.durationUnit.converter.baseUnitValue(fromValue: 1))
  return Measurement(value: perSecond, unit: .metersPerSecondSquared)
    .converted(to: family.accelerationUnit)
}

/// The time taken to change speed by `lhs` at `rhs`.
///
/// Answered in seconds rather than in the speed's own family, because every Foundation
/// acceleration is stated per second squared: the acceleration names the time unit, and an
/// acceleration expressed in hours would be a strange thing to write.
///
/// - Parameters:
///   - lhs: the change in speed.
///   - rhs: the acceleration applied.
/// - Returns: the time taken, in seconds.
public func / (
  lhs: Measurement<UnitSpeed>,
  rhs: Measurement<UnitAcceleration>
) -> Measurement<UnitDuration> {
  let speed = lhs.converted(to: .metersPerSecond).value
  let acceleration = rhs.converted(to: .metersPerSecondSquared).value
  return .init(value: speed / acceleration, unit: .seconds)
}

/// The speed gained by accelerating at `lhs` for `rhs`, in the speed unit of the acceleration's
/// family.
///
/// - Parameters:
///   - lhs: the acceleration applied.
///   - rhs: how long it was held.
/// - Returns: the change in speed.
public func * (
  lhs: Measurement<UnitAcceleration>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitSpeed> {
  let family = lhs.unit.kinematicFamily
  let acceleration = lhs.converted(to: .metersPerSecondSquared).value
  let time = rhs.converted(to: .seconds).value
  return Measurement(value: acceleration * time, unit: UnitSpeed.metersPerSecond)
    .converted(to: family.speedUnit)
}

/// The speed gained by accelerating at `rhs` for `lhs`.
///
/// A duration names no family of its own, so the acceleration governs the unit.
///
/// - Parameters:
///   - lhs: how long the acceleration was held.
///   - rhs: the acceleration applied.
/// - Returns: the change in speed.
public func * (
  lhs: Measurement<UnitDuration>,
  rhs: Measurement<UnitAcceleration>
) -> Measurement<UnitSpeed> {
  rhs * lhs
}

// swiftlint:enable static_operator
