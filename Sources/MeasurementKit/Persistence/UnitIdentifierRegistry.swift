import Foundation
import Synchronization

/**
 The map between units and the identifiers they are stored under, one table per dimension.

 The registry is a runtime table rather than a protocol requirement so that a dimension the package
 does not own can still be stored: Foundation's unit classes are non-final, which puts a `Self`
 requirement out of reach, and a retroactive conformance on one would collide with any other
 library that declared the same one. MeasurementKit's own dimensions and Foundation's common ones
 are registered before the first lookup.

 An app adds its own dimensions, and overrides any entry it inherits, by registering a table of its
 own. Later registrations win, and earlier ones stay readable: registering `["ft": UnitLength.feet]`
 makes new writes say `ft` while a preference already holding `feet` still restores, which is how a
 change of identifier migrates without a migration pass.
 */
public enum UnitIdentifierRegistry {
  private static let tables = Mutex<[ObjectIdentifier: UnitTable]>(builtInUnitTables)

  /// Register a dimension that names its own units.
  ///
  /// - Parameter dimension: the dimension to register.
  public static func register<UnitType: UnitIdentifying>(_ dimension: UnitType.Type) {
    register(dimension.unitIdentifiers)
  }

  /**
   Register a table of units for the dimension they belong to.

   Use this for a dimension that cannot conform to ``MeasurementKit/UnitIdentifying`` — any of
   Foundation's, whose classes are not final — or to override identifiers already registered for
   one.

   - Parameter identifiers: the units to store, keyed by the identifier to store them under.
   */
  public static func register<UnitType: Dimension>(_ identifiers: [UnitIdentifier: UnitType]) {
    tables.withLock { $0[ObjectIdentifier(UnitType.self), default: .init()].insert(identifiers) }
  }

  /**
   The identifier a unit is stored under.

   - Parameter unit: the unit to look up.
   - Returns: the identifier most recently registered for `unit`.
   - Throws: ``MeasurementKit/UnitIdentifierError/unregisteredUnit(symbol:dimension:)`` if the
     unit's dimension was never registered, or was registered without this unit.
   - Note: the dimension comes from the static type of `unit`, so a unit held in a
     `Dimension`-typed variable has to be cast back to its own type to be found.
   */
  public static func identifier<UnitType: Dimension>(
    for unit: UnitType
  ) throws(UnitIdentifierError) -> UnitIdentifier {
    guard let identifier = table(for: UnitType.self)?.identifier(for: unit) else {
      throw .unregisteredUnit(symbol: unit.symbol, dimension: String(describing: UnitType.self))
    }
    return identifier
  }

  /**
   The unit an identifier was stored for.

   - Parameters:
     - dimension: the dimension the unit belongs to.
     - identifier: the identifier read back out of storage.
   - Returns: the unit registered under `identifier`.
   - Throws: ``MeasurementKit/UnitIdentifierError/unknownIdentifier(_:dimension:)`` if nothing is
     registered under it, which is what an identifier written by a build that has since renamed or
     dropped the unit looks like.
   */
  public static func unit<UnitType: Dimension>(
    _ dimension: UnitType.Type,
    identifiedBy identifier: UnitIdentifier
  ) throws(UnitIdentifierError) -> UnitType {
    guard let unit = table(for: dimension)?.unit(for: identifier) as? UnitType else {
      throw .unknownIdentifier(identifier, dimension: String(describing: dimension))
    }
    return unit
  }

  /// Keyed on the static type a unit was registered under, never on `type(of:)`: Foundation's
  /// unit singletons are instances of a private subclass — `UnitSpeed.knots` is really a
  /// `_NSStatic_NSUnitSpeed` — so a dynamic type never matches the class the table was filed
  /// under.
  private static func table<UnitType: Dimension>(for dimension: UnitType.Type) -> UnitTable? {
    tables.withLock { $0[ObjectIdentifier(dimension)] }
  }
}
