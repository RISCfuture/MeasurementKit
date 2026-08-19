#if canImport(Darwin)
  import Foundation

  extension Measurement where UnitType: Dimension {
    /// The magnitudes to re-probe at when the live value writes no number to read an arrangement
    /// from. Several are needed because a locale can omit the number at more than one magnitude —
    /// Arabic writes both one foot and two feet as words alone.
    private static var probeMagnitudes: [Double] { [3, 11, 42, 100, 1000] }

    /**
     The text the locale writes before and after this measurement's number — spacing, symbols and
     all — for setting a unit around a field that edits the number on its own.

     The arrangement is read back from how the locale actually writes *this* value under *this*
     format style rather than assumed, because all three move: Sinhala and Swahili lead with the
     unit, Nepali runs it onto the number with no space, Faroese inflects it, and Hebrew moves it
     to the front for a value of one.

     Passing the caller's own format style is what makes the reading correct. A style carrying its
     own number format writes an altimeter setting as “29.92 inHg”; probing that with a number
     formatted to a different precision finds “30” inside “30.06” and hands back “.06 inHg” as the
     unit.

     A locale that writes some magnitudes without a number at all — Arabic writes one foot as
     “قدم” — leaves nothing to split on, so the arrangement is re-probed at other magnitudes and
     the unit still lands on one side.

     - Parameters:
       - format: the style the value is rendered with.
       - locale: the locale to read the arrangement from.
     - Returns: the text to set before the digits and the text to set after them. Either may be
       empty; both are empty only for a unit the locale writes without a number at every magnitude
       tried.
     */
    public func affixes(
      format: Measurement<UnitType>.FormatStyle,
      in locale: Locale = .current
    ) -> (prefix: String, suffix: String) {
      let localized = format.locale(locale)
      if let affixes = affixes(at: value, using: localized, in: locale) { return affixes }

      for magnitude in Self.probeMagnitudes {
        if let affixes = affixes(at: magnitude, using: localized, in: locale) { return affixes }
      }
      return ("", "")
    }

    /// The affixes read from a measurement of `magnitude`, or `nil` where the locale writes that
    /// magnitude without a number to split on.
    private func affixes(
      at magnitude: Double,
      using format: Measurement<UnitType>.FormatStyle,
      in locale: Locale
    ) -> (prefix: String, suffix: String)? {
      let written = format.format(.init(value: magnitude, unit: unit))
      let number = (format.numberFormatStyle ?? .number).locale(locale).format(magnitude)

      guard !number.isEmpty, let range = written.range(of: number) else { return nil }
      return (String(written[..<range.lowerBound]), String(written[range.upperBound...]))
    }
  }
#endif
