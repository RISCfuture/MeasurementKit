import Foundation
import SwiftUI
import Testing

@testable import MeasurementKitUI

@MainActor
@Suite("Binding Scalar Tests")
struct BindingScalarTests {

  /// A metre is 3.280839895… feet, so a magnitude that comes back from a conversion is compared
  /// with room for the round trip rather than for equality.
  private static let tolerance = 0.0001

  /// The reason the shims exist: a control that edits a number must not be the place a unit is
  /// silently decided. Reading and writing both go through the unit the caller named, and the
  /// binding keeps storing what it always stored.
  @Test("A magnitude read and written in feet leaves metres in the binding")
  func scalarConvertsBothWays() {
    let storage = Storage(Measurement(value: 100, unit: UnitLength.meters))
    let scalar = storage.binding.scalar(in: .feet)

    #expect(abs(scalar.wrappedValue - 328.0839895) < Self.tolerance)

    scalar.wrappedValue = 3_000

    #expect(abs(scalar.wrappedValue - 3_000) < Self.tolerance)
    #expect(abs(storage.value.converted(to: .meters).value - 914.4) < Self.tolerance)
  }

  /// Truncating here loses a whole foot the pilot never gave away, so the magnitude is rounded.
  @Test("A whole-number magnitude is rounded rather than truncated")
  func roundedScalarRounds() {
    let storage = Storage(Measurement(value: 2.6, unit: UnitLength.feet))

    #expect(storage.binding.roundedScalar(in: .feet).wrappedValue == 3)
  }

  @Test("A whole-number magnitude written back keeps its unit")
  func roundedScalarWritesInItsUnit() {
    let storage = Storage(Measurement(value: 0, unit: UnitLength.meters))
    let scalar = storage.binding.roundedScalar(in: .feet)

    scalar.wrappedValue = 3_000

    #expect(scalar.wrappedValue == 3_000)
    #expect(abs(storage.value.converted(to: .meters).value - 914.4) < Self.tolerance)
  }

  /// An empty field has no magnitude, and neither has a magnitude that was cleared. Turning either
  /// into a zero would hand a calculation a value nobody gave.
  @Test("Absence travels through the optional shims in both directions")
  func absenceSurvives() throws {
    let storage = Storage(Measurement<UnitLength>?.none)
    let scalar = storage.binding.scalar(in: .feet)

    #expect(scalar.wrappedValue == nil)
    #expect(storage.binding.roundedScalar(in: .feet).wrappedValue == nil)

    scalar.wrappedValue = 3_000

    #expect(abs(try #require(storage.value).converted(to: .meters).value - 914.4) < Self.tolerance)

    scalar.wrappedValue = nil

    #expect(storage.value == nil)
  }

  @Test("An optional whole-number magnitude is rounded rather than truncated")
  func optionalRoundedScalarRounds() {
    let storage = Storage(Measurement<UnitLength>?(.init(value: 2.6, unit: .feet)))

    #expect(storage.binding.roundedScalar(in: .feet).wrappedValue == 3)
  }
}

/// A value a `Binding` can be projected from outside a view, so the shims can be exercised without
/// a `body` to host them.
@MainActor
private final class Storage<Value> {
  var value: Value

  var binding: Binding<Value> {
    .init(get: { self.value }, set: { self.value = $0 })
  }

  init(_ value: Value) {
    self.value = value
  }
}
