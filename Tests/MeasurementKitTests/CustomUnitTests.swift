import Foundation
import Numerics
import Testing

@testable import MeasurementKit

@Suite("Custom Unit Tests")
struct CustomUnitTests {

  // MARK: - Slope

  /// The symbol is the SI spelling for a ratio of like quantities. Naming it `m` — as one of the
  /// apps this was extracted from did — collides with the metre wherever a slope is formatted.
  @Test("A ratio is symbolised as a ratio, not as a metre")
  func slopeSymbolIsNotAMetre() {
    #expect(UnitSlope.ratio.symbol == "m/m")
    #expect(UnitSlope.ratio.symbol != UnitLength.meters.symbol)
  }

  @Test("A published climb gradient converts to percent and to an angle")
  func climbGradientConverts() {
    let gradient = Measurement(value: 318, unit: UnitSlope.feetPerNauticalMile)

    #expect(
      gradient.converted(to: .percent).value
        .isApproximatelyEqual(to: 5.2336, absoluteTolerance: 0.0001)
    )
    #expect(
      gradient.angle.converted(to: .degrees).value
        .isApproximatelyEqual(to: 3, absoluteTolerance: 0.01)
    )
  }

  @Test("An angle and its slope round-trip")
  func slopeRoundTrips() {
    let angle = Measurement(value: 3, unit: UnitAngle.degrees)

    #expect(
      angle.slope.angle.converted(to: .degrees).value
        .isApproximatelyEqual(to: 3, absoluteTolerance: 1e-9)
    )
  }

  @Test("A rise over a run is a slope")
  func riseOverRun() {
    let rise = Measurement(value: 50, unit: UnitLength.feet)
    let run = Measurement(value: 1000, unit: UnitLength.feet)

    #expect(rise.slope(over: run).converted(to: .percent).value
      .isApproximatelyEqual(to: 5, absoluteTolerance: 1e-9))
  }

  // MARK: - Density and flow

  /// Foundation measures mass in kilograms and volume in litres, so the coherent base unit has a
  /// coefficient of exactly one. A base unit that had to be reached by conversion would make every
  /// density relation approximate.
  @Test("The base density is coherent with Foundation's own base units")
  func densityBaseIsCoherent() {
    #expect(UnitDensity.baseUnit() == UnitDensity.kilogramsPerLiter)
    #expect(UnitDensity.kilogramsPerLiter.converter.baseUnitValue(fromValue: 1) == 1)
  }

  @Test("A derived unit reports the units it was built from")
  func derivedUnitsCarryComponents() {
    #expect(UnitDensity.poundsPerGallon.numeratorUnit == .pounds)
    #expect(UnitDensity.poundsPerGallon.denominatorUnit == .gallons)
    #expect(UnitMassFlowRate.poundsPerHour.numeratorUnit == .pounds)
    #expect(UnitMassFlowRate.poundsPerHour.denominatorUnit == .hours)
    #expect(UnitVolumetricFlowRate.gallonsPerHour.numeratorUnit == .gallons)
    #expect(UnitAngularVelocity.degreesPerSecond.numeratorUnit == .degrees)
  }

  @Test("A revolution per minute is six degrees per second")
  func revolutionsConvert() {
    let rate = Measurement(value: 1, unit: UnitAngularVelocity.revolutionsPerMinute)

    #expect(rate.converted(to: .degreesPerSecond).value.isApproximatelyEqual(
      to: 6, absoluteTolerance: 1e-12))
  }

  // MARK: - Force

  @Test("A kilogram-force is standard gravity on a kilogram")
  func kilogramForceIsCoherent() {
    let weight = Measurement(value: 1, unit: UnitMass.kilograms) * Measurement.standardGravity

    #expect(weight.converted(to: .kilogramsForce).value
      .isApproximatelyEqual(to: 1, absoluteTolerance: 1e-12))
  }

  // MARK: - Building a unit that the package does not ship

  @Test("A unit of one dimension per another can be built from its components")
  func derivedUnitBuildsFromComponents() {
    let poundsPerSquareFoot: UnitPressure = derivedUnit(UnitForce.poundsForce, per: UnitArea.squareFeet)
    let wingLoading = Measurement(value: 1, unit: poundsPerSquareFoot)

    #expect(poundsPerSquareFoot.symbol == "lbf/ft²")
    #expect(wingLoading.converted(to: .newtonsPerMetersSquared).value > 0)
  }
}
