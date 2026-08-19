import Foundation
import Testing

@testable import MeasurementKit

/**
 Exercises every cross-dimensional relation with **no type annotations**.

 Two overloads that differ only in return type are ambiguous at the use site, and the ambiguity is
 invisible in the module that declares them — it appears only where they are called, and only when
 the result type is not already pinned by an annotation. Writing every relation as a bare `let` is
 what makes a future overload that collides with an existing one fail this build instead of
 silently breaking a consumer.

 The assertions are deliberately thin. The point of the suite is that it compiles.
 */
@Suite("Operator Coverage Tests")
struct OperatorCoverageTests {

  private let length = Measurement(value: 100, unit: UnitLength.meters)
  private let shorter = Measurement(value: 25, unit: UnitLength.meters)
  private let time = Measurement(value: 10, unit: UnitDuration.seconds)
  private let speed = Measurement(value: 10, unit: UnitSpeed.metersPerSecond)
  private let acceleration = Measurement(value: 2, unit: UnitAcceleration.metersPerSecondSquared)
  private let area = Measurement(value: 20, unit: UnitArea.squareMeters)
  private let volume = Measurement(value: 8, unit: UnitVolume.liters)
  private let mass = Measurement(value: 6, unit: UnitMass.kilograms)
  private let density = Measurement(value: 2, unit: UnitDensity.kilogramsPerLiter)
  private let volumeFlow = Measurement(value: 4, unit: UnitVolumetricFlowRate.litersPerSecond)
  private let massFlow = Measurement(value: 3, unit: UnitMassFlowRate.kilogramsPerSecond)
  private let force = Measurement(value: 12, unit: UnitForce.newtons)
  private let pressure = Measurement(value: 5, unit: UnitPressure.newtonsPerMetersSquared)
  private let energy = Measurement(value: 50, unit: UnitEnergy.joules)
  private let power = Measurement(value: 25, unit: UnitPower.watts)
  private let angle = Measurement(value: 60, unit: UnitAngle.degrees)
  private let angularVelocity = Measurement(value: 6, unit: UnitAngularVelocity.degreesPerSecond)
  private let potential = Measurement(value: 12, unit: UnitElectricPotentialDifference.volts)
  private let current = Measurement(value: 3, unit: UnitElectricCurrent.amperes)
  private let resistance = Measurement(value: 4, unit: UnitElectricResistance.ohms)
  private let charge = Measurement(value: 30, unit: UnitElectricCharge.coulombs)

  // MARK: - Kinematics

  @Test("Kinematic relations resolve without annotation")
  func kinematics() {
    let derivedSpeed = length / time
    let derivedTime = length / speed
    let coveredForward = speed * time
    let coveredReverse = time * speed
    let derivedAcceleration = speed / time
    let accelerationTime = speed / acceleration
    let gainedForward = acceleration * time
    let gainedReverse = time * acceleration

    #expect(derivedSpeed.value > 0)
    #expect(derivedTime.value > 0)
    #expect(coveredForward == coveredReverse)
    #expect(derivedAcceleration.value > 0)
    #expect(accelerationTime.value > 0)
    #expect(gainedForward == gainedReverse)
  }

  // MARK: - Geometry

  @Test("Geometric relations resolve without annotation")
  func geometry() {
    let rectangle = length * shorter
    let side = area / shorter
    let prismForward = area * shorter
    let prismReverse = shorter * area
    let height = volume / area
    let base = volume / shorter

    #expect(rectangle.value > 0)
    #expect(side.value > 0)
    #expect(prismForward == prismReverse)
    #expect(height.value > 0)
    #expect(base.value > 0)
  }

  // MARK: - Mass, density and flow

  @Test("Material relations resolve without annotation")
  func material() {
    let weighedForward = volume * density
    let weighedReverse = density * volume
    let displaced = mass / density
    let measured = mass / volume
    let volumeRate = volume / time
    let flowedForward = volumeFlow * time
    let flowedReverse = time * volumeFlow
    let volumeDuration = volume / volumeFlow
    let massRate = mass / time
    let massForward = massFlow * time
    let massReverse = time * massFlow
    let massDuration = mass / massFlow
    let convertedForward = volumeFlow * density
    let convertedReverse = density * volumeFlow
    let backToVolume = massFlow / density

    #expect(weighedForward == weighedReverse)
    #expect(displaced.value > 0)
    #expect(measured.value > 0)
    #expect(volumeRate.value > 0)
    #expect(flowedForward == flowedReverse)
    #expect(volumeDuration.value > 0)
    #expect(massRate.value > 0)
    #expect(massForward == massReverse)
    #expect(massDuration.value > 0)
    #expect(convertedForward == convertedReverse)
    #expect(backToVolume.value > 0)
  }

