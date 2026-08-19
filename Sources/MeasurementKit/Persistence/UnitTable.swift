import Foundation

/**
 One dimension's units, newest registration first.

 A unit is immutable once built — its symbol and converter never change — so a table of them
 crosses isolation boundaries safely, which `Unit` itself is too old to promise.
 */
struct UnitTable: @unchecked Sendable {
  private var entries: [(identifier: UnitIdentifier, unit: Unit)] = []

  func identifier(for unit: Unit) -> UnitIdentifier? {
    entries.first { $0.unit == unit }?.identifier
  }

  func unit(for identifier: UnitIdentifier) -> Unit? {
    entries.first { $0.identifier == identifier }?.unit
  }

  mutating func insert(_ identifiers: [UnitIdentifier: some Unit]) {
    entries = identifiers.map { ($0.key, $0.value as Unit) } + entries
  }
}
