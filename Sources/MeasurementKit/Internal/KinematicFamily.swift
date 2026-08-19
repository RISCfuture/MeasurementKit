import Foundation

/**
 A set of length, duration, speed and acceleration units that measure each other coherently.

 One nautical mile is what one knot covers in one hour, and one foot is what one foot per minute
 covers in one minute. Answering a kinematic relation inside the family the left operand belongs to
 is what makes `120 kn × 2 hr` come out as exactly 240 NM: Foundation's knot coefficient is the
 truncated 0.514444, so routing the same product through metres arrives at 239.99979 NM instead.
 */
enum KinematicFamily {
  case si
  case nautical
  case statute
  case metricRoad
  case verticalAviation

  var lengthUnit: UnitLength {
    switch self {
      case .si: .meters
      case .nautical: .nauticalMiles
      case .statute: .miles
      case .metricRoad: .kilometers
      case .verticalAviation: .feet
    }
  }

  var durationUnit: UnitDuration {
    switch self {
      case .si: .seconds
      case .nautical, .statute, .metricRoad: .hours
      case .verticalAviation: .minutes
    }
  }

  var speedUnit: UnitSpeed {
    switch self {
      case .si: .metersPerSecond
      case .nautical: .knots
      case .statute: .milesPerHour
      case .metricRoad: .kilometersPerHour
      case .verticalAviation: .feetPerMinute
    }
  }

  var accelerationUnit: UnitAcceleration {
    switch self {
      case .nautical: .knotsPerSecond
      default: .metersPerSecondSquared
    }
  }
}

extension UnitLength {
  /// The family this length measures in, or ``KinematicFamily/si`` when it names none.
  var kinematicFamily: KinematicFamily {
    switch self {
      case .nauticalMiles: .nautical
      case .miles: .statute
      case .kilometers: .metricRoad
      case .feet: .verticalAviation
      default: .si
    }
  }
}

extension UnitSpeed {
  /// The family this speed measures in, or ``KinematicFamily/si`` when it names none.
  var kinematicFamily: KinematicFamily {
    switch self {
      case .knots: .nautical
      case .milesPerHour: .statute
      case .kilometersPerHour: .metricRoad
      case .feetPerMinute: .verticalAviation
      default: .si
    }
  }
}

extension UnitAcceleration {
  /// The family this acceleration measures in, or ``KinematicFamily/si`` when it names none.
  var kinematicFamily: KinematicFamily {
    self == .knotsPerSecond ? .nautical : .si
  }
}
