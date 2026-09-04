public import Defaults
public import Foundation
import MeasurementKit

/**
 Stores a unit a reader chose by its registered identifier.

 The identifier is the point. A symbol is display text — Foundation may respell it between OS
 versions, it can be localized, and it is not unique across dimensions — so a preference that
 recorded one can stop matching, and a unit that stops matching quietly puts the reader back on a
 default they never picked. An identifier changes only when someone registers a new one.

 A dimension opts into storage by naming this bridge:

 ```swift
 extension UnitLength: Defaults.Serializable {
   public static var bridge: UnitBridge<UnitLength> { .init() }
 }
 ```

 - Important: `serialize` traps on a unit with no registered identifier, which is a wiring mistake
   the first run finds rather than anything a reader can cause. `deserialize` returns `nil` for an
   identifier that is no longer registered — a preference an older build wrote — which leaves
   `Defaults` to fall back to the key's default. Call
   `UnitIdentifierRegistry.unit(_:identifiedBy:)` directly where that fallback needs to be noticed
   instead of taken.
 */
public struct UnitBridge<UnitType: Dimension>: Defaults.Bridge, Sendable {
  public typealias Value = UnitType
  public typealias Serializable = String

  public init() {}

  public func serialize(_ value: Value?) -> Serializable? {
    guard let value else { return nil }
    guard let identifier = try? UnitIdentifierRegistry.identifier(for: value) else {
      preconditionFailure(
        "\(value.symbol) has no registered identifier; register \(UnitType.self) with "
          + "UnitIdentifierRegistry before storing it"
      )
    }
    return identifier.rawValue
  }

  public func deserialize(_ object: Serializable?) -> Value? {
    guard let object else { return nil }
    return try? UnitIdentifierRegistry.unit(UnitType.self, identifiedBy: .init(rawValue: object))
  }
}
