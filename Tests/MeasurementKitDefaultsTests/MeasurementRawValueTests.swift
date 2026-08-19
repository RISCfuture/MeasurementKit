import Foundation
import MeasurementKit
import Testing

@Suite("Measurement storage in AppStorage")
struct MeasurementRawValueTests {

  /// `@AppStorage` stores a `RawRepresentable` whose `RawValue` is a `String`, so a measurement
  /// that keeps its own unit has to carry the unit's identifier alongside the number.
  @Test("A measurement round-trips through its raw value carrying its unit")
  func rawValueRoundTrips() throws {
    let visibility = Measurement(value: 2.5, unit: UnitLength.nauticalMiles)
    let restored = try #require(Measurement<UnitLength>(rawValue: visibility.rawValue))

    #expect(restored == visibility)
    #expect(restored.unit == .nauticalMiles)
  }

  /// The conformance decides the format, not the registry: a length here is written `NM` because
  /// that is what the app's table says, where the table MeasurementKit registers for `UnitLength`
  /// says `nauticalMiles`. An app that declares one has declared the whole format.
  @Test("The dimension's own table names the unit, not the registry's")
  func conformanceDecidesTheFormat() {
    let raw = Measurement(value: 2.5, unit: UnitLength.nauticalMiles).rawValue

    #expect(raw.contains("NM"))
    #expect(!raw.contains("nauticalMiles"))
  }

  @Test("A raw value naming an unregistered unit restores nothing")
  func unknownUnitsFailToRestore() {
    #expect(Measurement<UnitLength>(rawValue: #"{"value":2.5,"unit":"furlongs"}"#) == nil)
    #expect(Measurement<UnitLength>(rawValue: "2.5 NM") == nil)
  }
}
