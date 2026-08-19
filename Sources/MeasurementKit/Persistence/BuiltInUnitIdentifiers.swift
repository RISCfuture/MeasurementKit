import Foundation

extension UnitSlope: UnitIdentifying {
  public static var unitIdentifiers: [UnitIdentifier: UnitSlope] {
    [
      "ratio": .ratio,
      "percent": .percent,
      "feetPerNauticalMile": .feetPerNauticalMile
    ]
  }
}

extension UnitDensity: UnitIdentifying {
  public static var unitIdentifiers: [UnitIdentifier: UnitDensity] {
    [
      "kilogramsPerLiter": .kilogramsPerLiter,
      "kilogramsPerCubicMeter": .kilogramsPerCubicMeter,
      "poundsPerGallon": .poundsPerGallon,
      "poundsPerCubicFoot": .poundsPerCubicFoot
    ]
  }
}

extension UnitForce: UnitIdentifying {
  public static var unitIdentifiers: [UnitIdentifier: UnitForce] {
    [
      "newtons": .newtons,
      "poundsForce": .poundsForce,
      "kilogramsForce": .kilogramsForce
    ]
  }
}

extension UnitAngularVelocity: UnitIdentifying {
  public static var unitIdentifiers: [UnitIdentifier: UnitAngularVelocity] {
    [
      "degreesPerSecond": .degreesPerSecond,
      "radiansPerSecond": .radiansPerSecond,
      "degreesPerMinute": .degreesPerMinute,
      "revolutionsPerMinute": .revolutionsPerMinute
    ]
  }
}

extension UnitMassFlowRate: UnitIdentifying {
  public static var unitIdentifiers: [UnitIdentifier: UnitMassFlowRate] {
    [
      "kilogramsPerSecond": .kilogramsPerSecond,
      "kilogramsPerHour": .kilogramsPerHour,
      "poundsPerHour": .poundsPerHour
    ]
  }
}

extension UnitVolumetricFlowRate: UnitIdentifying {
  public static var unitIdentifiers: [UnitIdentifier: UnitVolumetricFlowRate] {
    [
      "litersPerSecond": .litersPerSecond,
      "litersPerMinute": .litersPerMinute,
      "gallonsPerHour": .gallonsPerHour,
      "cubicMetersPerSecond": .cubicMetersPerSecond
    ]
  }
}

extension UnitTemperatureDifference: UnitIdentifying {
  public static var unitIdentifiers: [UnitIdentifier: UnitTemperatureDifference] {
    [
      "kelvin": .kelvin,
      "celsius": .celsius,
      "fahrenheit": .fahrenheit
    ]
  }
}

/**
 The tables every lookup starts from: MeasurementKit's own dimensions, and the Foundation
 dimensions an app is most likely to let a reader choose a unit for.

 Registering Foundation's units here is not a conformance — nothing is added to `UnitLength` that
 another library could also add — so it costs an adopting app nothing and can be overridden
 wholesale by registering a table of its own.
 */
let builtInUnitTables: [ObjectIdentifier: UnitTable] = {
  var tables: [ObjectIdentifier: UnitTable] = [:]

  func add<UnitType: Dimension>(_ identifiers: [UnitIdentifier: UnitType]) {
    tables[ObjectIdentifier(UnitType.self), default: .init()].insert(identifiers)
  }

  add(UnitSlope.unitIdentifiers)
  add(UnitDensity.unitIdentifiers)
  add(UnitForce.unitIdentifiers)
  add(UnitAngularVelocity.unitIdentifiers)
  add(UnitMassFlowRate.unitIdentifiers)
  add(UnitVolumetricFlowRate.unitIdentifiers)
  add(UnitTemperatureDifference.unitIdentifiers)

  add(foundationLengthIdentifiers)
  add(foundationSpeedIdentifiers)
  add(foundationMassIdentifiers)
  add(foundationVolumeIdentifiers)
  add(foundationPressureIdentifiers)
  add(foundationTemperatureIdentifiers)
  add(foundationAngleIdentifiers)
  add(foundationDurationIdentifiers)
  add(foundationAccelerationIdentifiers)
  add(foundationAreaIdentifiers)
  add(foundationPowerIdentifiers)
  add(foundationEnergyIdentifiers)

  return tables
}()

