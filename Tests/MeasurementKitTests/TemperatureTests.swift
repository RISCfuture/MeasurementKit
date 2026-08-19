import Foundation
import Numerics
import Testing

@testable import MeasurementKit

@Suite("Temperature Tests")
struct TemperatureTests {

  /// A deviation and a reading are different quantities, and the type system is what keeps them
  /// apart: adding two readings converts through kelvin and answers a temperature nobody meant.
  @Test("A temperature shifted by a deviation stays on its own scale")
  func deviationShifts() {
    let standard = Measurement(value: 15, unit: UnitTemperature.celsius)
    let shifted = standard.deviated(by: .init(value: 10, unit: .celsius))

    #expect(shifted.value == 25)
    #expect(shifted.unit == .celsius)
  }

  @Test("A deviation carried onto another scale keeps its size")
  func deviationCrossesScales() {
    let standard = Measurement(value: 59, unit: UnitTemperature.fahrenheit)
    let shifted = standard.deviated(by: .init(value: 10, unit: .celsius))

    #expect(shifted.value.isApproximatelyEqual(to: 77, absoluteTolerance: 1e-9))
    #expect(shifted.unit == .fahrenheit)
  }

  @Test("The deviation between two temperatures is stated on the receiver's scale")
  func deviationBetweenTemperatures() {
    let observed = Measurement(value: 5, unit: UnitTemperature.celsius)
    let standard = Measurement(value: 15, unit: UnitTemperature.celsius)

    let deviation = observed.deviation(from: standard)

    #expect(deviation.value.isApproximatelyEqual(to: -10, absoluteTolerance: 1e-9))
    #expect(deviation.unit == .celsius)
  }

  @Test("A deviation round-trips through the temperature it came from")
  func deviationRoundTrips() {
    let observed = Measurement(value: -3, unit: UnitTemperature.celsius)
    let standard = Measurement(value: 15, unit: UnitTemperature.celsius)

    let restored = standard.deviated(by: observed.deviation(from: standard))

    #expect(restored.value.isApproximatelyEqual(to: -3, absoluteTolerance: 1e-9))
  }

  /// The ratio of two differences is unit-independent, which is the property that makes a
  /// difference a proportional quantity and a reading not one.
  @Test("The ratio of two deviations does not depend on the scale they are stated in")
  func deviationRatiosAreScaleFree() {
    let inCelsius =
      Measurement(value: 20, unit: UnitTemperatureDifference.celsius)
      / Measurement(value: 10, unit: UnitTemperatureDifference.celsius)
    let inFahrenheit =
      Measurement(value: 36, unit: UnitTemperatureDifference.fahrenheit)
      / Measurement(value: 18, unit: UnitTemperatureDifference.fahrenheit)

    #expect(inCelsius == 2)
    #expect(inFahrenheit == 2)
  }

  @Test("A Celsius degree and a kelvin are the same size")
  func celsiusAndKelvinAgree() {
    let tenCelsius = Measurement(value: 10, unit: UnitTemperatureDifference.celsius)

    #expect(
      tenCelsius.converted(to: .kelvin).value
        .isApproximatelyEqual(to: 10, absoluteTolerance: 1e-12)
    )
  }
}
