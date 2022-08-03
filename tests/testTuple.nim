import std/[macros, options, sugar, typetraits, unittest]
import records/[seqSet, tupleops]

test "tupleKeys":
  let x = (a: 1, b: 2)
  type T = typeof(x)

  check tupleKeys(typeof(x)) == @["a", "b"]
  check tupleKeys(T) == @["a", "b"]
  check tupleKeys(tuple[b: int, a: string]) == @["b", "a"]
  check len(tupleKeys(())) == 0


test "tuplecat1":
  check concat((), ()) == ()

  type Person = tuple[nam: string, age: int]
  type Person2 = tuple[ssn: string]
  let x = (1, 2, 3)
  let y = (4, 5, 6)

  check concat(x, y) == (1, 2, 3, 4, 5, 6)

  var t: Person = ("foo", 3)
  let t2: Person2 = ("123453456", )
  check concat(t, t2) == (nam: "foo", age: 3, ssn: "123453456")
  let empty = ()
  const otherempty = ()
  check concat(empty, otherempty) == ()

  let nums1 = (1, "b", 3)
  check concat(nums1, nums1) == (1, "b", 3, 1, "b", 3)
  check (nums1 & nums1) == (1, "b", 3, 1, "b", 3)

test "projection":
  let x = (a: 1, b: "hi", c: true)
  check x.project([]) == ()
  check (()).project([]) == ()
  check x.project(["a", "c"]) == (a: 1, c: true)
  check x.project(x.tupleKeys) == x
  check x.project(["c", "b", "a"]) == (c: true, b: "hi", a: 1)
  check x.reject(["a"]) == x.project(["b", "c"])

test "concatenation":
  let c = concat( (1, 2), (3, "a"))
  check c == (1, 2, 3, "a")

test "join":
  let x = (a: 1, b: 2)
  check join(x, x) == some(x)
  let ab = (a: 1, b: 2)
  let bc = (b: 2, c: 3)
  let abc = (a: 1, b: 2, c: 3)
  check join(ab, bc) == some(abc)

test "rename":
  let x = (a: 1, b: 2)
  let x1 = x.reject(["b"]).concat((c: x.b))
  check x1 == (a: 1, c: 2)
