public import Foundation

// Except where a companion unit is named, these relations answer in their dimension's base unit —
// newtons, joules, watts, pascals. Unlike the kinematic units there is no coherent imperial family
// to stay inside, so converting to SI is what keeps the arithmetic exact.
// swiftlint:disable static_operator

/// The force `lhs` exerts under `rhs`, in the force unit matching the mass's unit.
///
/// A mass in pounds under one gravity weighs the same number of pounds-force.
///
/// - Parameters:
///   - lhs: the mass.
///   - rhs: the acceleration it is under.
/// - Returns: the force.
public func * (
  lhs: Measurement<UnitMass>,
  rhs: Measurement<UnitAcceleration>
) -> Measurement<UnitForce> {
  let newtons =
    lhs.converted(to: .kilograms).value * rhs.converted(to: .metersPerSecondSquared).value
  return Measurement(value: newtons, unit: UnitForce.newtons).converted(to: lhs.unit.forceUnit)
}

/// The force `rhs` exerts under `lhs`.
///
/// - Parameters:
///   - lhs: the acceleration.
///   - rhs: the mass under it.
/// - Returns: the force.
public func * (
  lhs: Measurement<UnitAcceleration>,
  rhs: Measurement<UnitMass>
) -> Measurement<UnitForce> {
  rhs * lhs
}

/// The acceleration `lhs` imparts to `rhs`.
///
/// - Parameters:
///   - lhs: the force applied.
///   - rhs: the mass it acts on.
/// - Returns: the acceleration.
public func / (
  lhs: Measurement<UnitForce>,
  rhs: Measurement<UnitMass>
) -> Measurement<UnitAcceleration> {
  let value = lhs.converted(to: .newtons).value / rhs.converted(to: .kilograms).value
  return .init(value: value, unit: .metersPerSecondSquared)
}

/// The mass `lhs` accelerates at `rhs`, in the mass unit matching the force's unit.
///
/// - Parameters:
///   - lhs: the force applied.
///   - rhs: the acceleration observed.
/// - Returns: the mass.
public func / (
  lhs: Measurement<UnitForce>,
  rhs: Measurement<UnitAcceleration>
) -> Measurement<UnitMass> {
  let kilograms =
    lhs.converted(to: .newtons).value / rhs.converted(to: .metersPerSecondSquared).value
  return Measurement(value: kilograms, unit: UnitMass.kilograms).converted(to: lhs.unit.massUnit)
}

/// The force `lhs` exerts over `rhs`.
///
/// - Parameters:
///   - lhs: the pressure.
///   - rhs: the area it acts over.
/// - Returns: the force.
public func * (
  lhs: Measurement<UnitPressure>,
  rhs: Measurement<UnitArea>
) -> Measurement<UnitForce> {
  let value =
    lhs.converted(to: .newtonsPerMetersSquared).value * rhs.converted(to: .squareMeters).value
  return .init(value: value, unit: .newtons)
}

/// The force `rhs` exerts over `lhs`.
///
/// - Parameters:
///   - lhs: the area.
///   - rhs: the pressure acting over it.
/// - Returns: the force.
public func * (
  lhs: Measurement<UnitArea>,
  rhs: Measurement<UnitPressure>
) -> Measurement<UnitForce> {
  rhs * lhs
}

/// The pressure `lhs` exerts over `rhs`.
///
/// - Parameters:
///   - lhs: the force.
///   - rhs: the area it is spread over.
/// - Returns: the pressure.
public func / (
  lhs: Measurement<UnitForce>,
  rhs: Measurement<UnitArea>
) -> Measurement<UnitPressure> {
  let value = lhs.converted(to: .newtons).value / rhs.converted(to: .squareMeters).value
  return .init(value: value, unit: .newtonsPerMetersSquared)
}

/// The area over which `lhs` exerts `rhs`.
///
/// - Parameters:
///   - lhs: the force.
///   - rhs: the pressure it produces.
/// - Returns: the area.
public func / (
  lhs: Measurement<UnitForce>,
  rhs: Measurement<UnitPressure>
) -> Measurement<UnitArea> {
  let value =
    lhs.converted(to: .newtons).value / rhs.converted(to: .newtonsPerMetersSquared).value
  return .init(value: value, unit: .squareMeters)
}

