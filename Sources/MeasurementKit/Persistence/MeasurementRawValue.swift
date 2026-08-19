import Foundation

/**
 A measurement stored as its number and the identifier of its unit.

 `Measurement` is already `Codable`, and encodes its unit by symbol — the one thing a stored unit
 must never be. This is the same JSON one field further from Foundation's, and the field it does
 not share is the whole reason it exists.
 */
private struct StoredMeasurement: Codable {
  let value: Double
  let unit: UnitIdentifier
}

/**
 Storage of a measurement in `@AppStorage`, as JSON naming the value and its unit.

 `@AppStorage` stores a `RawRepresentable` whose `RawValue` is `String`, and a measurement that
 carries its own unit has to name that unit to come back as the same quantity. The unit is named by
 its ``MeasurementKit/UnitIdentifier``, never by its symbol.

 The conformance reaches only as far as the dimensions that asked for it. Claiming
 `RawRepresentable` for every `Measurement` would put a conformance to a protocol this package does
 not own, on a type it does not own, in front of every consumer — and `RawRepresentable` on
 `Measurement` is exactly what a competing persistence library would want to declare too, which is
 a collision no adopting app can resolve short of a fork. Conforming a dimension to
 ``MeasurementKit/UnitIdentifying`` is how an app opts its own measurements in, the same way it
 declares ``MeasurementKit/CanonicalUnit`` for the units it stores as bare numbers.

 Storing a measurement in a canonical unit is the other option, and the better one where it
 applies: a bare number reads back from a preference an earlier build wrote as a plain number and
 names no unit at all. Reach for this when the unit genuinely varies — when the reader chose it, or
 when the measurement arrives already carrying one.
 */
extension Measurement: @retroactive RawRepresentable
where UnitType: UnitIdentifying, UnitType.IdentifiedDimension == UnitType {
  public var rawValue: String {
    guard let identifier = UnitType.unitIdentifiers.first(where: { $0.value == unit })?.key else {
      preconditionFailure(
        "\(UnitType.self).unitIdentifiers does not name \(unit.symbol); a unit has to be in the "
          + "table to be stored"
      )
    }
    return Self.json(for: .init(value: value, unit: identifier))
  }

  public init?(rawValue: String) {
    guard let data = rawValue.data(using: .utf8),
      let stored = try? JSONDecoder().decode(StoredMeasurement.self, from: data),
      let unit = UnitType.unitIdentifiers[stored.unit]
    else { return nil }
    self.init(value: stored.value, unit: unit)
  }

  private static func json(for stored: StoredMeasurement) -> String {
    guard let data = try? JSONEncoder().encode(stored),
      let json = String(data: data, encoding: .utf8)
    else {
      preconditionFailure("A number and an identifier cannot fail to encode as UTF-8 JSON")
    }
    return json
  }
}
