public import Foundation
import MeasurementKit

/**
 The shortest route between two points on the Earth — a course line, and the questions asked of one
 in flight.

 ``crossTrackDistance(to:)`` says how far off course a position is and which side it is on,
 ``alongTrackDistance(to:)`` how far down the route it has come, and ``closestPoint(to:)`` where on
 the route it is abeam of. Together they are the arithmetic behind a course deviation indicator.
 */
public struct GreatCircleSegment: Hashable, Codable, Sendable, CustomStringConvertible {
  /// Where the route begins.
  public let start: Coordinate

  /// Where the route ends.
  public let end: Coordinate

  /// How long the route is.
  public var length: Measurement<UnitLength> { start.distance(to: end) }

  /// The bearing to depart ``start`` on.
  public var initialBearing: TrueBearing { start.initialBearing(to: end) }

  /// The bearing the route arrives at ``end`` on.
  public var finalBearing: TrueBearing { start.finalBearing(to: end) }

  public var description: String { "\(start) → \(end)" }

  /// The route from `start` to `end`.
  ///
  /// - Parameters:
  ///   - start: where the route begins.
  ///   - end: where the route ends.
  public init(from start: Coordinate, to end: Coordinate) {
    self.start = start
    self.end = end
  }

  /**
   How far `position` lies off the course line, and on which side.

   The sign is the one a course deviation indicator needs: **positive means `position` is to the
   right of the course**, negative to the left, as seen by someone flying from ``start`` toward
   ``end``. A positive deviation is therefore corrected by turning left.

   The distance is measured to the great circle the segment lies on, not to the segment, so a
   position beyond either end still reports its perpendicular offset from the extended course line.

   - Parameter position: the point to measure.
   - Returns: the perpendicular distance to the course line, signed.
   */
  public func crossTrackDistance(to position: Coordinate) -> Measurement<UnitLength> {
    Earth.meanRadius * asin(sin(angularDistance(to: position)) * sin(relativeBearing(of: position)))
  }

  /**
   How far down the course line `position` lies — the distance from ``start`` to the point on the
   course that `position` is abeam of.

   Negative when `position` is behind ``start``, and greater than ``length`` when it is beyond
   ``end``.

   - Parameter position: the point to measure.
   - Returns: the distance along the course line, signed.
   */
  public func alongTrackDistance(to position: Coordinate) -> Measurement<UnitLength> {
    let straightAhead = angularDistance(to: position)
    let offCourse = crossTrackDistance(to: position) / Earth.meanRadius
    let travelled = acos((cos(straightAhead) / cos(offCourse)).clampedToCosineRange)
    return Earth.meanRadius * travelled * sign(of: position)
  }

  /**
   The point on the route that `position` is abeam of.

   Held to the segment: a position behind ``start`` or beyond ``end`` answers that end rather than
   a point on the extended great circle, so the result is always somewhere the route actually goes.

   - Parameter position: the point to measure from.
   - Returns: the nearest point on the route.
   */
  public func closestPoint(to position: Coordinate) -> Coordinate {
    let travelled = alongTrackDistance(to: position).clamped(to: .zero...length)
    return start.offset(bearing: initialBearing, distance: travelled)
  }

  /// The angle `position` subtends with ``start`` at the centre of the Earth, in radians.
  private func angularDistance(to position: Coordinate) -> Double {
    start.angularDistance(to: position)
  }

  /// The angle from the course line to `position` as seen from ``start``, in radians.
  private func relativeBearing(of position: Coordinate) -> Double {
    (start.initialBearing(to: position) - initialBearing).radians
  }

  /// Which way along the course `position` lies: ahead of ``start``, or behind it.
  private func sign(of position: Coordinate) -> Double {
    cos(relativeBearing(of: position)) < 0 ? -1 : 1
  }
}

extension Double {
  /// This value held to the range a cosine occupies, so that rounding cannot push an `acos`
  /// argument past ±1 and answer a NaN.
  fileprivate var clampedToCosineRange: Self { Swift.min(Swift.max(self, -1), 1) }
}
