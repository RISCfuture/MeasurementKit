import Foundation
import MeasurementKit
import Numerics
import Testing

@testable import MeasurementKitLocation

@Suite("Bearing Tests")
struct BearingTests {

  @Test("Initialization normalizes into [0, 360)")
  func normalizesAtInitialization() {
    #expect(TrueBearing(degrees: 370).degrees.isApproximatelyEqual(to: 10, absoluteTolerance: 1e-9))
    #expect(
      TrueBearing(degrees: -10).degrees.isApproximatelyEqual(to: 350, absoluteTolerance: 1e-9)
    )
    #expect(TrueBearing(degrees: 360).degrees.isApproximatelyEqual(to: 0, absoluteTolerance: 1e-9))
    #expect(
      TrueBearing(degrees: -730).degrees.isApproximatelyEqual(to: 350, absoluteTolerance: 1e-9)
    )
  }

  @Test("Reciprocal is the opposite course in the same datum")
  func reciprocal() {
    #expect(
      TrueBearing(degrees: 30).reciprocal.degrees.isApproximatelyEqual(
        to: 210,
        absoluteTolerance: 1e-9
      )
    )
    #expect(
      MagneticBearing(degrees: 200).reciprocal.degrees
        .isApproximatelyEqual(to: 20, absoluteTolerance: 1e-9)
    )
  }

  @Test("shortestTurn picks the shorter direction across the 0/360 wrap")
  func shortestTurn() {
    let north = MagneticBearing(degrees: 350)
    let east = MagneticBearing(degrees: 10)

    #expect(
      north.shortestTurn(to: east).degrees.isApproximatelyEqual(to: 20, absoluteTolerance: 1e-9)
    )
    #expect(
      east.shortestTurn(to: north).degrees.isApproximatelyEqual(to: -20, absoluteTolerance: 1e-9)
    )
  }

  @Test("Subtraction answers a signed turn in (-180, 180]")
  func subtractionIsSigned() {
    let opposed = TrueBearing(degrees: 180) - TrueBearing(degrees: 0)
    #expect(opposed.degrees.isApproximatelyEqual(to: 180, absoluteTolerance: 1e-9))

    let theOtherWay = TrueBearing(degrees: 0) - TrueBearing(degrees: 180)
    #expect(theOtherWay.degrees.isApproximatelyEqual(to: 180, absoluteTolerance: 1e-9))

    let leftOfNorth = TrueBearing(degrees: 350) - TrueBearing(degrees: 10)
    #expect(leftOfNorth.degrees.isApproximatelyEqual(to: -20, absoluteTolerance: 1e-9))
  }

  @Test("Adding a turn stays in the datum and wraps")
  func addingATurn() {
    let rolledOut = MagneticBearing(degrees: 350) + RelativeBearing(degrees: 20)
    #expect(rolledOut.degrees.isApproximatelyEqual(to: 10, absoluteTolerance: 1e-9))

    let leftTurn = MagneticBearing(degrees: 10) + RelativeBearing(degrees: -20)
    #expect(leftTurn.degrees.isApproximatelyEqual(to: 350, absoluteTolerance: 1e-9))
  }

  @Test("toMagnetic and toTrue round trip through a variation")
  func datumRoundTrip() {
    let trueBearing = TrueBearing(degrees: 10)
    let variation = MagneticVariation.east(15)

    let magnetic = trueBearing.toMagnetic(variation: variation)
    #expect(magnetic.degrees.isApproximatelyEqual(to: 355, absoluteTolerance: 1e-9))

    let backToTrue = magnetic.toTrue(variation: variation)
    #expect(backToTrue.degrees.isApproximatelyEqual(to: 10, absoluteTolerance: 1e-9))
  }

  @Test("A bare angle converts the same way a variation does")
  func bareAngleVariation() {
    let variation = Measurement(value: 15, unit: UnitAngle.degrees)
    #expect(
      TrueBearing(degrees: 10).toMagnetic(variation: variation).degrees
        .isApproximatelyEqual(to: 355, absoluteTolerance: 1e-9)
    )
    #expect(
      MagneticBearing(degrees: 355).toTrue(variation: variation).degrees
        .isApproximatelyEqual(to: 10, absoluteTolerance: 1e-9)
    )
  }

  /// True runway headings from nav data, with O22's 16°E variation, must yield the magnetic
  /// headings published on the Jeppesen chart (Rwy 35→354, 17→174, 11→118, 29→298).
  @Test("O22's published runway headings fall out of a 16 degrees east variation")
  func publishedRunwayHeadings() {
    let variation = MagneticVariation.east(16)
    let runways: [(trueBearing: Double, published: Double)] = [
      (10, 354), (190, 174), (134, 118), (314, 298)
    ]

    for runway in runways {
      let magnetic = TrueBearing(degrees: runway.trueBearing).toMagnetic(variation: variation)
      #expect(
        magnetic.degrees.isApproximatelyEqual(to: runway.published, absoluteTolerance: 1e-6)
      )
    }
  }

  @Test("Westerly variation runs the other way")
  func westerlyVariation() {
    let variation = MagneticVariation.west(10)
    #expect(variation.isWesterly)
    #expect(
      TrueBearing(degrees: 0).toMagnetic(variation: variation).degrees
        .isApproximatelyEqual(to: 10, absoluteTolerance: 1e-9)
    )
  }

  @Test("Encoding carries the datum alongside the angle")
  func encodesDatum() throws {
    let encoded = try JSONEncoder().encode(TrueBearing(degrees: 90))
    let fields = try #require(
      try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
    )

    #expect(fields["datum"] as? String == "T")
    #expect(
      (fields["degrees"] as? Double)?.isApproximatelyEqual(to: 90, absoluteTolerance: 1e-9) == true
    )
  }

  @Test("Decoding rejects data written in the other datum")
  func decodingRejectsForeignDatum() throws {
    let encoded = try JSONEncoder().encode(MagneticBearing(degrees: 90))

    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(TrueBearing.self, from: encoded)
    }
    let decoded = try JSONDecoder().decode(MagneticBearing.self, from: encoded)
    #expect(decoded.degrees.isApproximatelyEqual(to: 90, absoluteTolerance: 1e-9))
  }

  @Test("Bearings built from different units compare equal")
  func unitIndependence() {
    #expect(TrueBearing(radians: .pi) == TrueBearing(degrees: 180))
  }
}

@Suite("Relative Bearing Tests")
struct RelativeBearingTests {

  @Test("A turn normalizes into (-180, 180]")
  func normalizesAtInitialization() {
    #expect(
      RelativeBearing(degrees: 270).degrees.isApproximatelyEqual(to: -90, absoluteTolerance: 1e-9)
    )
    #expect(
      RelativeBearing(degrees: 180).degrees.isApproximatelyEqual(to: 180, absoluteTolerance: 1e-9)
    )
    #expect(
      RelativeBearing(degrees: -180).degrees.isApproximatelyEqual(to: 180, absoluteTolerance: 1e-9)
    )
  }

  @Test("Magnitude drops the direction of the turn")
  func magnitude() {
    #expect(
      RelativeBearing(degrees: -45).magnitude.degrees
        .isApproximatelyEqual(to: 45, absoluteTolerance: 1e-9)
    )
  }

  @Test("Negation turns the other way")
  func negation() {
    #expect(
      (-RelativeBearing(degrees: 30)).degrees.isApproximatelyEqual(to: -30, absoluteTolerance: 1e-9)
    )
  }
}
