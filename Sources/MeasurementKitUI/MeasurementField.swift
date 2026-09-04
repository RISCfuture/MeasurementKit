public import Foundation
import MeasurementKit
public import SwiftUI

/**
 A text field that edits a measurement, with the unit set beside the digits exactly where the
 locale writes it.

 The unit is placed by `affixes(format:in:)` rather than pinned to the trailing edge, so a locale
 that leads with the unit, runs it onto the number without a space, or inflects it for particular
 numbers reads correctly — and keeps reading correctly as the value being typed changes.

 The field edits the magnitude alone, in the unit the caller names. That unit is required: the
 bound value is `nil` exactly when the field is empty, so there is no value to take a unit from at
 the moment one is most needed, and a default would quietly mean metres in an app that thinks in
 feet.

 A value outside the bounds the caller set colours red. It is still written to the binding — the
 field reports what was typed and leaves the decision about it to the caller.
 */
public struct MeasurementField<UnitType: Dimension>: View {
  /// The field's placeholder while it is empty, and its accessibility label throughout.
  private let label: LocalizedStringKey

  /// The edited value, `nil` while the field writes no number.
  @Binding private var value: Measurement<UnitType>?

  /// The unit the digits are typed and read in.
  private let unit: UnitType

  /// How the value is written — and, through its number format, read back.
  private let format: Measurement<UnitType>.FormatStyle

  /// The keypad the caller asked for, or `nil` to take the one the format calls for.
  private let requestedKeypad: NumericKeypad?

  /// The bounds outside which the entered value shows as invalid, if any.
  private let minimum: Measurement<UnitType>?, maximum: Measurement<UnitType>?

  @Environment(\.locale)
  private var locale

  @State private var text: String

  /// Whether the field holds focus. It lives out here rather than inside the text field because
  /// the value may only rewrite the text while it does not.
  @FocusState private var isEditing: Bool

  public var body: some View {
    let unitAffixes = affixes

    HStack(spacing: 0) {
      Affix(text: unitAffixes.prefix)
      // The placeholder stands down once there is a value to show. A field sized to fit its own
      // placeholder stays that wide forever, and a caller that strikes or boxes the entered value
      // would draw around the empty space the placeholder had reserved.
      NumericTextField(
        label,
        prompt: value == nil ? label : "",
        text: $text,
        isEditing: $isEditing,
        keypad: keypad
      )
      // `.foreground` rather than `.primary`, so a caller dimming or striking the whole field is
      // not overridden by the field restating the colour it would have had anyway.
      .foregroundStyle(isValid ? AnyShapeStyle(.foreground) : AnyShapeStyle(.red))
      Affix(text: unitAffixes.suffix)
    }
    .onChange(of: text) { _, typed in write(typed) }
    .onChange(of: value) { _, entered in
      text = entry.text(for: scalar(of: entered), whileTyping: text, isEditing: isEditing)
    }
    // Leaving the field hands the say back to the value: what was typed is written out afresh, and
    // any change made from elsewhere while the field was held appears.
    .onChange(of: isEditing) { _, editing in
      if !editing { text = entry.text(for: scalar(of: value)) }
    }
    .onChange(of: locale, initial: true) { text = entry.text(for: scalar(of: value)) }
  }

  /// The number format the field's text goes through, in the locale the view is rendered for.
  private var numberFormat: FloatingPointFormatStyle<Double> {
    (format.numberFormatStyle ?? .number).locale(locale)
  }

  /// The format the field's text is written with, and the keypad it is read under.
  private var entry: ScalarEntry<Double> {
    .init(format: numberFormat, keypad: keypad)
  }

  /// The keys the field raises: the ones the caller named, or the ones this value's own format and
  /// bounds call for.
  private var keypad: NumericKeypad {
    requestedKeypad ?? .matching(numberFormat, allowsNegatives: allowsNegatives, in: locale)
  }

  /// Whether the field needs a minus sign. Unless the caller has ruled negatives out with a
  /// minimum of zero or more, one belongs in range.
  private var allowsNegatives: Bool {
    guard let minimum else { return true }
    return minimum < .zero(in: unit)
  }

  /// What the locale writes before and after the digits, read from the value being edited — or,
  /// while the field is empty, from a value standing in for it.
  private var affixes: (prefix: String, suffix: String) {
    (value?.converted(to: unit) ?? .init(value: 1, unit: unit)).affixes(format: format, in: locale)
  }

  /// Whether the entered value lies within the bounds the caller set. An empty field is valid:
  /// there is nothing yet to be out of range.
  private var isValid: Bool {
    guard let value else { return true }
    if let minimum, value < minimum { return false }
    if let maximum, value > maximum { return false }
    return true
  }

