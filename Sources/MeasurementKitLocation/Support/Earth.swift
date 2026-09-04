public import Foundation

/// Constants describing the sphere this module's geodesy is computed on.
///
/// The great-circle formulas treat the Earth as a sphere. That is accurate to roughly 0.3% against
/// an ellipsoidal solution — well inside what a navigation display needs, and a few orders of
/// magnitude simpler. Reach for a geodesic library where survey accuracy matters.
public enum Earth {
  /// The IUGG mean radius of the Earth, 6 371 008.8 m.
  ///
  /// The radius of the sphere with the same volume as the WGS 84 ellipsoid, which is the sphere
  /// that minimizes the error of the great-circle formulas over the whole globe.
  public static let meanRadius = Measurement(value: 6_371_008.8, unit: UnitLength.meters)
}
