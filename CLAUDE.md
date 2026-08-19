- Operators answer in a unit derived from the LEFT operand, never in the dimension's base
  unit. Kinematic relations answer inside the left operand's coherent family (see
  `Internal/KinematicFamily.swift`); relations involving a `DerivedDimension` read their
  result unit from its numerator and denominator; everything else answers in the base unit.
- Never add `+`, `-`, `+=` or `-=` for `Measurement`. An overload of an operator Foundation
  already defines is ambiguous at every use site in another module, and inside a function
  body it silently resolves to Foundation's instead. Use `adding(_:)`, `subtracting(_:)` and
  `Sequence.sum(in:)`.
- Never add two operators that differ only in their return type — every use of them becomes
  ambiguous. `OperatorCoverageTests` exercises every relation with NO type annotations
  precisely so that this fails the build; do not add annotations to those tests to make an
  error go away.
- `UnitTemperature` must never conform to `ProportionalDimension` and must never get a
  same-dimension ratio. Dividing two readings on an interval scale divides their kelvin
  values and answers a meaningless number. Differences use `UnitTemperatureDifference`.
- Ship no conformance of a Foundation unit class to a protocol this package owns, and no
  `CanonicalUnit` conformance for one. A conformance shipped from here silently changes an
  adopting app's on-disk format, and a retroactive conformance another dependency might also
  claim cannot be resolved short of a fork.
- Never serialize a unit by `Unit.symbol`. Symbols are OS-version dependent and possibly
  localized; use the package's own stable identifiers.
- `affixes(format:in:)` must take the caller's format style. Probing at a different precision
  than the style writes finds "30" inside "30.06" and returns the fraction as the unit.
- Derive imperial force units from Foundation's own `UnitMass.pounds`, not from the SI
  definition. Foundation rounds the pound, and using the exact value leaves "a mass in pounds
  under standard gravity weighs that many pounds-force" wrong by a part in a million.
- Use the exact 9.80665 m/s² for standard gravity, not `UnitAcceleration.gravity`, which
  Foundation rounds to 9.81.
