import Foundation
import MeasurementKitDefaults
import Testing

@Suite
struct `Measurement storage` {

  /// Measurements are stored as bare numbers, so preferences written before they became
  /// measurements have to keep reading back as the same quantity.
  @Test
  func `A measurement stored as a bare number reads back in its canonical unit`() throws {
    let runway = try #require(MeasurementBridge<UnitLength>().deserialize(3000))
    #expect(runway == Measurement(value: 3000, unit: .feet))

    let wind = try #require(MeasurementBridge<UnitSpeed>().deserialize(15))
    #expect(wind == Measurement(value: 15, unit: .knots))
  }

  /// Storing the raw value without converting first would write, say, a count of meters under a
  /// key everything else reads as feet, so the unit has to be normalized on the way down rather
  /// than assumed.
  @Test
  func `A measurement in another unit is normalized before it is stored`() throws {
    let runway = try #require(
      MeasurementBridge<UnitLength>().serialize(Measurement(value: 1, unit: .miles))
    )
    #expect(abs(runway - 5280) < 1e-9)

    let wind = try #require(
      MeasurementBridge<UnitSpeed>().serialize(Measurement(value: 1, unit: .milesPerHour))
    )
    #expect(abs(wind - 0.868976) < 1e-6)
  }
}
