import Foundation

/**
 The text a numeric field shows for a number, and the number it reads back from what was typed.

 This is the whole of a field's format-and-parse behavior, kept out of the view so it can be
 exercised on its own: a `body` driven by `@State` and focus cannot be.

 Half-typed text is the reason it exists. Writing the field from the bound value on every
 keystroke deletes the decimal separator the instant it is typed — “29.” formats straight back to
 “29”, and the fraction can never be reached — so ``text(for:whileTyping:isEditing:)`` leaves what
 is in the field alone while it is being typed into, and elsewhere whenever that text already
 writes the value the field is bound to.
 */
struct ScalarEntry<Value: BinaryFloatingPoint> {
  /// How the number is written, and — through its parse strategy — read.
  let format: FloatingPointFormatStyle<Value>

  /**
   The keys the field offers, and with them whether the number read back carries a fraction.

   A whole-number pad is the field's declaration that its value has none, and the parse honors that
   declaration on every platform rather than only on those where the keyboard can withhold the
   separator key. It defaults to the pad that withholds nothing, for the callers that only write
   text.
   */
  var keypad: NumericKeypad = .signedDecimal

  /// The text `value` is written as; empty where there is no value.
  func text(for value: Value?) -> String {
    value.map(format.format) ?? ""
  }

  /**
   The number `text` writes, or `nil` where it writes none.

   An empty field, a lone minus sign and outright nonsense all write nothing, which is what an
   optionally-bound field shows as empty and a non-optionally-bound one declines to write. A
   fraction typed where the keypad offers no separator to type it with is rounded away rather than
   reaching the value, so a whole-number field means the same thing under a Mac keyboard as it does
   under a number pad.
   */
  func value(from text: String) -> Value? {
    guard let parsed = try? format.parseStrategy.parse(text) else { return nil }
    return keypad.isFractional ? parsed : parsed.rounded()
  }

  /**
   The text to show for `value` while `typed` sits in the field.

   A field being typed into is never rewritten from the value it is bound to. That value is only as
   fresh as the last time the view was invalidated, and a binding whose write is echoed back
   asynchronously — a preference, a store, anything but plain `@State` — invalidates a keystroke
   behind the text, so rewriting from it puts a stale number under a caret that has moved on.

   - Parameters:
     - value: the value the field is bound to.
     - typed: the text currently in the field.
     - isEditing: whether the field holds focus.
   - Returns: `typed` itself while the field is being typed into, and while its text already writes
     `value`; freshly written text where the value has moved out from under an idle field.
   */
  func text(for value: Value?, whileTyping typed: String, isEditing: Bool) -> String {
    guard !isEditing, self.value(from: typed) != value else { return typed }
    return text(for: value)
  }
}
