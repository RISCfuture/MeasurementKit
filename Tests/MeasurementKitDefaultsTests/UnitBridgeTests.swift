import Foundation
import MeasurementKit
import MeasurementKitDefaults
import Testing

@Suite
struct `Chosen unit storage` {

  @Test
  func `A chosen unit round-trips through its identifier`() throws {
    let bridge = UnitBridge<UnitSpeed>()
    let stored = try #require(bridge.serialize(.knots))
    #expect(try #require(bridge.deserialize(stored)) == .knots)

    let slope = UnitBridge<UnitSlope>()
    let storedSlope = try #require(slope.serialize(.feetPerNauticalMile))
    #expect(try #require(slope.deserialize(storedSlope)) == .feetPerNauticalMile)
  }

  /// The identifier is what is written to disk, and a symbol Foundation is free to respell — `kn`
  /// one release and `kt` the next — is exactly what it must not be.
  @Test
  func `A unit is stored under its identifier and not its symbol`() throws {
    #expect(try #require(UnitBridge<UnitSpeed>().serialize(.knots)) == "knots")
    #expect(UnitSpeed.knots.symbol != "knots")

    #expect(try #require(UnitBridge<UnitSlope>().serialize(.ratio)) == "ratio")
    #expect(UnitSlope.ratio.symbol == "m/m")
  }

  /// A build that renames or drops a unit leaves preferences naming one that no longer resolves.
  /// The bridge can only answer `nil`, which `Defaults` turns into the key's default silently, so
  /// the registry has to be reachable directly for a caller that needs to notice.
  @Test
  func `An identifier nothing is registered under is reported rather than swallowed`() {
    #expect(UnitBridge<UnitLength>().deserialize("furlongs") == nil)

    #expect(throws: UnitIdentifierError.self) {
      try UnitIdentifierRegistry.unit(UnitLength.self, identifiedBy: "furlongs")
    }
  }

  /// Registering a table for a dimension that already has one is how an app renames an identifier:
  /// new writes take the new spelling, and preferences holding the old one still restore.
  @Test
  func `A re-registered unit takes the newer identifier and keeps reading the older one`() throws {
    UnitIdentifierRegistry.register(["old": UnitTestQuantity.units])
    UnitIdentifierRegistry.register(["new": UnitTestQuantity.units])

    #expect(try UnitIdentifierRegistry.identifier(for: UnitTestQuantity.units) == "new")
    #expect(try UnitIdentifierRegistry.unit(UnitTestQuantity.self, identifiedBy: "old") == .units)
  }
}
