#if canImport(Darwin)
  import Foundation
  import Testing

  @testable import MeasurementKit

  @Suite("Affix Tests")
  struct AffixTests {

    /// The precisions these fields are actually edited at. The failure this API prevents is
    /// invisible at whole numbers and appears at every one of the others.
    private static let lengthFormats: [Measurement<UnitLength>.FormatStyle] = [
      .measurement(width: .abbreviated, usage: .asProvided),
      .measurement(width: .narrow, usage: .asProvided),
      .measurement(width: .wide, usage: .asProvided),
      .measurement(
        width: .abbreviated,
        usage: .asProvided,
        numberFormatStyle: .number.rounded(increment: 0.1)
      )
    ]

    private static let locales = Locale.availableIdentifiers.map { Locale(identifier: $0) }

    // MARK: - Unit duplication

    /**
     The failure this whole API exists to prevent.

     Recovering the unit by formatting a dummy value and splitting on its digits returns a
     one-element array wherever the locale writes no digits — Arabic writes one foot as “قدم” — and
     the first and last element of a one-element array are the same substring, so the field renders
     the unit on both sides of the number.
     */
    @Test("The unit never lands on both sides at once")
    func unitNeverDuplicates() {
      var duplicated: [String] = []

      for locale in Self.locales {
        for magnitude in [0.0, 1, 2, 3, 11, 42, 3_000] {
          let length = Measurement(value: magnitude, unit: UnitLength.feet)
          let (prefix, suffix) = length.affixes(format: Self.lengthFormats[0], in: locale)

          if !prefix.isEmpty, prefix == suffix {
            duplicated.append("\(locale.identifier) at \(magnitude): “\(prefix)” on both sides")
          }
        }
      }

      #expect(duplicated.isEmpty, "\(duplicated.count) duplicated: \(duplicated.prefix(5))")
    }

    /// The magnitude cascade exists so that a locale writing some magnitudes without a number still
    /// places its unit. An unresolved arrangement renders a field with no unit beside it at all.
    @Test("Every locale resolves an arrangement at every precision")
    func everyLocaleResolves() {
      var unresolved: [String] = []

      for locale in Self.locales {
        for format in Self.lengthFormats {
          let length = Measurement(value: 1, unit: UnitLength.feet)
          let (prefix, suffix) = length.affixes(format: format, in: locale)

          if prefix.isEmpty, suffix.isEmpty {
            unresolved.append(locale.identifier)
          }
        }
      }

      #expect(unresolved.isEmpty, "\(unresolved.count) unresolved: \(unresolved.prefix(5))")
    }

    /// Wherever the locale does write the number, putting it back between the affixes has to
    /// reproduce what the locale wrote — that is what a field showing a unit beside an editable
    /// number is imitating.
    @Test("Placing the number between the affixes reproduces the written measurement")
    func affixesReproduceTheWrittenMeasurement() {
      var mismatches: [String] = []

      for locale in Self.locales {
        for format in Self.lengthFormats {
          for magnitude in [0.0, 1, 2, 42, 3_000] {
            let length = Measurement(value: magnitude, unit: UnitLength.feet)
            let localized = format.locale(locale)
            let written = localized.format(length)
            let number = (localized.numberFormatStyle ?? .number).locale(locale).format(magnitude)
            guard written.contains(number) else { continue }

            let (prefix, suffix) = length.affixes(format: format, in: locale)
            guard prefix + number + suffix != written else { continue }
            mismatches.append(
              "\(locale.identifier) at \(magnitude): “\(prefix + number + suffix)” ≠ “\(written)”"
            )
          }
        }
      }

      #expect(mismatches.isEmpty, "\(mismatches.count) mismatched: \(mismatches.prefix(5))")
    }

    // MARK: - Precision

    /**
     The failure the format-style parameter exists to prevent.

     Probing with a number formatted to a different precision than the style writes finds “30” inside
     “30.06” and hands back the fraction as though it were the unit.
     */
    @Test("A style with fractional precision is probed at its own precision")
    func fractionalPrecisionIsHonoured() {
      let format = Measurement<UnitPressure>.FormatStyle.measurement(
        width: .abbreviated,
        usage: .asProvided,
        numberFormatStyle: .number.rounded(increment: 0.01)
      )
      let locale = Locale(identifier: "en_US")

      for setting in [29.92, 30.06, 1_013.25] {
        let altimeter = Measurement(value: setting, unit: UnitPressure.inchesOfMercury)
        let (prefix, suffix) = altimeter.affixes(format: format, in: locale)

        #expect(prefix.isEmpty)
        #expect(suffix == " inHg", "at \(setting) the suffix was “\(suffix)”")
      }
    }

    // MARK: - Arrangement

    /// Arabic writes one foot as “قدم” and two as “قدمان”, neither of which contains a number to read
    /// an arrangement from. The unit still has to land on exactly one side, in the locale's own
    /// script, leaving the field somewhere to show the value.
    @Test(
      "A unit written without a number still lands on one side, in the locale's script",
      arguments: [("ar", 1.0), ("ar_EG", 1.0), ("ar_SA", 2.0)]
    )
    func unitWithoutNumberStillPlaced(identifier: String, magnitude: Double) {
      let locale = Locale(identifier: identifier)
      let length = Measurement(value: magnitude, unit: UnitLength.feet)

      let (prefix, suffix) = length.affixes(format: Self.lengthFormats[0], in: locale)

      #expect(prefix.isEmpty != suffix.isEmpty, "the unit landed on both sides, or neither")
      // Arabic inflects the unit for number — one foot is “قدم”, two are “أقدام” — so the assertion
      // is that the unit was written in the locale's own script, not that it took any one form.
      #expect(
        (prefix + suffix).unicodeScalars.contains { (0x0600...0x06FF).contains(Int($0.value)) },
        "the unit was not written in Arabic"
      )
    }

    /// Sinhala and Swahili write the unit first, so a field that pins it to the trailing edge reads
    /// backwards there.
    @Test(
      "The unit leads the number where the locale writes it first",
      arguments: ["si_LK", "sw_TZ"]
    )
    func unitLeadsNumber(identifier: String) {
      let length = Measurement(value: 42, unit: UnitLength.feet)

      let (prefix, suffix) = length.affixes(
        format: Self.lengthFormats[0],
        in: Locale(identifier: identifier)
      )

      #expect(!prefix.isEmpty)
      #expect(suffix.isEmpty)
    }

    /// Reading the arrangement from the value being edited, rather than from a fixed dummy, is what
    /// keeps it right in a language that moves or inflects the unit for particular numbers.
    @Test("The arrangement follows the value where the locale moves the unit")
    func arrangementFollowsTheValue() {
      let locale = Locale(identifier: "he_IL")
      let one = Measurement(value: 1, unit: UnitLength.feet)
      let many = Measurement(value: 42, unit: UnitLength.feet)

      let single = one.affixes(format: Self.lengthFormats[0], in: locale)
      let plural = many.affixes(format: Self.lengthFormats[0], in: locale)

      #expect(single != plural, "Hebrew writes one foot differently from forty-two")
    }
  }
#endif
