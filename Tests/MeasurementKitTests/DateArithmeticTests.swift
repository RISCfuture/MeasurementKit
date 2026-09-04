import Foundation
import Numerics
import Testing

@testable import MeasurementKit

@Suite
struct `Date Arithmetic Tests` {

  private let epoch = Date(timeIntervalSince1970: 0)

  @Test
  func `The time between two dates is a duration`() {
    let later = Date(timeIntervalSince1970: 90)

    let minutes = later.elapsed(since: epoch).converted(to: .minutes).value

    #expect(minutes.isApproximatelyEqual(to: 1.5, absoluteTolerance: 1e-12))
    #expect(epoch.elapsed(since: later).value < 0)
  }

  @Test
  func `The time remaining is the elapsed time reversed`() {
    let later = Date(timeIntervalSince1970: 90)

    #expect(epoch.remaining(until: later).value == later.elapsed(since: epoch).value)
  }

  @Test
  func `A date advances and retards by a duration`() {
    let lookahead = Measurement(value: 2, unit: UnitDuration.minutes)

    #expect((epoch + lookahead).timeIntervalSince1970 == 120)
    #expect((epoch - lookahead).timeIntervalSince1970 == -120)
  }

  @Test
  func `Shifting in place matches shifting by value`() {
    let lookahead = Measurement(value: 30, unit: UnitDuration.seconds)
    var advanced = epoch
    advanced += lookahead

    #expect(advanced == epoch + lookahead)
  }

  /// `Date + TimeInterval` has to keep resolving with the measurement overload in scope.
  @Test
  func `Foundation's own date arithmetic still resolves`() {
    #expect((epoch + 5.0).timeIntervalSince1970 == 5)
  }

  @Test
  func `A duration measurement bridges to Duration and back`() {
    let measurement = Measurement(value: 90, unit: UnitDuration.seconds)

    #expect(measurement.timeInterval == 90)
    #expect(
      measurement.duration.measurement.value
        .isApproximatelyEqual(to: 90, absoluteTolerance: 1e-9)
    )
  }
}
