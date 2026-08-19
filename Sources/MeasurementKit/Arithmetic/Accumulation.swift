import Foundation

extension Measurement where UnitType: Dimension {
  /**
   Zero, in the dimension's base unit.

   Comparison converts, so this is a valid zero to test any measurement of the dimension against —
   `descentRate < .zero` reads correctly whether the rate is in feet per minute or metres per
   second.

   It is the wrong seed for a running total. Foundation's `+` keeps the left operand's unit only
   when both units are identical and falls back to the base unit otherwise, so a total seeded with
   a base-unit zero silently becomes metres the first time a distance in feet is added to it. Seed
   with ``zero(in:)``, or total a sequence with ``Swift/Sequence/sum(in:)``.
   */
  public static var zero: Self { .init(value: 0, unit: .baseUnit()) }

  /// Zero, in `unit` — the seed for a running total that should stay in that unit.
  ///
  /// - Parameter unit: the unit the total is kept in.
  /// - Returns: zero, wearing `unit`.
  public static func zero(in unit: UnitType) -> Self { .init(value: 0, unit: unit) }

  /**
   This measurement plus `other`, kept in this measurement's unit.

   Foundation's `+` answers in the base unit whenever the two units differ. This answers in the
   receiver's, which is what a running total wants: the total of a flight plan's legs stays in the
   unit the first leg was written in.

   - Parameter other: the measurement to add.
   - Returns: the sum, in this measurement's unit.
   */
  public func adding(_ other: Self) -> Self {
    .init(value: value + other.converted(to: unit).value, unit: unit)
  }

  /// This measurement less `other`, kept in this measurement's unit.
  ///
  /// - Parameter other: the measurement to subtract.
  /// - Returns: the difference, in this measurement's unit.
  public func subtracting(_ other: Self) -> Self {
    .init(value: value - other.converted(to: unit).value, unit: unit)
  }
}

extension Sequence {
  /**
   The total of these measurements, in `unit`.

   Every element converts into `unit` before it is added, so the total neither drifts into the base
   unit the way a `reduce(.zero, +)` does, nor depends on the order the elements arrive in.

   - Parameter unit: the unit to total in.
   - Returns: the sum, wearing `unit`; zero for an empty sequence.
   */
  public func sum<UnitType: Dimension>(
    in unit: UnitType
  ) -> Measurement<UnitType> where Element == Measurement<UnitType> {
    .init(value: reduce(0) { $0 + $1.converted(to: unit).value }, unit: unit)
  }
}
