import Foundation
import Testing

@testable import MeasurementKitUI

@Suite("Scalar Entry Tests")
struct ScalarEntryTests {

  /// The precisions these fields are edited at in practice, with a value each format writes
  /// without rounding so a round trip has something to prove.
  private static let formats:
    [(name: String, style: FloatingPointFormatStyle<Double>, value: Double)] = [
      ("plain", .number, 3_000),
      ("whole increments", .number.rounded(increment: 1), 3_000),
      ("tenths", .number.rounded(increment: 0.1), 29.9),
      ("hundredths", .number.rounded(increment: 0.01), 29.92),
      ("three fraction digits", .number.precision(.fractionLength(3)), 1.225),
      ("no fraction digits", .number.precision(.fractionLength(0)), 15),
      ("up to two fraction digits", .number.precision(.fractionLength(0...2)), 2.6)
    ]

  @Test("A value survives being written and read back at every precision")
  func roundTrips() {
    for format in Self.formats {
      let entry = ScalarEntry(format: format.style)
      let text = entry.text(for: format.value)

      #expect(entry.value(from: text) == format.value, "\(format.name) lost \(format.value)")
    }
  }

  /// The bug the type exists for. A field rewritten from its value on every keystroke loses the
  /// separator the instant it is typed, and the fraction can never be reached.
  @Test("A separator just typed is not formatted away")
  func inFlightSeparatorSurvives() {
    let entry = ScalarEntry(format: FloatingPointFormatStyle<Double>.number)
    let typed = "29."

    #expect(entry.value(from: typed) == 29)
    #expect(entry.text(for: 29, whileTyping: typed, isEditing: false) == typed)
  }

  /// Trailing zeros are the same bug one keystroke later: “29.0” is on its way to “29.05”, and
  /// rewriting it to “29” takes the separator away again.
  @Test("A trailing zero on its way to a hundredth is not formatted away")
  func inFlightTrailingZeroSurvives() {
    let entry = ScalarEntry(format: FloatingPointFormatStyle<Double>.number)

    #expect(entry.text(for: 29, whileTyping: "29.0", isEditing: false) == "29.0")
  }

  /// Text that stops writing the bound value is text somebody else changed the value out from
  /// under, and the field has to catch up with it.
  @Test("Text that no longer writes the value is rewritten")
  func staleTextIsRewritten() {
    let entry = ScalarEntry(format: FloatingPointFormatStyle<Double>.number)

    #expect(entry.text(for: 42, whileTyping: "29.", isEditing: false) == "42")
    #expect(entry.text(for: nil, whileTyping: "29", isEditing: false).isEmpty)
  }

  /**
   The defect the focus rule exists for.

   A binding that echoes its write back asynchronously — a preference, a store, anything but plain
   `@State` — leaves the view invalidated a keystroke behind the text, so the value the field is
   handed names the keystroke before last. Rewriting the field from it puts that keystroke back
   under a caret that has already moved on, and the next one is read against text nobody typed. A
   fast typist, or a UI test, outruns the round trip every time.
   */
  @Test("A value lagging a keystroke behind does not rewrite the field being typed into")
  func laggingValueLeavesTypingAlone() {
    let entry = ScalarEntry(format: FloatingPointFormatStyle<Double>.number)
    var text = "3,550"
    var lagging: Double? = 3_550

    for keystroke in ["4", "45", "455", "4550"] {
      text = keystroke
      let handedBack = lagging
      lagging = entry.value(from: text)
      text = entry.text(for: handedBack, whileTyping: text, isEditing: true)
    }

    #expect(text == "4550")
    #expect(lagging == 4_550)
  }

  /// The other half of the rule. A field nobody is typing into shows the value, however the value
  /// got there — a unit changed, a calculation ran, another screen wrote the preference.
  @Test("A value changed while the field is idle is written into it")
  func idleFieldFollowsTheValue() {
    let entry = ScalarEntry(format: FloatingPointFormatStyle<Double>.number)

    #expect(entry.text(for: 4_550, whileTyping: "3,550", isEditing: false) == "4,550")
    #expect(entry.text(for: 4_550, whileTyping: "3,550", isEditing: true) == "3,550")
  }

  /**
   A whole-number keypad is the field's declaration that its value carries no fraction, and the
   parse is what makes the declaration hold everywhere. Only some platforms can withhold the
   separator key: a Mac keyboard types “3000.7” into a field a number pad could only have given
   “30007”, and without this the fraction reaches the value on one platform and not the other.

   The fraction is rounded away rather than truncated, for the reason a stepper over feet rounds:
   turning 2.6 into 2 loses a foot nobody gave away.
   */
  @Test(
    "A fraction survives only where the keypad offers the separator to type it with",
    arguments: [
      (NumericKeypad.whole, 3_001.0),
      (.signedWhole, 3_001),
      (.decimal, 3_000.7),
      (.signedDecimal, 3_000.7)
    ]
  )
  func fractionSurvivesOnlyOnADecimalKeypad(keypad: NumericKeypad, expected: Double) {
    let entry = ScalarEntry(format: FloatingPointFormatStyle<Double>.number, keypad: keypad)

    #expect(entry.value(from: "3000.7") == expected)
    #expect(entry.value(from: "-3000.7") == -expected)
  }

  /// Nothing typed and nothing meant both have to write nothing, or an empty field reads as zero
  /// and a calculation runs on a value nobody gave.
  @Test("Text writing no number writes nothing", arguments: ["", "-", "abc", " "])
  func unparsableTextWritesNothing(text: String) {
    let entry = ScalarEntry(format: FloatingPointFormatStyle<Double>.number)

    #expect(entry.value(from: text) == nil)
  }

  @Test("No value is written as empty text")
  func noValueIsEmpty() {
    let entry = ScalarEntry(format: FloatingPointFormatStyle<Double>.number)

    #expect(entry.text(for: nil).isEmpty)
  }

  /// The field's text is written in the locale it is rendered for, and read back in the same one,
  /// so a comma typed into a German field is a decimal separator rather than a thousands mark.
  @Test("A value round-trips through the locale's own separator")
  func roundTripsInAnotherLocale() {
    let entry = ScalarEntry(
      format: FloatingPointFormatStyle<Double>.number.locale(Locale(identifier: "de_DE"))
    )
    let text = entry.text(for: 29.92)

    #expect(text.contains(","))
    #expect(entry.value(from: text) == 29.92)
  }
}
