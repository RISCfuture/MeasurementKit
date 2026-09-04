public import Foundation

extension Bearing where Datum == Magnetic {
  /// This bearing restated in true, by adding the local variation.
  ///
  /// - Parameter variation: the variation where the bearing was taken.
  /// - Returns: the same direction, measured from true north.
  public func toTrue(variation: MagneticVariation) -> TrueBearing {
    toTrue(variation: variation.angle)
  }

  /// This bearing restated in true, by adding the local variation.
  ///
  /// - Parameter variation: the angle from true north to magnetic north, positive east.
  /// - Returns: the same direction, measured from true north.
  public func toTrue(variation: Measurement<UnitAngle>) -> TrueBearing {
    .init(angle + variation)
  }
}

extension Bearing where Datum == True {
  /// This bearing restated in magnetic, by removing the local variation.
  ///
  /// - Parameter variation: the variation where the bearing was taken.
  /// - Returns: the same direction, measured from magnetic north.
  public func toMagnetic(variation: MagneticVariation) -> MagneticBearing {
    toMagnetic(variation: variation.angle)
  }

  /// This bearing restated in magnetic, by removing the local variation.
  ///
  /// - Parameter variation: the angle from true north to magnetic north, positive east.
  /// - Returns: the same direction, measured from magnetic north.
  public func toMagnetic(variation: Measurement<UnitAngle>) -> MagneticBearing {
    .init(angle - variation)
  }
}
