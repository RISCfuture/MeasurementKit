import Foundation

/**
 A dimension an app expresses in a single unit everywhere it stores one.

 Some dimensions have a unit that is fixed by the domain rather than by the reader: aviation flies
 knots and feet worldwide, so every altitude an aviation app persists is a number of feet whatever
 the reader's locale says. Pinning that unit to the dimension lets a measurement be stored as the
 bare number a preference already holds, and lets a measurement arriving in any other unit be
 normalized on its way down to storage.

 The bare number is the point. A preference an earlier build wrote as `3000`, before the value
 became a `Measurement` at all, reads straight back as three thousand feet — `UserDefaults` bridges
 an integer and a double through the same `NSNumber`, so no migration stands between the two
 formats.

 MeasurementKit conforms none of Foundation's unit classes to this protocol, and neither should any
 other library. The conformance decides an app's on-disk format: shipping one would silently change
 what an adopting app's existing preferences mean, and a retroactive conformance to a type the
 package does not own would collide with any other library that declared the same one. Declare the
 conformances your app needs, in your app, in one file.

 - Note: `CanonicalDimension` stands in for `Self`, which a non-final class such as
   `Foundation.UnitSpeed` cannot satisfy in a static requirement. Conforming a final class of your
   own leaves the default alone; conforming a Foundation unit class means writing the type out.
 */
public protocol CanonicalUnit: Dimension {
  associatedtype CanonicalDimension: Dimension = Self

  /// The unit this app stores and displays every measurement of this dimension in.
  static var canonical: CanonicalDimension { get }
}
