import Foundation

extension Measurement where UnitType: Dimension {
  /**
   This measurement rounded to a multiple of `step`, in this measurement's unit.

   - Parameters:
     - step: the multiple to round to, such as a hundred feet to round to whole hundreds.
     - rule: how to resolve a measurement falling between two multiples; defaults to the same rule
       as `rounded()`.
   - Returns: the multiple of `step` that `rule` selects.
   */
  public func rounded(
    toMultipleOf step: Self,
    rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero
  ) -> Self {
    .init(
      value: value.rounded(toMultipleOf: step.converted(to: unit).value, rule: rule),
      unit: unit
    )
  }

  /**
   This measurement pinned to `range`: the nearer bound when it falls outside, and itself when it
   does not.

   - Parameter range: the range to pin to.
   - Returns: a measurement `range` contains, in this measurement's unit.
   */
  public func clamped(to range: ClosedRange<Self>) -> Self {
    if self < range.lowerBound { return range.lowerBound.converted(to: unit) }
    if self > range.upperBound { return range.upperBound.converted(to: unit) }
    return self
  }
}
