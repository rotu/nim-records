import std/unittest
import records/lenientTuple


test "testEquality":
    let x = (a: "a", b: "b")
    let y = (b: "b", a: "a")
    check x ==~ y

test "testAssignment":
    let x = (a: 1, b: 2)
    let y = (b: 2, a: 1)
    check x[0] != y[0]

    let yAsX = y.to(typeof x)
    check (typeof yAsX) is (typeof x)
    check yAsX[0] == x[0]

    let y2AsX = y.to(typeof x)
    check (typeof y2AsX) is (typeof x)
    check y2AsX[0] == x[0]

test "assignfrom":
    var dest = (x: 1, y: 2)
    let src = (x: 3)
    dest <~ src
    check dest == (x: 3, y: 2)

test "getsetbyname":
    var x = (a: 1, b: "boo")
    check x["a"] == 1
    check x["b"] == "boo"
    x["b"] = "bang!"
    check x.b == "bang!"

    check not compiles(x["c"])
    check not compiles(x["c"] = 4)

test "len":
    var x = ()
    check len(x) == 0
    check len(typeof(x)) == 0
    check len((x: 1)) == 1
    check len(typeof (x: 1)) == 1
    check len((1, 2, 3)) == 3
    check len(typeof (1, 2, 3)) == 3