  /**
   Creates a field editing a measurement that may be absent.

   - Parameters:
     - label: the placeholder shown while the field is empty, and its accessibility label.
     - value: the edited value, `nil` while the field is empty.
     - unit: the unit the digits are typed and read in.
     - format: how the value is written, and through its number format how it is read back.
     - keypad: the keys to raise; by default, the ones `format` and `minimum` call for.
     - minimum: the value below which the field shows as invalid, if any.
     - maximum: the value above which the field shows as invalid, if any.
   */
  public init(
    _ label: LocalizedStringKey,
    value: Binding<Measurement<UnitType>?>,
    in unit: UnitType,
    format: Measurement<UnitType>.FormatStyle,
    keypad: NumericKeypad? = nil,
    minimum: Measurement<UnitType>? = nil,
    maximum: Measurement<UnitType>? = nil
  ) {
    self.label = label
    _value = value
    self.unit = unit
    self.format = format
    requestedKeypad = keypad
    self.minimum = minimum
    self.maximum = maximum

    let entry = ScalarEntry(format: format.numberFormatStyle ?? .number)
    _text = .init(initialValue: entry.text(for: value.wrappedValue?.converted(to: unit).value))
  }

  /**
   Creates a field editing a measurement that is always present.

   Emptying the field leaves the value as it stands: there is no absence to write into a value
   that cannot be absent.

   - Parameters:
     - label: the placeholder shown while the field is empty, and its accessibility label.
     - value: the edited value.
     - unit: the unit the digits are typed and read in.
     - format: how the value is written, and through its number format how it is read back.
     - keypad: the keys to raise; by default, the ones `format` and `minimum` call for.
     - minimum: the value below which the field shows as invalid, if any.
     - maximum: the value above which the field shows as invalid, if any.
   */
  public init(
    _ label: LocalizedStringKey,
    value: Binding<Measurement<UnitType>>,
    in unit: UnitType,
    format: Measurement<UnitType>.FormatStyle,
    keypad: NumericKeypad? = nil,
    minimum: Measurement<UnitType>? = nil,
    maximum: Measurement<UnitType>? = nil
  ) {
    self.init(
      label,
      value: Binding<Measurement<UnitType>?>(
        get: { value.wrappedValue },
        set: { entered in if let entered { value.wrappedValue = entered } }
      ),
      in: unit,
      format: format,
      keypad: keypad,
      minimum: minimum,
      maximum: maximum
    )
  }

  /// `measurement` as the number the field edits: its magnitude in the field's own unit.
  private func scalar(of measurement: Measurement<UnitType>?) -> Double? {
    measurement?.converted(to: unit).value
  }

  /// Reads `typed` back into the bound value, on every keystroke, so a caller calculating from it
  /// keeps up with the field rather than waiting for it to be dismissed.
  private func write(_ typed: String) {
    value = entry.value(from: typed).map { .init(value: $0, unit: unit) }
  }
}

/// The text the locale sets beside the digits, drawn only where the locale puts something there.
private struct Affix: View {
  let text: String

  var body: some View {
    if !text.isEmpty {
      Text(verbatim: text)
        .foregroundStyle(.secondary)
        // The unit is not editable and repeats what the field's own accessibility label already
        // says, so it stays out of the accessibility tree rather than sitting beside the field as
        // a second element a caller has to step past.
        .accessibilityHidden(true)
    }
  }
}

#if DEBUG
  #Preview("Entered, empty, and out of range") {
    @Previewable @State var entered: Measurement<UnitLength>? = .init(value: 4520, unit: .feet)
    @Previewable @State var empty: Measurement<UnitLength>?
    @Previewable @State var pressure = Measurement(value: 29.92, unit: UnitPressure.inchesOfMercury)
    @Previewable @State var tooCold: Measurement<UnitTemperature>? = .init(
      value: -80,
      unit: .celsius
    )

    Form {
      LabeledContent("Entered") {
        MeasurementField(
          "Feet MSL",
          value: $entered,
          in: .feet,
          format: .measurement(width: .abbreviated, usage: .asProvided)
        )
      }
      LabeledContent("Empty") {
        MeasurementField(
          "Feet MSL",
          value: $empty,
          in: .feet,
          format: .measurement(width: .abbreviated, usage: .asProvided)
        )
      }
      LabeledContent("Always present") {
        MeasurementField(
          "Altimeter",
          value: $pressure,
          in: .inchesOfMercury,
          format: .measurement(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(2))
          )
        )
      }
      LabeledContent("Below minimum") {
        MeasurementField(
          "Celsius",
          value: $tooCold,
          in: .celsius,
          format: .measurement(width: .abbreviated, usage: .asProvided),
          minimum: .init(value: -50, unit: .celsius)
        )
      }
    }
  }
#endif
