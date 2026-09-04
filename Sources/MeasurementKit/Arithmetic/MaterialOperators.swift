public import Foundation

// swiftlint:disable static_operator

/// The mass of `lhs` at `rhs`, in the density's own mass unit.
///
/// A density names both units of the answer, so gallons weighed by a density in pounds per gallon
/// weigh pounds.
///
/// - Parameters:
///   - lhs: the volume.
///   - rhs: the density it is filled with.
/// - Returns: the mass.
public func * (
  lhs: Measurement<UnitVolume>,
  rhs: Measurement<UnitDensity>
) -> Measurement<UnitMass> {
  let volume = lhs.converted(to: rhs.unit.denominatorUnit).value
  return .init(value: volume * rhs.value, unit: rhs.unit.numeratorUnit)
}

/// The mass of `rhs` at `lhs`.
///
/// - Parameters:
///   - lhs: the density.
///   - rhs: the volume it fills.
/// - Returns: the mass.
public func * (
  lhs: Measurement<UnitDensity>,
  rhs: Measurement<UnitVolume>
) -> Measurement<UnitMass> {
  rhs * lhs
}

/// The volume `lhs` occupies at `rhs`, in the density's own volume unit.
///
/// - Parameters:
///   - lhs: the mass.
///   - rhs: the density it has.
/// - Returns: the volume.
public func / (
  lhs: Measurement<UnitMass>,
  rhs: Measurement<UnitDensity>
) -> Measurement<UnitVolume> {
  let mass = lhs.converted(to: rhs.unit.numeratorUnit).value
  return .init(value: mass / rhs.value, unit: rhs.unit.denominatorUnit)
}

/// The density of `lhs` filling `rhs`, in the two operands' own units.
///
/// - Parameters:
///   - lhs: the mass.
///   - rhs: the volume it fills.
/// - Returns: the density.
public func / (
  lhs: Measurement<UnitMass>,
  rhs: Measurement<UnitVolume>
) -> Measurement<UnitDensity> {
  .init(value: lhs.value / rhs.value, unit: .init(mass: lhs.unit, per: rhs.unit))
}

/// The rate at which `lhs` flows in `rhs`, in the two operands' own units.
///
/// - Parameters:
///   - lhs: the volume that flowed.
///   - rhs: the time it took.
/// - Returns: the flow rate.
public func / (
  lhs: Measurement<UnitVolume>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitVolumetricFlowRate> {
  .init(value: lhs.value / rhs.value, unit: .init(volume: lhs.unit, per: rhs.unit))
}

/// The volume that flows at `lhs` for `rhs`, in the flow rate's own volume unit.
///
/// - Parameters:
///   - lhs: the flow rate.
///   - rhs: how long it flowed.
/// - Returns: the volume.
public func * (
  lhs: Measurement<UnitVolumetricFlowRate>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitVolume> {
  let time = rhs.converted(to: lhs.unit.denominatorUnit).value
  return .init(value: lhs.value * time, unit: lhs.unit.numeratorUnit)
}

/// The volume that flows at `rhs` for `lhs`.
///
/// - Parameters:
///   - lhs: how long it flowed.
///   - rhs: the flow rate.
/// - Returns: the volume.
public func * (
  lhs: Measurement<UnitDuration>,
  rhs: Measurement<UnitVolumetricFlowRate>
) -> Measurement<UnitVolume> {
  rhs * lhs
}

/// How long `lhs` takes to flow at `rhs`, in the flow rate's own duration unit.
///
/// - Parameters:
///   - lhs: the volume to move.
///   - rhs: the flow rate.
/// - Returns: the time taken.
public func / (
  lhs: Measurement<UnitVolume>,
  rhs: Measurement<UnitVolumetricFlowRate>
) -> Measurement<UnitDuration> {
  let volume = lhs.converted(to: rhs.unit.numeratorUnit).value
  return .init(value: volume / rhs.value, unit: rhs.unit.denominatorUnit)
}

/// The rate at which `lhs` flows in `rhs`, in the two operands' own units.
///
/// - Parameters:
///   - lhs: the mass that flowed.
///   - rhs: the time it took.
/// - Returns: the flow rate.
public func / (
  lhs: Measurement<UnitMass>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitMassFlowRate> {
  .init(value: lhs.value / rhs.value, unit: .init(mass: lhs.unit, per: rhs.unit))
}

/// The mass that flows at `lhs` for `rhs`, in the flow rate's own mass unit.
///
/// - Parameters:
///   - lhs: the flow rate.
///   - rhs: how long it flowed.
/// - Returns: the mass.
public func * (
  lhs: Measurement<UnitMassFlowRate>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitMass> {
  let time = rhs.converted(to: lhs.unit.denominatorUnit).value
  return .init(value: lhs.value * time, unit: lhs.unit.numeratorUnit)
}

/// The mass that flows at `rhs` for `lhs`.
///
/// - Parameters:
///   - lhs: how long it flowed.
///   - rhs: the flow rate.
/// - Returns: the mass.
public func * (
  lhs: Measurement<UnitDuration>,
  rhs: Measurement<UnitMassFlowRate>
) -> Measurement<UnitMass> {
  rhs * lhs
}

/// How long `lhs` takes to flow at `rhs`, in the flow rate's own duration unit.
///
/// - Parameters:
///   - lhs: the mass to move.
///   - rhs: the flow rate.
/// - Returns: the time taken.
public func / (
  lhs: Measurement<UnitMass>,
  rhs: Measurement<UnitMassFlowRate>
) -> Measurement<UnitDuration> {
  let mass = lhs.converted(to: rhs.unit.numeratorUnit).value
  return .init(value: mass / rhs.value, unit: rhs.unit.denominatorUnit)
}

/// The mass flowing when `lhs` carries fluid of density `rhs`.
///
/// - Parameters:
///   - lhs: the volume flow rate.
///   - rhs: the fluid's density.
/// - Returns: the mass flow rate, in the density's mass unit per the flow rate's duration unit.
public func * (
  lhs: Measurement<UnitVolumetricFlowRate>,
  rhs: Measurement<UnitDensity>
) -> Measurement<UnitMassFlowRate> {
  let volume = Measurement(value: lhs.value, unit: lhs.unit.numeratorUnit)
    .converted(to: rhs.unit.denominatorUnit).value
  return .init(
    value: volume * rhs.value,
    unit: .init(mass: rhs.unit.numeratorUnit, per: lhs.unit.denominatorUnit)
  )
}

/// The mass flowing when `rhs` carries fluid of density `lhs`.
///
/// - Parameters:
///   - lhs: the fluid's density.
///   - rhs: the volume flow rate.
/// - Returns: the mass flow rate.
public func * (
  lhs: Measurement<UnitDensity>,
  rhs: Measurement<UnitVolumetricFlowRate>
) -> Measurement<UnitMassFlowRate> {
  rhs * lhs
}

/// The volume flowing when `lhs` carries fluid of density `rhs`.
///
/// - Parameters:
///   - lhs: the mass flow rate.
///   - rhs: the fluid's density.
/// - Returns: the volume flow rate, in the density's volume unit per the flow rate's duration unit.
public func / (
  lhs: Measurement<UnitMassFlowRate>,
  rhs: Measurement<UnitDensity>
) -> Measurement<UnitVolumetricFlowRate> {
  let mass = Measurement(value: lhs.value, unit: lhs.unit.numeratorUnit)
    .converted(to: rhs.unit.numeratorUnit).value
  return .init(
    value: mass / rhs.value,
    unit: .init(volume: rhs.unit.denominatorUnit, per: lhs.unit.denominatorUnit)
  )
}

// swiftlint:enable static_operator
