public import Foundation

extension Date {
  /// The date `duration` after `date`.
  ///
  /// - Parameters:
  ///   - date: the starting date.
  ///   - duration: how long after it.
  /// - Returns: the later date.
  public static func + (date: Self, duration: Measurement<UnitDuration>) -> Self {
    date.addingTimeInterval(duration.timeInterval)
  }

  /// The date `duration` before `date`.
  ///
  /// - Parameters:
  ///   - date: the starting date.
  ///   - duration: how long before it.
  /// - Returns: the earlier date.
  public static func - (date: Self, duration: Measurement<UnitDuration>) -> Self {
    date.addingTimeInterval(-duration.timeInterval)
  }

  /// Advances `date` by `duration`.
  ///
  /// - Parameters:
  ///   - date: the date to advance.
  ///   - duration: how far to advance it.
  public static func += (date: inout Self, duration: Measurement<UnitDuration>) {
    date = date + duration
  }

  /// Retards `date` by `duration`.
  ///
  /// - Parameters:
  ///   - date: the date to retard.
  ///   - duration: how far to retard it.
  public static func -= (date: inout Self, duration: Measurement<UnitDuration>) {
    date = date - duration
  }

  /**
   The time from `other` to this date, negative when this date precedes it.

   Spelled as a method rather than as a subtraction operator: `Date - Date` is a name that
   `TimeInterval`, `Duration` and a duration measurement all have an equal claim on, and a library
   that takes it makes every subtraction of two dates in its consumers ambiguous.

   - Parameter other: the earlier date.
   - Returns: the elapsed time, in seconds.
   */
  public func elapsed(since other: Self) -> Measurement<UnitDuration> {
    .init(value: timeIntervalSince(other), unit: .seconds)
  }

  /// The time from this date until `other`, negative when `other` has passed.
  ///
  /// - Parameter other: the later date.
  /// - Returns: the remaining time, in seconds.
  public func remaining(until other: Self) -> Measurement<UnitDuration> {
    .init(value: other.timeIntervalSince(self), unit: .seconds)
  }
}