  // MARK: - Force, pressure, energy and power

  @Test("Mechanical relations resolve without annotation")
  func mechanical() {
    let weightForward = mass * acceleration
    let weightReverse = acceleration * mass
    let imparted = force / mass
    let accelerated = force / acceleration
    let loadForward = pressure * area
    let loadReverse = area * pressure
    let spread = force / area
    let over = force / pressure
    let workForward = force * length
    let workReverse = length * force
    let restored = energy / length
    let deliveredForward = power * time
    let deliveredReverse = time * power
    let rate = energy / time
    let endurance = energy / power
    let developedForward = force * speed
    let developedReverse = speed * force
    let thrust = power / speed

    #expect(weightForward == weightReverse)
    #expect(imparted.value > 0)
    #expect(accelerated.value > 0)
    #expect(loadForward == loadReverse)
    #expect(spread.value > 0)
    #expect(over.value > 0)
    #expect(workForward == workReverse)
    #expect(restored.value > 0)
    #expect(deliveredForward == deliveredReverse)
    #expect(rate.value > 0)
    #expect(endurance.value > 0)
    #expect(developedForward == developedReverse)
    #expect(thrust.value > 0)
  }

  // MARK: - Rotation

  @Test("Rotational relations resolve without annotation")
  func rotation() {
    let rate = angle / time
    let sweptForward = angularVelocity * time
    let sweptReverse = time * angularVelocity
    let sweepTime = angle / angularVelocity
    let radius = speed / angularVelocity
    let turnRate = speed / length

    #expect(rate.value > 0)
    #expect(sweptForward == sweptReverse)
    #expect(sweepTime.value > 0)
    #expect(radius.value > 0)
    #expect(turnRate.value > 0)
  }

  // MARK: - Electrical

  @Test("Electrical relations resolve without annotation")
  func electrical() {
    let dissipatedForward = potential * current
    let dissipatedReverse = current * potential
    let acrossWhich = power / current
    let drawn = power / potential
    let derivedResistance = potential / current
    let developedForward = current * resistance
    let developedReverse = resistance * current
    let driven = potential / resistance
    let carriedForward = current * time
    let carriedReverse = time * current
    let derivedCurrent = charge / time
    let chargeTime = charge / current

    #expect(dissipatedForward == dissipatedReverse)
    #expect(acrossWhich.value > 0)
    #expect(drawn.value > 0)
    #expect(derivedResistance.value > 0)
    #expect(developedForward == developedReverse)
    #expect(driven.value > 0)
    #expect(carriedForward == carriedReverse)
    #expect(derivedCurrent.value > 0)
    #expect(chargeTime.value > 0)
  }

  // MARK: - Ratios, beside the cross-dimensional relations that share a left operand

  @Test("Same-dimension ratios resolve beside the relations sharing their left operand")
  func ratios() {
    let lengths = length / shorter
    let speeds = speed / speed
    let areas = area / area
    let volumes = volume / volume
    let masses = mass / mass
    let times = time / time
    let angles = angle / angle

    #expect(lengths == 4)
    #expect(speeds == 1)
    #expect(areas == 1)
    #expect(volumes == 1)
    #expect(masses == 1)
    #expect(times == 1)
    #expect(angles == 1)
  }

  /// Foundation's own arithmetic has to keep resolving with sixty overloads in scope.
  @Test("Foundation's own measurement operators still resolve")
  func foundationOperatorsSurvive() {
    let scaled = length * 2.0
    let halved = length / 2.0
    let summed = length + shorter
    let difference = length - shorter

    #expect(scaled.value == 200)
    #expect(halved.value == 50)
    #expect(summed.value == 125)
    #expect(difference.value == 75)
    #expect(length > shorter)
  }
}
