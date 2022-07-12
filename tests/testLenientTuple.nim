import unittest

import records/lenientTuple


test "testEquality":
    let x = (a: "a", b: "b")
    let y = (b: "b", a: "a")
    check x == y


test "testAssignment":
    let x = (a: 1, b: 2)
    let y = (b: 2, a: 1)
    check x[0] != y[0]
    let yAsX = toTuple[typeof(x)](y)
    check (typeof yAsX) is (typeof x)
    check yAsX[0] == x[0]
