import SwiftUI

#if canImport(UIKit)
  import UIKit
#endif

/**
 The text field every numeric entry control in this library is built on: the keypad the value
 needs, digits set against the trailing edge where the eye compares them, and the whole value
 selected when the field takes focus so that typing replaces it instead of appending to it.

 Selecting on focus is scoped to this field through its own `TextSelection`, not broadcast: a
 screen editing a value beside a search field must not select the search field's contents out
 from under whoever is typing in it.

 Focus itself belongs to the control built on this field rather than to this field, because
 whether the value may overwrite the text depends on it. The focus state is owned one level up and
 bound in here, which leaves this the only view applying `focused(_:)` to the text field — a
 caller's own `focused(_:)`, applied to the control from outside, goes on binding as it did.
 */
struct NumericTextField: View {
  /// What the field is called to VoiceOver.
  let label: LocalizedStringKey

  /// The placeholder shown while the field is empty; empty to show none.
  let prompt: LocalizedStringKey

  /// The text being edited.
  @Binding var text: String

  /// Whether the field holds focus, owned by the control this field is built into.
  @FocusState.Binding var isEditing: Bool

  /// The keys the value needs.
  let keypad: NumericKeypad

  #if !os(watchOS) && !os(tvOS)
    @State private var selection: TextSelection?
  #endif

  var body: some View {
    #if os(watchOS) || os(tvOS)
      // `TextSelection` and the field initializer that takes one do not exist here, so the field
      // is the plain one and focus selects nothing.
      TextField(prompt, text: $text)
        .focused($isEditing)
        .numericKeypad(keypad)
        .multilineTextAlignment(.trailing)
        .accessibilityLabel(Text(label))
    #else
      TextField(prompt, text: $text, selection: $selection)
        .focused($isEditing)
        .onChange(of: isEditing) { _, editing in
          guard editing, !text.isEmpty else { return }
          selection = TextSelection(range: text.startIndex..<text.endIndex)
        }
        .numericKeypad(keypad)
        .multilineTextAlignment(.trailing)
        .accessibilityLabel(Text(label))
        .doneButton(ending: $isEditing)
    #endif
  }

  /// Creates a numeric text field.
  ///
  /// - Parameters:
  ///   - label: what the field is called to VoiceOver.
  ///   - prompt: the placeholder shown while the field is empty; empty to show none.
  ///   - text: the text being edited.
  ///   - isEditing: whether the field holds focus.
  ///   - keypad: the keys the value needs.
  init(
    _ label: LocalizedStringKey,
    prompt: LocalizedStringKey,
    text: Binding<String>,
    isEditing: FocusState<Bool>.Binding,
    keypad: NumericKeypad
  ) {
    self.label = label
    self.prompt = prompt
    _text = text
    _isEditing = isEditing
    self.keypad = keypad
  }
}

#if os(iOS) || os(tvOS) || os(visionOS)
  extension NumericKeypad {
    /// The keyboard offering these keys. No pad carries a minus sign, so a signed value falls to
    /// the narrowest keyboard that does.
    var keyboardType: UIKeyboardType {
      switch self {
        case .whole: .numberPad
        case .decimal: .decimalPad
        case .signedWhole, .signedDecimal: .numbersAndPunctuation
      }
    }
  }
#endif

extension NumericKeypad {
  /// The accessibility identifier of the Done button above a numeric field's keyboard, for a UI test
  /// to end editing through the same control a person would.
  public static let doneButtonIdentifier = "MeasurementKit.NumericField.done"
}

extension View {
  /// Puts a Done button above the keyboard while the field is being edited.
  ///
  /// The number and decimal pads have no key of their own to end editing, so without it a field
  /// raising one can only be left by tapping elsewhere or scrolling. Signed values raise a keyboard
  /// that does have a Return key, and carry the button anyway, so every numeric field is left the
  /// same way.
  ///
  /// Only the field holding focus offers one. Every field in a form adds to the same bar above the
  /// keyboard, and a button from each would stack up there.
  ///
  /// It is a plain button, which the keyboard bar draws in clear glass. The confirming role would
  /// bring a translated label with it, but the bar draws a confirming button as a large tinted
  /// checkmark, and offers no way to draw it plainly. The label is looked up in the app's own
  /// string catalog, the same way as the labels an app passes its fields, so an app that localizes
  /// translates "Done" alongside its own strings.
  func doneButton(ending isEditing: FocusState<Bool>.Binding) -> some View {
    #if os(iOS)
      toolbar {
        ToolbarItemGroup(placement: .keyboard) {
          if isEditing.wrappedValue {
            Spacer()
            Button("Done") { isEditing.wrappedValue = false }
              .accessibilityIdentifier(NumericKeypad.doneButtonIdentifier)
          }
        }
      }
    #else
      self
    #endif
  }

  /// Raises the keyboard offering `keypad`'s keys, on the platforms that have a choice of
  /// keyboard to raise. Elsewhere the keypad is inert, so a cross-platform call site names it
  /// once and compiles everywhere.
  func numericKeypad(_ keypad: NumericKeypad) -> some View {
    #if os(iOS) || os(tvOS) || os(visionOS)
      keyboardType(keypad.keyboardType)
    #else
      self
    #endif
  }
}
