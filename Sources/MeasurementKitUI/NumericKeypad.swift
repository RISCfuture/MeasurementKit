public import Foundation

/**
 The keys a numeric field needs, chosen from what its number format actually writes rather than
 from what the caller remembers about it.

 A field that raises the wrong keypad is a field the value cannot be typed into: a pad without a
 decimal separator makes an altimeter setting unreachable, and one without a minus sign makes a
 temperature below freezing unreachable.
 */
public enum NumericKeypad: Sendable, Hashable, CaseIterable {
  /// Digits alone.
  case whole

  /// Digits and the locale's decimal separator.
  case decimal

  /// Digits and a minus sign.
  case signedWhole

  /// Digits, the locale's decimal separator, and a minus sign.
  case signedDecimal

  /**
   Whether this pad offers the decimal separator, and with it whether a fraction belongs in the
   value a field raising it reads back.

   The pad is the one place a field's fractionality is stated, so it is also what the field's parse
   consults. Only some platforms can withhold a key; every platform can decline to read what the
   key would have typed, which is what keeps a whole-number field whole on a Mac.
   */
  var isFractional: Bool {
    switch self {
      case .decimal, .signedDecimal: true
      case .whole, .signedWhole: false
    }
  }

  /// The keypad offering each of the keys asked for.
  init(fractional: Bool, signed: Bool) {
    switch (fractional, signed) {
      case (true, true): self = .signedDecimal
      case (true, false): self = .decimal
      case (false, true): self = .signedWhole
      case (false, false): self = .whole
    }
  }

  /**
   The keypad `numberFormat` calls for.

   Fractionality is read from what the style writes for a half: a style that keeps the fraction
   puts the locale's decimal separator in the text, and one that rounds it away does not. Reading
   it is the only trustworthy route — a format style is not introspectable, and its precision can
   be set through `precision(_:)` or `rounded(increment:)` alike.

   The sign cannot be read the same way, which is why it is asked for. A negative value writes a
   minus sign whatever the style's sign strategy says, and in a right-to-left locale the marks
   around it defeat a comparison of what the style writes for a value and its negation.

   - Parameters:
     - numberFormat: the style the field's value is written and read with.
     - allowsNegatives: whether a negative value belongs in the field.
     - locale: the locale whose decimal separator is looked for.
   - Returns: the keypad carrying exactly the keys the value needs.
   */
  public static func matching(
    _ numberFormat: FloatingPointFormatStyle<Double>,
    allowsNegatives: Bool = false,
    in locale: Locale = .current
  ) -> Self {
    .init(fractional: numberFormat.writesFractions(in: locale), signed: allowsNegatives)
  }
}

extension FloatingPointFormatStyle {
  /// Whether this style writes a fraction at all, read from whether a half leaves the locale's
  /// decimal separator in the text.
  func writesFractions(in locale: Locale) -> Bool {
    guard let separator = locale.decimalSeparator else { return false }
    let half: FormatInput = 0.5
    return self.locale(locale).format(half).contains(separator)
  }
}
