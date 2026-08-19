import Foundation
import Numerics
import Testing

@testable import MeasurementKit

@Suite("Date Arithmetic Tests")
struct DateArithmeticTests {

  private let epoch = Date(timeIntervalSince1970: 0)

  @Test("The time between two dates is a duration")
  func elapsedIsADuration() {
    let later = Date(timeIntervalSince1970: 90)

    let minutes = later.elapsed(since: epoch).converted(to: .minutes).value

    #expect(minutes.isApproximatelyEqual(to: 1.5, absoluteTolerance: 1e-12))
    #expect(epoch.elapsed(since: later).value < 0)
  }

  @Test("The time remaining is the elapsed time reversed")
  func remainingReversesElapsed() {
    let later = Date(timeIntervalSince1970: 90)

    #expect(epoch.remaining(until: later).value == later.elapsed(since: epoch).value)
  }

  @Test("A date advances and retards by a duration")
  func datesShiftByADuration() {
    let lookahead = Measurement(value: 2, unit: UnitDuration.minutes)

    #expect((epoch + lookahead).timeIntervalSince1970 == 120)
    #expect((epoch - lookahead).timeIntervalSince1970 == -120)
  }

  @Test("Shifting in place matches shifting by value")
  func inPlaceShiftMatches() {
    let lookahead = Measurement(value: 30, unit: UnitDuration.seconds)
    var advanced = epoch
    advanced += lookahead

    #expect(advanced == epoch + lookahead)
  }

  /// `Date + TimeInterval` has to keep resolving with the measurement overload in scope.
  @Test("Foundation's own date arithmetic still resolves")
  func foundationDateArithmeticSurvives() {
    #expect((epoch + 5.0).timeIntervalSince1970 == 5)
  }

  @Test("A duration measurement bridges to Duration and back")
  func durationBridges() {
    let measurement = Measurement(value: 90, unit: UnitDuration.seconds)

    #expect(measurement.timeInterval == 90)
    #expect(
      measurement.duration.measurement.value
        .isApproximatelyEqual(to: 90, absoluteTolerance: 1e-9)
    )
  }
}
