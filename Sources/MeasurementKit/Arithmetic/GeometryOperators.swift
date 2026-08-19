import Foundation

// swiftlint:disable static_operator

/// The area of a rectangle `lhs` by `rhs`, in the area unit matching the first length's unit.
///
/// - Parameters:
///   - lhs: one side.
///   - rhs: the other side.
/// - Returns: the area.
public func * (lhs: Measurement<UnitLength>, rhs: Measurement<UnitLength>) -> Measurement<UnitArea> {
  let unit = lhs.unit
  let other = rhs.converted(to: unit).value
  return .init(value: lhs.value * other, unit: unit.areaUnit)
}

/// The remaining side of a rectangle of area `lhs` with one side `rhs`, in the length unit matching
/// the area's unit.
///
/// - Parameters:
///   - lhs: the area.
///   - rhs: the known side.
/// - Returns: the other side.
public func / (
  lhs: Measurement<UnitArea>,
  rhs: Measurement<UnitLength>
) -> Measurement<UnitLength> {
  let unit = lhs.unit.lengthUnit
  let side = rhs.converted(to: unit).value
  return .init(value: lhs.converted(to: unit.areaUnit).value / side, unit: unit)
}

/// The volume of a prism of base `lhs` and height `rhs`, in the volume unit matching the area's
/// unit.
///
/// - Parameters:
///   - lhs: the base area.
///   - rhs: the height.
/// - Returns: the volume.
public func * (
  lhs: Measurement<UnitArea>,
  rhs: Measurement<UnitLength>
) -> Measurement<UnitVolume> {
  let lengthUnit = lhs.unit.lengthUnit
  let base = lhs.converted(to: lengthUnit.areaUnit).value
  let height = rhs.converted(to: lengthUnit).value
  return .init(value: base * height, unit: lengthUnit.volumeUnit)
}

/// The volume of a prism of height `lhs` and base `rhs`.
///
/// - Parameters:
///   - lhs: the height.
///   - rhs: the base area.
/// - Returns: the volume.
public func * (
  lhs: Measurement<UnitLength>,
  rhs: Measurement<UnitArea>
) -> Measurement<UnitVolume> {
  rhs * lhs
}

/// The height of a prism of volume `lhs` on base `rhs`, in the length unit matching the volume's
/// unit.
///
/// - Parameters:
///   - lhs: the volume.
///   - rhs: the base area.
/// - Returns: the height.
public func / (
  lhs: Measurement<UnitVolume>,
  rhs: Measurement<UnitArea>
) -> Measurement<UnitLength> {
  let lengthUnit = lhs.unit.lengthUnit
  let volume = lhs.value
  let base = rhs.converted(to: lengthUnit.areaUnit).value
  return .init(value: volume / base, unit: lengthUnit)
}

/// The base of a prism of volume `lhs` and height `rhs`, in the area unit matching the volume's
/// unit.
///
/// - Parameters:
///   - lhs: the volume.
///   - rhs: the height.
/// - Returns: the base area.
public func / (
  lhs: Measurement<UnitVolume>,
  rhs: Measurement<UnitLength>
) -> Measurement<UnitArea> {
  let lengthUnit = lhs.unit.lengthUnit
  let height = rhs.converted(to: lengthUnit).value
  return .init(value: lhs.value / height, unit: lengthUnit.areaUnit)
}

// swiftlint:enable static_operator
