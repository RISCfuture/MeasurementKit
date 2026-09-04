public import CoreLocation
public import Foundation
import MeasurementKit

extension CLLocation {
  /// Where the fix is, as a ``Coordinate``.
  ///
  /// Named apart from `coordinate`, which Core Location already uses for its own
  /// `CLLocationCoordinate2D`.
  public var geoCoordinate: Coordinate { .init(coordinate) }

  /// The altitude above mean sea level.
  public var altitudeMSL: Measurement<UnitLength> { .init(value: altitude, unit: .meters) }

  /// How fast the fix is moving over the ground, or `nil` when the speed is unavailable.
  ///
  /// Zero is a real reading — an aircraft holding short is stopped, not unmeasured.
  public var groundSpeed: Measurement<UnitSpeed>? {
    speed.availableReading.map { .init(value: $0, unit: .metersPerSecond) }
  }

  /// The direction the fix is moving in, or `nil` when the course is unavailable.
  ///
  /// Core Location reports a course over the ground referenced to true north.
  public var courseTrue: TrueBearing? {
    course.availableReading.map { .init(degrees: $0) }
  }

  /// The radius of the horizontal uncertainty around the fix, or `nil` when the position is
  /// invalid.
  public var horizontalAccuracyDistance: Measurement<UnitLength>? {
    horizontalAccuracy.availableReading.map { .init(value: $0, unit: .meters) }
  }

  /// The vertical uncertainty of the altitude, or `nil` when the altitude is invalid.
  public var verticalAccuracyDistance: Measurement<UnitLength>? {
    verticalAccuracy.availableReading.map { .init(value: $0, unit: .meters) }
  }

  /// The uncertainty of the course, or `nil` when it is unavailable.
  public var courseAccuracyAngle: Measurement<UnitAngle>? {
    courseAccuracy.availableReading.map { .init(value: $0, unit: .degrees) }
  }

  /// The uncertainty of the speed, or `nil` when it is unavailable.
  public var speedAccuracyMeasurement: Measurement<UnitSpeed>? {
    speedAccuracy.availableReading.map { .init(value: $0, unit: .metersPerSecond) }
  }
}

extension CLLocationCoordinate2D {
  /// This location as a ``Coordinate``.
  public var geoCoordinate: Coordinate { .init(self) }

  /// This location as a Core Location coordinate.
  ///
  /// - Parameter coordinate: the location to convert.
  public init(_ coordinate: Coordinate) {
    self.init(latitude: coordinate.latitude.degrees, longitude: coordinate.longitude.degrees)
  }
}

extension Coordinate {
  /// This location as a Core Location coordinate.
  public var clCoordinate: CLLocationCoordinate2D { .init(self) }

  /// The Core Location coordinate `coordinate`, as a ``Coordinate``.
  ///
  /// - Parameter coordinate: the location to convert.
  public init(_ coordinate: CLLocationCoordinate2D) {
    self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }
}

// `CLHeading` exists only where there is a magnetometer to feed it.
#if os(iOS) || os(watchOS)
  extension CLHeading {
    /// Where the device points relative to magnetic north, or `nil` when the heading is
    /// unavailable.
    public var magneticBearing: MagneticBearing? {
      magneticHeading.availableReading.map { .init(degrees: $0) }
    }

    /// Where the device points relative to true north, or `nil` when the heading is unavailable —
    /// which it is until Core Location has a position to compute the local variation from.
    public var trueBearing: TrueBearing? {
      trueHeading.availableReading.map { .init(degrees: $0) }
    }
  }
#endif

extension Double {
  /**
   This value if Core Location measured it, or `nil` if it did not.

   Core Location signals an unavailable speed, course, heading, or accuracy with a negative
   sentinel rather than an optional. Taken at face value the sentinels are catastrophic in a
   navigation calculation: a speed of −1 m/s dead-reckons the aircraft backwards, and a course of
   −1° points one degree west of north. Zero passes through, because a stopped aircraft and a
   course of north are both real readings.
   */
  fileprivate var availableReading: Self? { self < 0 ? nil : self }
}
