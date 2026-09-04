public import Foundation
public import SwiftUI

/**
 A text field that edits a bare number, carrying the same entry behavior as ``MeasurementField``
 without a unit beside it.

 It exists because the entry behavior cannot be handed out on its own. Selecting the field's
 contents on focus is scoped to the field through its own `TextSelection`, and whether the bound
 value may rewrite what is in the field turns on whether the field holds focus; neither is
 something a modifier applied to somebody else's `TextField` can reach — so a value with no
 dimension to it gets a field of its own rather than a modifier.
 */
public struct NumericField<Value: BinaryFloatingPoint>: View {
  /// The field's placeholder while it is empty, and its accessibility label throughout.
  private let label: LocalizedStringKey

  /// The edited value, `nil` while the field writes no number.
  @Binding private var value: Value?

  /// How the value is written — and, through its parse strategy, read back.
  private let format: FloatingPointFormatStyle<Value>

  /// The keypad the caller asked for, or `nil` to take the one the format calls for.
  private let requestedKeypad: NumericKeypad?

  /// The bounds outside which the entered value shows as invalid, if any.
  private let minimum: Value?, maximum: Value?

  @Environment(\.locale)
  private var locale

  @State private var text: String

  /// Whether the field holds focus. It lives out here rather than inside the text field because
  /// the value may only rewrite the text while it does not.
  @FocusState private var isEditing: Bool

  public var body: some View {
    NumericTextField(
      label,
      prompt: value == nil ? label : "",
      text: $text,
      isEditing: $isEditing,
      keypad: keypad
    )
    .foregroundStyle(isValid ? AnyShapeStyle(.foreground) : AnyShapeStyle(.red))
    .onChange(of: text) { _, typed in value = entry.value(from: typed) }
    .onChange(of: value) { _, entered in
      text = entry.text(for: entered, whileTyping: text, isEditing: isEditing)
    }
    // Leaving the field hands the say back to the value: what was typed is written out afresh, and
    // any change made from elsewhere while the field was held appears.
    .onChange(of: isEditing) { _, editing in
      if !editing { text = entry.text(for: value) }
    }
    .onChange(of: locale, initial: true) { text = entry.text(for: value) }
  }

  /// The format the field's text is written with, and the keypad it is read under.
  private var entry: ScalarEntry<Value> {
    .init(format: format.locale(locale), keypad: keypad)
  }

  /// The keys the field raises: the ones the caller named, or the ones this value's own format and
  /// bounds call for.
  private var keypad: NumericKeypad {
    requestedKeypad
      ?? .init(fractional: format.writesFractions(in: locale), signed: allowsNegatives)
  }

  /// Whether the field needs a minus sign. Unless the caller has ruled negatives out with a
  /// minimum of zero or more, one belongs in range.
  private var allowsNegatives: Bool {
    guard let minimum else { return true }
    return minimum < 0
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
   Creates a field editing a number that may be absent.

   - Parameters:
     - label: the placeholder shown while the field is empty, and its accessibility label.
     - value: the edited value, `nil` while the field is empty.
     - format: how the value is written, and through its parse strategy how it is read back.
     - keypad: the keys to raise; by default, the ones `format` and `minimum` call for.
     - minimum: the value below which the field shows as invalid, if any.
     - maximum: the value above which the field shows as invalid, if any.
   */
  public init(
    _ label: LocalizedStringKey,
    value: Binding<Value?>,
    format: FloatingPointFormatStyle<Value>,
    keypad: NumericKeypad? = nil,
    minimum: Value? = nil,
    maximum: Value? = nil
  ) {
    self.label = label
    _value = value
    self.format = format
    requestedKeypad = keypad
    self.minimum = minimum
    self.maximum = maximum

    _text = .init(initialValue: ScalarEntry(format: format).text(for: value.wrappedValue))
  }

  /**
   Creates a field editing a number that is always present.

   Emptying the field leaves the value as it stands: there is no absence to write into a value that
   cannot be absent.

   - Parameters:
     - label: the placeholder shown while the field is empty, and its accessibility label.
     - value: the edited value.
     - format: how the value is written, and through its parse strategy how it is read back.
     - keypad: the keys to raise; by default, the ones `format` and `minimum` call for.
     - minimum: the value below which the field shows as invalid, if any.
     - maximum: the value above which the field shows as invalid, if any.
   */
  public init(
    _ label: LocalizedStringKey,
    value: Binding<Value>,
    format: FloatingPointFormatStyle<Value>,
    keypad: NumericKeypad? = nil,
    minimum: Value? = nil,
    maximum: Value? = nil
  ) {
    self.init(
      label,
      value: Binding<Value?>(
        get: { value.wrappedValue },
        set: { entered in if let entered { value.wrappedValue = entered } }
      ),
      format: format,
      keypad: keypad,
      minimum: minimum,
      maximum: maximum
    )
  }
}

#if DEBUG
  #Preview("Entered, empty, and out of range") {
    @Previewable @State var entered: Double? = 1.35
    @Previewable @State var empty: Double?
    @Previewable @State var count = 12.0

    Form {
      LabeledContent("Load factor") {
        NumericField("g", value: $entered, format: .number.precision(.fractionLength(2)))
      }
      LabeledContent("Empty") {
        NumericField("Ratio", value: $empty, format: .number.precision(.fractionLength(0...2)))
      }
      LabeledContent("Above maximum") {
        NumericField(
          "Seats",
          value: $count,
          format: .number.precision(.fractionLength(0)),
          minimum: 0,
          maximum: 6
        )
      }
    }
  }
#endif
