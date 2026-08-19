import Foundation

extension UnitLength {
  /// The area unit a square of this length measures in.
  var areaUnit: UnitArea {
    switch self {
      case .meters: .squareMeters
      case .kilometers: .squareKilometers
      case .centimeters: .squareCentimeters
      case .millimeters: .squareMillimeters
      case .feet: .squareFeet
      case .yards: .squareYards
      case .inches: .squareInches
      case .miles: .squareMiles
      default: .squareMeters
    }
  }

  /// The volume unit a cube of this length measures in.
  var volumeUnit: UnitVolume {
    switch self {
      case .meters: .cubicMeters
      case .kilometers: .cubicKilometers
      case .centimeters: .cubicCentimeters
      case .millimeters: .cubicMillimeters
      case .feet: .cubicFeet
      case .yards: .cubicYards
      case .inches: .cubicInches
      case .miles: .cubicMiles
      default: .cubicMeters
    }
  }
}

extension UnitArea {
  /// The length unit a side of this area measures in.
  var lengthUnit: UnitLength {
    switch self {
      case .squareMeters: .meters
      case .squareKilometers: .kilometers
      case .squareCentimeters: .centimeters
      case .squareMillimeters: .millimeters
      case .squareFeet: .feet
      case .squareYards: .yards
      case .squareInches: .inches
      case .squareMiles: .miles
      default: .meters
    }
  }
}

extension UnitVolume {
  /// The length unit an edge of this volume measures in.
  var lengthUnit: UnitLength {
    switch self {
      case .cubicMeters: .meters
      case .cubicKilometers: .kilometers
      case .cubicCentimeters: .centimeters
      case .cubicMillimeters: .millimeters
      case .cubicFeet: .feet
      case .cubicYards: .yards
      case .cubicInches: .inches
      case .cubicMiles: .miles
      default: .meters
    }
  }
}

extension UnitMass {
  /// The force unit a weight of this mass measures in, so that a mass in pounds under one gravity
  /// weighs the same number of pounds-force.
  var forceUnit: UnitForce {
    switch self {
      case .pounds: .poundsForce
      case .kilograms: .kilogramsForce
      default: .newtons
    }
  }
}

extension UnitForce {
  /// The mass unit a body of this weight measures in.
  var massUnit: UnitMass {
    switch self {
      case .poundsForce: .pounds
      case .kilogramsForce: .kilograms
      default: .kilograms
    }
  }
}
