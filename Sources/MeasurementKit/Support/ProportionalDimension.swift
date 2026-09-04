public import Foundation

/**
 A dimension whose measurements sit on a proportional scale — one whose zero is a genuine absence
 of the quantity, so that the ratio of two measurements is the same number in every unit of the
 dimension.

 Ratio arithmetic is only meaningful on such a scale. Temperature is the counterexample the
 protocol exists to exclude: degrees Celsius and degrees Fahrenheit are interval scales with
 displaced zeros, so dividing two readings divides their kelvin values and answers a number that
 means nothing. MeasurementKit therefore ships no generic ratio over every `Dimension`; it ships
 this protocol, concrete overloads for the Foundation dimensions that qualify, and conformances
 for its own dimensions.

 Conform your own `Dimension` subclasses to make them ratio-capable. MeasurementKit deliberately
 conforms none of Foundation's unit classes to it: a retroactive conformance to a type the package
 does not own would collide with any other library that did the same.
 */
public protocol ProportionalDimension: Dimension {}
