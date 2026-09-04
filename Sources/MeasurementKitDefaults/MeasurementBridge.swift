public import Defaults
public import Foundation
public import MeasurementKit

/**
 Stores a measurement as a bare number in its dimension's canonical unit.

 Serializing to a plain number keeps the preference legible in the defaults database and lets a
 value an earlier build wrote as an integer read straight back, since `UserDefaults` bridges either
 through the same `NSNumber`. Conversion happens only here, at the storage boundary, so a
 measurement handed over in any other unit is normalized on the way down rather than written under
 a key everything else reads as feet.
 */
public struct MeasurementBridge<UnitType>: Defaults.Bridge, Sendable
where UnitType: CanonicalUnit, UnitType.CanonicalDimension == UnitType {
  public typealias Value = Measurement<UnitType>
  public typealias Serializable = Double

  public init() {}

  public func serialize(_ value: Value?) -> Serializable? {
    value?.converted(to: .canonical).value
  }

  public func deserialize(_ object: Serializable?) -> Value? {
    object.map { Measurement(value: $0, unit: .canonical) }
  }
}

extension Measurement: @retroactive Defaults.Serializable
where UnitType: CanonicalUnit, UnitType.CanonicalDimension == UnitType {
  public static var bridge: MeasurementBridge<UnitType> { .init() }
}
