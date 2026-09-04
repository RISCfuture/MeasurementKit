public import Foundation

extension UnitTemperature {
  /**
   The unit a difference between two temperatures on this scale is stated in.

   A reading and a difference between two readings are different quantities — 10 °C is a point on
   an interval scale, ten Celsius degrees is an interval — so the two have separate types, and this
   is the mapping between them. An app that reports a lapse rate, an ISA deviation, or any other
   difference beside a reading takes the difference's unit from the reading's own unit through
   here, rather than assuming Celsius beside a Fahrenheit display.

   Celsius answers for every scale whose degree is a kelvin, which is every one Foundation defines
   but Fahrenheit and Kelvin themselves.
   */
  public var differenceUnit: UnitTemperatureDifference {
    switch self {
      case .fahrenheit: .fahrenheit
      case .kelvin: .kelvin
      default: .celsius
    }
  }
}

extension Measurement where UnitType == UnitTemperature {
  /**
   This temperature shifted by a deviation from it.

   - Parameter deviation: how far from this temperature the result stands.
   - Returns: the shifted temperature, in this temperature's unit.
   */
  public func deviated(by deviation: Measurement<UnitTemperatureDifference>) -> Self {
    .init(
      value: value + deviation.converted(to: unit.differenceUnit).value,
      unit: unit
    )
  }

  /**
   How far this temperature stands from `reference`.

   - Parameter reference: the temperature to measure from, typically the standard temperature at an
     altitude.
   - Returns: the signed difference, stated on this temperature's own scale.
   */
  public func deviation(from reference: Self) -> Measurement<UnitTemperatureDifference> {
    let kelvins = converted(to: .kelvin).value - reference.converted(to: .kelvin).value
    return Measurement<UnitTemperatureDifference>(value: kelvins, unit: .kelvin)
      .converted(to: unit.differenceUnit)
  }
}
