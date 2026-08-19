import Foundation

// Ohm's law and electrical power. These answer in their dimension's base unit — watts, volts,
// amperes, ohms, coulombs — since no coherent non-SI family of electrical units exists.
// swiftlint:disable static_operator

/// The power dissipated by `rhs` across `lhs`.
///
/// - Parameters:
///   - lhs: the potential difference.
///   - rhs: the current flowing.
/// - Returns: the power.
public func * (
  lhs: Measurement<UnitElectricPotentialDifference>,
  rhs: Measurement<UnitElectricCurrent>
) -> Measurement<UnitPower> {
  let value = lhs.converted(to: .volts).value * rhs.converted(to: .amperes).value
  return .init(value: value, unit: .watts)
}

/// The power dissipated by `lhs` across `rhs`.
///
/// - Parameters:
///   - lhs: the current flowing.
///   - rhs: the potential difference.
/// - Returns: the power.
public func * (
  lhs: Measurement<UnitElectricCurrent>,
  rhs: Measurement<UnitElectricPotentialDifference>
) -> Measurement<UnitPower> {
  rhs * lhs
}

/// The potential difference across which `lhs` is dissipated by `rhs`.
///
/// - Parameters:
///   - lhs: the power.
///   - rhs: the current flowing.
/// - Returns: the potential difference.
public func / (
  lhs: Measurement<UnitPower>,
  rhs: Measurement<UnitElectricCurrent>
) -> Measurement<UnitElectricPotentialDifference> {
  let value = lhs.converted(to: .watts).value / rhs.converted(to: .amperes).value
  return .init(value: value, unit: .volts)
}

/// The current that dissipates `lhs` across `rhs`.
///
/// - Parameters:
///   - lhs: the power.
///   - rhs: the potential difference.
/// - Returns: the current.
public func / (
  lhs: Measurement<UnitPower>,
  rhs: Measurement<UnitElectricPotentialDifference>
) -> Measurement<UnitElectricCurrent> {
  let value = lhs.converted(to: .watts).value / rhs.converted(to: .volts).value
  return .init(value: value, unit: .amperes)
}

/// The resistance that draws `rhs` under `lhs`.
///
/// - Parameters:
///   - lhs: the potential difference.
///   - rhs: the current it drives.
/// - Returns: the resistance.
public func / (
  lhs: Measurement<UnitElectricPotentialDifference>,
  rhs: Measurement<UnitElectricCurrent>
) -> Measurement<UnitElectricResistance> {
  let value = lhs.converted(to: .volts).value / rhs.converted(to: .amperes).value
  return .init(value: value, unit: .ohms)
}

/// The potential difference `lhs` develops across `rhs`.
///
/// - Parameters:
///   - lhs: the current.
///   - rhs: the resistance it flows through.
/// - Returns: the potential difference.
public func * (
  lhs: Measurement<UnitElectricCurrent>,
  rhs: Measurement<UnitElectricResistance>
) -> Measurement<UnitElectricPotentialDifference> {
  let value = lhs.converted(to: .amperes).value * rhs.converted(to: .ohms).value
  return .init(value: value, unit: .volts)
}

/// The potential difference `rhs` develops across `lhs`.
///
/// - Parameters:
///   - lhs: the resistance.
///   - rhs: the current flowing through it.
/// - Returns: the potential difference.
public func * (
  lhs: Measurement<UnitElectricResistance>,
  rhs: Measurement<UnitElectricCurrent>
) -> Measurement<UnitElectricPotentialDifference> {
  rhs * lhs
}

/// The current `lhs` drives through `rhs`.
///
/// - Parameters:
///   - lhs: the potential difference.
///   - rhs: the resistance.
/// - Returns: the current.
public func / (
  lhs: Measurement<UnitElectricPotentialDifference>,
  rhs: Measurement<UnitElectricResistance>
) -> Measurement<UnitElectricCurrent> {
  let value = lhs.converted(to: .volts).value / rhs.converted(to: .ohms).value
  return .init(value: value, unit: .amperes)
}

/// The charge `lhs` carries in `rhs`.
///
/// - Parameters:
///   - lhs: the current.
///   - rhs: how long it flowed.
/// - Returns: the charge.
public func * (
  lhs: Measurement<UnitElectricCurrent>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitElectricCharge> {
  let value = lhs.converted(to: .amperes).value * rhs.converted(to: .seconds).value
  return .init(value: value, unit: .coulombs)
}

/// The charge `rhs` carries in `lhs`.
///
/// - Parameters:
///   - lhs: the duration.
///   - rhs: the current flowing over it.
/// - Returns: the charge.
public func * (
  lhs: Measurement<UnitDuration>,
  rhs: Measurement<UnitElectricCurrent>
) -> Measurement<UnitElectricCharge> {
  rhs * lhs
}

/// The current that carries `lhs` in `rhs`.
///
/// - Parameters:
///   - lhs: the charge.
///   - rhs: the time it took.
/// - Returns: the current.
public func / (
  lhs: Measurement<UnitElectricCharge>,
  rhs: Measurement<UnitDuration>
) -> Measurement<UnitElectricCurrent> {
  let value = lhs.converted(to: .coulombs).value / rhs.converted(to: .seconds).value
  return .init(value: value, unit: .amperes)
}

/// How long `lhs` takes to pass at `rhs`.
///
/// - Parameters:
///   - lhs: the charge.
///   - rhs: the current.
/// - Returns: the time taken.
public func / (
  lhs: Measurement<UnitElectricCharge>,
  rhs: Measurement<UnitElectricCurrent>
) -> Measurement<UnitDuration> {
  let value = lhs.converted(to: .coulombs).value / rhs.converted(to: .amperes).value
  return .init(value: value, unit: .seconds)
}

// swiftlint:enable static_operator
