import Foundation

extension Double {
  /// This value rounded to a multiple of `step`.
  ///
  /// The standard library rounds only to an integral value, so rounding to hundreds goes through
  /// the step: divide, round, multiply back.
  ///
  /// - Parameters:
  ///   - step: the multiple to round to.
  ///   - rule: how to resolve a value falling between two multiples.
  /// - Returns: the multiple of `step` that `rule` selects.
  package func rounded(toMultipleOf step: Self, rule: FloatingPointRoundingRule) -> Self {
    (self / step).rounded(rule) * step
  }
}
