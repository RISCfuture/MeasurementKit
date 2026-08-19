import Foundation

/**
 A stable name a unit is stored under.

 Deliberately not `Unit.symbol`. A symbol is display text: Foundation is free to change it between
 OS versions, it can be localized, and it is not unique across dimensions — a slope written `m/m`
 and a length written `m` are one keystroke apart. A preference that records a symbol therefore
 records something that can stop matching, and a unit that stops matching quietly reverts the
 reader to a default they never chose.

 An identifier is owned by the package or the app that registers it, spelled the way the unit's
 property is spelled, and changed only by a deliberate migration.
 */
public struct UnitIdentifier: RawRepresentable, Hashable, Sendable, Codable,
  ExpressibleByStringLiteral, CustomStringConvertible
{
  public let rawValue: String

  public var description: String { rawValue }

  public init(rawValue: String) {
    self.rawValue = rawValue
  }

  public init(stringLiteral value: String) {
    self.init(rawValue: value)
  }
}

/**
 A dimension that names the units it can be stored under.

 The table is the dimension's storage format, written down once and complete at compile time.
 Conforming is what makes `Measurement` of that dimension storable in `@AppStorage`, and handing
 the type to ``MeasurementKit/UnitIdentifierRegistry`` registers the same table for the bridges in
 `MeasurementKitDefaults`.

 MeasurementKit conforms its own dimensions and no Foundation unit class, on the same reasoning as
 ``MeasurementKit/CanonicalUnit``: the conformance decides an adopting app's on-disk format, and a
 retroactive conformance to a type the package does not own would collide with any other library
 that declared the same one. Declare the ones your app needs, in your app. Foundation's common
 units are also registered by table, which is a conformance-free path for the code that can use it
 — see ``MeasurementKit/UnitIdentifierRegistry``.

 - Note: `IdentifiedDimension` stands in for `Self`, which a non-final class such as
   `Foundation.UnitLength` cannot satisfy in a static requirement. Conforming a final class of your
   own leaves the default alone; conforming a Foundation unit class means writing the type out.
 */
public protocol UnitIdentifying: Dimension {
  associatedtype IdentifiedDimension: Dimension = Self

  /// Every unit of this dimension that can be stored, keyed by the identifier it is stored under.
  static var unitIdentifiers: [UnitIdentifier: IdentifiedDimension] { get }
}

/// An error raised while translating between a unit and the identifier it is stored under.
public protocol UnitStorageError: LocalizedError {}

/// A unit and its identifier could not be matched up, because one of them was never registered.
public enum UnitIdentifierError: UnitStorageError {
  /// No unit of `dimension` is registered under `identifier`.
  case unknownIdentifier(UnitIdentifier, dimension: String)

  /// The unit `symbol` names is not registered under any identifier of `dimension`.
  case unregisteredUnit(symbol: String, dimension: String)

  public var errorDescription: String? {
    String(localized: "Couldn’t store or restore a unit.")
  }

  public var failureReason: String? {
    switch self {
      case let .unknownIdentifier(identifier, dimension):
        String(
          localized: "No \(dimension) is registered under the identifier “\(identifier.rawValue)”."
        )
      case let .unregisteredUnit(symbol, dimension):
        String(localized: "The \(dimension) “\(symbol)” has no registered identifier.")
    }
  }
}
