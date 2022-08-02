import std/[macros, options, sugar, typetraits, unittest]
import records/seqSet
import records/lenientTuple
import records/tupleops

# test "call":
#   proc fn(a:string, b:string, c:string) =
#     check a=="a"
#     check b=="b"
#     check c=="c"

#   call(fn,("a","b"),(c:"c"))

test "tupleKeys":
  let x = (a: 1, b: 2)
  type T = typeof(x)
  check tupleKeys(typeof(x)) == @["a", "b"]
  check tupleKeys(T) == @["a", "b"]
  check tupleKeys(tuple[b: int, a: string]) == @["b", "a"]

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
  check x.proj([]) == ()
  check (()).proj([]) == ()
  check x.proj(["a", "c"]) == (a: 1, c: true)
  check x.proj(x.tupleKeys) == x
  check x.proj(["c", "b", "a"]) == (c: true, b: "hi", a: 1)
  check x.reject(["a"]) == x.proj(["b", "c"])


test "concatenation":
  let c = concat( (1, 2), (3, "a"))
  check c == (1, 2, 3, "a")
  let d = (a: 1, b: 2)
  let d2 = (c: 3, d: 5)

test "get":
  let x = ((a: 1, b: "B"))
  check (get(x, "a")) == 1
  check x["a"] == 1
  check get(x, "b") == "B"
  check x["b"] == "B"

test "union order varies":
  let x = (a: 1)
  let y = (b: 2)
  let z = (c: 3)

  check((x & y & z) ==~ (z & x & y))
  check ((x & y) ==~ (y & x))

test "join":
  let x = (a: 1, b: 2)
  check join(x, x) == some(x)
  let ab = (a: 1, b: 2)
  let bc = (b: 2, c: 3)
  let abc = (a: 1, b: 2, c: 3)
  check join(ab, bc) == some(abc)

