# ``MeasurementKitDefaults``

@Metadata {
    @DisplayName("MeasurementKitDefaults")
}

Storage of measurements and units in `UserDefaults` through `Defaults`, in a
format that survives a Foundation release.

## Overview

A measurement is a number and a unit, and a preference holds one value.
Everything hard about storing measurements follows from that: the unit has to be
recovered somehow, and every way of recovering it that Foundation makes
convenient is a way of losing it later.

MeasurementKitDefaults takes the two positions that hold up.

A measurement whose dimension has one unit across your whole app is stored as a
bare number in that unit. Nothing about the unit is written, because nothing
about it can change:

```swift
extension UnitLength: CanonicalUnit {
  public static var canonical: UnitLength { .feet }
}

extension Defaults.Keys {
  static let runwayMinimum = Key<Measurement<UnitLength>>(
    "runwayMinimum",
    default: .init(value: 3000, unit: .feet)
  )
}
```

A measurement handed to that key in any other unit is converted on the way down,
so a runway minimum entered as one mile is stored as `5280` and read back as
five thousand two hundred eighty feet. A preference an earlier build wrote as a
plain `3000`, before the value was a `Measurement` at all, reads back unchanged
— `UserDefaults` bridges an integer and a double through the same `NSNumber`, so
no migration stands between the old format and the new one.

A unit the reader chose is stored by a package-owned identifier from a registry,
never by `Unit.symbol`. See below.

## Declaring canonical units

> Important: MeasurementKitDefaults ships no `CanonicalUnit` conformance for any
> of Foundation's unit classes. Not `UnitLength`, not `UnitSpeed`, none. Declare
> the ones your app needs, in your app, in one file.

Two reasons, and either one is enough.

The conformance decides your on-disk format. `UnitLength.canonical` is the unit
every stored length already means, so a conformance arriving from a package
would silently change what every existing preference says — a stored `3000`
that meant feet would start meaning metres. A package cannot know which unit you
have been writing, and cannot ship a default that is harmless.

The conformance is also retroactive, and a retroactive conformance to a type the
package does not own collides with any other library that declares the same one.
Two dependencies conforming `UnitLength` to `CanonicalUnit` is not a conflict
you can resolve; short of forking one of them, there is no fix. Only you are in
a position to declare it exactly once.

If you are already storing measurements, write down what you are storing before
you choose. Storing display units — feet and knots — makes the declaration a
formality. Storing Foundation's `baseUnit()` means you have been writing metres
and metres per second, and adopting a different canonical unit is a data
migration, not a refactor.

## Adopting this target is all-or-nothing

Linking MeasurementKitDefaults means this package owns the conformance of
`Measurement` to `Defaults.Serializable`. Swift permits exactly one conformance
of a type to a protocol, whatever the conditional bounds, so an app that already
declares its own — a `MeasurementBridge` of its own over a protocol of its own —
cannot link this target as well:

```text
error: conflicting conformance of 'Measurement<UnitType>' to protocol
'Serializable'; there cannot be more than one conformance, even with different
conditional bounds
```

This is a compile error rather than something that surfaces at runtime, which is
the good outcome: an app storing measurements under a policy of its own finds
out at the point of adoption, not from a preference that silently changes
meaning. Take this target and delete your bridge, or keep your bridge and take
only the core; there is no arrangement that keeps both.

An app whose stored numbers are already canonical-unit measurements can make
that swap without touching what is on disk. An app storing Foundation's
`baseUnit()`, or storing under a policy that varies by dimension, is looking at
a data migration — decide that before deleting anything.

## Storing a unit the reader chose

Where the reader picks the unit — a settings screen offering inches of mercury
or hectopascals — the choice itself is a preference, and ``UnitBridge`` stores
it under the identifier registered for it in `UnitIdentifierRegistry`:

```swift
extension UnitPressure: Defaults.Serializable {
  public static var bridge: UnitBridge<UnitPressure> { .init() }
}
```

The identifier is the whole point of the type. `Unit.symbol` is display text:
Foundation is free to respell it between OS versions, it can be localized, and
it is not unique across dimensions — a slope written `m/m` sits one keystroke
from a length written `m`. A preference recording a symbol records something
that can stop matching, and a unit that stops matching puts the reader back on a
default they never picked, without a word. An identifier changes only when
someone registers a new one.

MeasurementKit's own dimensions and Foundation's common ones are registered
before the first lookup. Register a table to add a dimension of your own, or to
respell an identifier you inherited: later registrations win for new writes, and
preferences holding the older spelling still restore.

## Storing without this package

The core `MeasurementKit` target stores measurements too, with no dependency on
`Defaults` at all: a `Measurement` whose dimension conforms to `UnitIdentifying`
is `RawRepresentable` as JSON, which is what `@AppStorage` takes. Reach for that
where the unit varies from value to value, and for a canonical unit and a bare
number everywhere else.

That conformance is yours to declare, for the same two reasons as
`CanonicalUnit`: the table it supplies *is* the on-disk format, and
`RawRepresentable` on `Measurement` is a conformance to a protocol the package
does not own, on a type it does not own, which a competing persistence library
would want just as much. Narrowing it to the dimensions that asked for it keeps
the claim off every other `Measurement` you use.

A dimension can take both paths at once — a canonical unit for the values stored
as bare numbers, an identifier table for the ones that carry their unit. Where
you register a table with `UnitIdentifierRegistry` *and* conform the same
dimension to `UnitIdentifying`, the two are independent: the conformance decides
what `@AppStorage` writes and the registry decides what ``UnitBridge`` writes.
Register the type itself, rather than a second table, to keep them saying the
same thing.

## Migrating from stored base units

> Warning: If you have been storing Foundation's `baseUnit()`, adopting this
> changes what every already-written preference means. Plan the migration before
> you declare the conformance, not after.

Three separate formats change, and each has to be handled on its own.

**Stored measurements.** A key that held a base-unit number holds metres,
kilograms, or metres per second. Choosing feet as `UnitLength.canonical`
reinterprets every one of those numbers as feet on first launch — a 1000 m
runway silently becomes 1000 ft. Read the old key, convert, write the new one,
and do it under a new key name so the migration is idempotent and the old value
stays recoverable.

**Stored units.** A preference recording `Unit.symbol` holds `kn`, `inHg`, `m`.
None of those are identifiers, so every one of them fails to resolve and falls
back to the key's default — quietly, because a `Defaults.Bridge` cannot report a
failure. Either translate the symbols once at launch, or register the old
symbols as additional identifiers for the units they named, which makes the old
preferences readable without a migration pass at all.

**Symbols that were already ambiguous.** A custom slope unit spelled `m` has
been writing the symbol for a metre. Any translation table written from symbols
has to be read per dimension, never globally.

Detecting rather than absorbing a failed restore means calling
`UnitIdentifierRegistry.unit(_:identifiedBy:)` directly: it throws, where the
bridge can only answer `nil` and let `Defaults` substitute the default.

## Topics

### Storing Measurements

- ``MeasurementBridge``

### Storing Units

- ``UnitBridge``