private let foundationLengthIdentifiers: [UnitIdentifier: UnitLength] = [
  "meters": .meters,
  "kilometers": .kilometers,
  "centimeters": .centimeters,
  "millimeters": .millimeters,
  "inches": .inches,
  "feet": .feet,
  "yards": .yards,
  "miles": .miles,
  "nauticalMiles": .nauticalMiles
]

private let foundationSpeedIdentifiers: [UnitIdentifier: UnitSpeed] = [
  "metersPerSecond": .metersPerSecond,
  "kilometersPerHour": .kilometersPerHour,
  "milesPerHour": .milesPerHour,
  "knots": .knots,
  "feetPerMinute": .feetPerMinute
]

private let foundationMassIdentifiers: [UnitIdentifier: UnitMass] = [
  "kilograms": .kilograms,
  "grams": .grams,
  "pounds": .pounds,
  "ounces": .ounces,
  "metricTons": .metricTons,
  "shortTons": .shortTons
]

private let foundationVolumeIdentifiers: [UnitIdentifier: UnitVolume] = [
  "liters": .liters,
  "milliliters": .milliliters,
  "cubicMeters": .cubicMeters,
  "cubicFeet": .cubicFeet,
  "gallons": .gallons,
  "quarts": .quarts,
  "imperialGallons": .imperialGallons
]

private let foundationPressureIdentifiers: [UnitIdentifier: UnitPressure] = [
  "newtonsPerMetersSquared": .newtonsPerMetersSquared,
  "hectopascals": .hectopascals,
  "kilopascals": .kilopascals,
  "millibars": .millibars,
  "inchesOfMercury": .inchesOfMercury,
  "millimetersOfMercury": .millimetersOfMercury,
  "poundsForcePerSquareInch": .poundsForcePerSquareInch
]

private let foundationTemperatureIdentifiers: [UnitIdentifier: UnitTemperature] = [
  "kelvin": .kelvin,
  "celsius": .celsius,
  "fahrenheit": .fahrenheit
]

private let foundationAngleIdentifiers: [UnitIdentifier: UnitAngle] = [
  "degrees": .degrees,
  "radians": .radians,
  "gradians": .gradians,
  "arcMinutes": .arcMinutes,
  "arcSeconds": .arcSeconds
]

private let foundationDurationIdentifiers: [UnitIdentifier: UnitDuration] = [
  "seconds": .seconds,
  "minutes": .minutes,
  "hours": .hours,
  "milliseconds": .milliseconds
]

private let foundationAccelerationIdentifiers: [UnitIdentifier: UnitAcceleration] = [
  "metersPerSecondSquared": .metersPerSecondSquared,
  "gravity": .gravity,
  "knotsPerSecond": .knotsPerSecond
]

private let foundationAreaIdentifiers: [UnitIdentifier: UnitArea] = [
  "squareMeters": .squareMeters,
  "squareKilometers": .squareKilometers,
  "squareFeet": .squareFeet,
  "squareMiles": .squareMiles,
  "hectares": .hectares,
  "acres": .acres
]

private let foundationPowerIdentifiers: [UnitIdentifier: UnitPower] = [
  "watts": .watts,
  "kilowatts": .kilowatts,
  "horsepower": .horsepower
]

private let foundationEnergyIdentifiers: [UnitIdentifier: UnitEnergy] = [
  "joules": .joules,
  "kilojoules": .kilojoules,
  "kilocalories": .kilocalories,
  "kilowattHours": .kilowattHours
]
