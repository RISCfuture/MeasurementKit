import Foundation
import Testing

@testable import MeasurementKitUI

@Suite("Numeric Keypad Tests")
struct NumericKeypadTests {

  /// The number formats these fields are actually edited at, paired with whether a fraction can
  /// be typed into a field using them.
  private static let formats:
    [(name: String, style: FloatingPointFormatStyle<Double>, fractional: Bool)] =
      [
        ("plain", .number, true),
        ("whole increments", .number.rounded(increment: 1), false),
        ("tenths", .number.rounded(increment: 0.1), true),
        ("hundredths", .number.rounded(increment: 0.01), true),
        ("three fraction digits", .number.precision(.fractionLength(3)), true),
        ("two fraction digits", .number.precision(.fractionLength(2)), true),
        ("no fraction digits", .number.precision(.fractionLength(0)), false),
        ("up to two fraction digits", .number.precision(.fractionLength(0...2)), true)
      ]

  private static let locales = Locale.availableIdentifiers.map { Locale(identifier: $0) }

  /**
   The point of reading the keypad off the format rather than asking the caller for it. A style
   that rounds the fraction away leaves a separator key that can only produce text the field
   discards; one that keeps it and gets no separator key leaves the fraction unreachable.
   */
  @Test("Fractionality follows the format in every locale")
  func fractionalityFollowsTheFormat() {
    var wrong: [String] = []

    for locale in Self.locales {
      for format in Self.formats {
        let keypad = NumericKeypad.matching(format.style, in: locale)
        let expected: NumericKeypad = format.fractional ? .decimal : .whole

        if keypad != expected {
          wrong.append("\(locale.identifier) at \(format.name): \(keypad)")
        }
      }
    }

    #expect(wrong.isEmpty, "\(wrong.count) mismatched: \(wrong.prefix(5))")
  }

  /// The sign is asked for rather than read, because a negative writes a minus sign whatever the
  /// style's sign strategy says. Whatever fractionality was resolved has to survive being asked.
  @Test("Asking for negatives signs the keypad without disturbing its fractionality")
  func negativesSignTheKeypad() {
    var wrong: [String] = []

    for locale in Self.locales {
      for format in Self.formats {
        let keypad = NumericKeypad.matching(format.style, allowsNegatives: true, in: locale)
        let expected: NumericKeypad = format.fractional ? .signedDecimal : .signedWhole

        if keypad != expected {
          wrong.append("\(locale.identifier) at \(format.name): \(keypad)")
        }
      }
    }

    #expect(wrong.isEmpty, "\(wrong.count) mismatched: \(wrong.prefix(5))")
  }

  /// A locale writing its own digits still writes its own decimal separator, and the probe has to
  /// find it there rather than looking for a full stop.
  @Test(
    "A locale with its own digits resolves",
    arguments: ["ar_EG", "fa_IR", "my_MM", "bn_IN", "ne_NP"]
  )
  func nonArabicDigitsResolve(identifier: String) {
    let locale = Locale(identifier: identifier)

    #expect(NumericKeypad.matching(.number, in: locale) == .decimal)
    #expect(NumericKeypad.matching(.number.rounded(increment: 1), in: locale) == .whole)
  }
}
