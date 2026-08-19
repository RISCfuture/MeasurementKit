import Foundation
import MeasurementKit

/**
 The conformances an adopting app declares for itself, standing in for one here.

 MeasurementKit ships none of these for Foundation's unit classes, so a test that exercises the
 storage path has to choose units the way an adopter would: feet for lengths, knots for speeds.
 The identifiers are spelled the way a preference file older than this package would already have
 spelled them, which is the adopter's decision and not the package's.
 */
extension UnitLength: CanonicalUnit {
  public static var canonical: UnitLength { .feet }
}

extension UnitSpeed: CanonicalUnit {
  public static var canonical: UnitSpeed { .knots }
}

extension UnitLength: UnitIdentifying {
  public static var unitIdentifiers: [UnitIdentifier: UnitLength] {
    [
      "ft": .feet,
      "m": .meters,
      "NM": .nauticalMiles,
      "mi": .miles
    ]
  }
}

/// A dimension no other test registers, so a test can rewrite its identifiers in isolation.
final class UnitTestQuantity: Dimension, @unchecked Sendable {
  static let units = UnitTestQuantity(symbol: "u", converter: UnitConverterLinear(coefficient: 1))

  override static func baseUnit() -> UnitTestQuantity { .units }
}