/// The work `lhs` does over `rhs`.
///
/// - Parameters:
///   - lhs: the force applied.
///   - rhs: the distance it acts through.
/// - Returns: the work done.
public func * (
  lhs: Measurement<UnitForce>,
  rhs: Measurement<UnitLength>
) -> Measurement<UnitEnergy> {
  let value = lhs.converted(to: .newtons).value * rhs.converted(to: .meters).value
  return .init(value: value, unit: .joules)
}

/// The work `rhs` does over `lhs`.
///
/// - Parameters:
///   - lhs: the distance.
///   - rhs: the force acting through it.
/// - Returns: the work done.
public func * (
  lhs: Measurement<UnitLength>,
  rhs: Measurement<UnitForce>
) -> Measurement<UnitEnergy> {
  rhs * lhs
}

/// The force that does `lhs` over `rhs`.
///
/// - Parameters:
///   - lhs: the work done.
///   - rhs: the distance it was done over.
/// - Returns: the force.
public func / (
  lhs: Measurement<UnitEnergy>,
  rhs: Measurement<UnitLength>
) -> Measurement<UnitForce> {
  let value = lhs.converted(to: .joules).value / rhs.converted(to: .meters).value
  return .init(value: value, unit: .newtons)
}

/// The energy `lhs` delivers in `rhs`.
///
/// - Parameters:
///   - lhs: the power.
///   - rhs: how long it was delivered.
/// - Returns: the energy.
public func * (
  lhs: Measurement<UnitPower>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitEnergy> {
  let value = lhs.converted(to: .watts).value * rhs.converted(to: .seconds).value
  return .init(value: value, unit: .joules)
}

/// The energy `rhs` delivers in `lhs`.
///
/// - Parameters:
///   - lhs: the duration.
///   - rhs: the power delivered over it.
/// - Returns: the energy.
public func * (
  lhs: Measurement<UnitDuration>,
  rhs: Measurement<UnitPower>
) -> Measurement<UnitEnergy> {
  rhs * lhs
}

/// The power that delivers `lhs` in `rhs`.
///
/// - Parameters:
///   - lhs: the energy.
///   - rhs: the time it was delivered in.
/// - Returns: the power.
public func / (
  lhs: Measurement<UnitEnergy>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitPower> {
  let value = lhs.converted(to: .joules).value / rhs.converted(to: .seconds).value
  return .init(value: value, unit: .watts)
}

/// How long `lhs` lasts at `rhs`.
///
/// - Parameters:
///   - lhs: the energy available.
///   - rhs: the power drawn.
/// - Returns: the time it lasts.
public func / (
  lhs: Measurement<UnitEnergy>,
  rhs: Measurement<UnitPower>
) -> Measurement<UnitDuration> {
  let value = lhs.converted(to: .joules).value / rhs.converted(to: .watts).value
  return .init(value: value, unit: .seconds)
}

/// The power `lhs` develops at `rhs` — a thrust moving through the air.
///
/// - Parameters:
///   - lhs: the force.
///   - rhs: the speed it acts at.
/// - Returns: the power.
public func * (
  lhs: Measurement<UnitForce>,
  rhs: Measurement<UnitSpeed>
) -> Measurement<UnitPower> {
  let value = lhs.converted(to: .newtons).value * rhs.converted(to: .metersPerSecond).value
  return .init(value: value, unit: .watts)
}

/// The power `rhs` develops at `lhs`.
///
/// - Parameters:
///   - lhs: the speed.
///   - rhs: the force acting at it.
/// - Returns: the power.
public func * (
  lhs: Measurement<UnitSpeed>,
  rhs: Measurement<UnitForce>
) -> Measurement<UnitPower> {
  rhs * lhs
}

/// The force `lhs` produces at `rhs`.
///
/// - Parameters:
///   - lhs: the power.
///   - rhs: the speed it is delivered at.
/// - Returns: the force.
public func / (
  lhs: Measurement<UnitPower>,
  rhs: Measurement<UnitSpeed>
) -> Measurement<UnitForce> {
  let value = lhs.converted(to: .watts).value / rhs.converted(to: .metersPerSecond).value
  return .init(value: value, unit: .newtons)
}

// swiftlint:enable static_operator
