import Foundation

/**
 The north a bearing is measured from.

 A datum is a type, not a value: ``Bearing`` takes it as its type parameter, so the compiler knows
 which north every bearing in a calculation was measured from and rejects the mixtures that would
 otherwise have to be caught by a runtime check, or not at all.

 The protocol requires nothing but `Sendable` and an abbreviation. In particular it does not
 require `Codable`, which the datums could not satisfy: they are caseless enums, and a type with no
 values has nothing to decode into. ``Bearing`` carries the abbreviation into its own encoded form
 instead.
 */
public protocol BearingDatum: Sendable {
  /// The letter a bearing in this datum is suffixed with, as it appears on a chart — `T` or `M`.
  static var abbreviation: String { get }
}

/// Bearings measured from the geographic north pole, the datum charts and nav data are drawn in.
public enum True: BearingDatum {
  public static let abbreviation = "T"
}

/// Bearings measured from the local magnetic north, the datum a compass and a published runway
/// heading are stated in.
public enum Magnetic: BearingDatum {
  public static let abbreviation = "M"
}
