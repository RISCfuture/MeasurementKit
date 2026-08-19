# Arithmetic

The relations between dimensions that MeasurementKit defines.

## Overview

Each relation is a concrete operator overload rather than a generic scheme. That is what lets a
force be both a mass under an acceleration and a pressure over an area — a protocol-based approach
admits only one definition per type, and physics does not oblige.

It also means an unsupported product simply fails to compile rather than trapping at runtime, and
that two relations differing only in their result type cannot both exist. Two are excluded for
exactly that reason: a slope, because a length over a length already answers a dimensionless ratio
(use ``Foundation/Measurement/slope(over:)``), and a torque, because it is dimensionally
indistinguishable from the energy that `force * length` already answers.

## Topics

### Kinematics

- ``/(_:_:)-(Measurement<UnitLength>,Measurement<UnitDuration>)``
- ``*(_:_:)-(Measurement<UnitSpeed>,Measurement<UnitDuration>)``

### Time

- ``Foundation/Date/elapsed(since:)``
- ``Foundation/Date/remaining(until:)``

### Angles and Trigonometry

- ``Foundation/Measurement/normalized``
- ``Foundation/Measurement/signedNormalized``
- ``Foundation/Measurement/reciprocal``
- ``Foundation/Measurement/rotated(by:)``
- ``sin(_:)``
- ``cos(_:)``
- ``tan(_:)``

### Accumulation

- ``Foundation/Measurement/zero``
- ``Foundation/Measurement/zero(in:)``
- ``Foundation/Measurement/adding(_:)``
- ``Foundation/Measurement/subtracting(_:)``
- ``Swift/Sequence/sum(in:)``

### Rounding

- ``Foundation/Measurement/rounded(toMultipleOf:rule:)``
- ``Foundation/Measurement/clamped(to:)``
