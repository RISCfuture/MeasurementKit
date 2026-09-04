public import Foundation

extension Measurement where UnitType == UnitDuration {
  /// The equivalent `Duration`, for the `Duration`-based format styles.
  public var duration: Duration { .seconds(converted(to: .seconds).value) }

  /// The equivalent `TimeInterval`, for the Foundation and Core Location APIs that take one.
  public var timeInterval: TimeInterval { converted(to: .seconds).value }
}

extension Duration {
  /// The equivalent measurement, in seconds.
  public var measurement: Measurement<UnitDuration> {
    let (seconds, attoseconds) = components
    return .init(
      value: Double(seconds) + Double(attoseconds) * 1e-18,
      unit: .seconds
    )
  }
}
