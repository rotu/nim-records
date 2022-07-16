import unittest
import records
import std/options
import std/sequtils
import std/tables
import records/seqSet
import records/lenientTuple
import std/sugar
import records/tupleops
import std/typetraits
import macros

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
  echo "concatting"
  check concat(nums1, nums1) == (1, "b", 3, 1, "b", 3)
  check (nums1 & nums1) == (1, "b", 3, 1, "b", 3)



# test "tuplecat":
#   let c = concat( (1, 2) , (3, "a") )
#   echo (c[3] & "foo")
#   let d = (a:1,b:2)
#   let d2 = (c:3,d:5)

#   # for f,g in fieldPairs(d):
#   #   echo f," ="
#   # echo dumpTypeInst(d)
#   echo merge(d, d2)
#   let r = R(a:1,b:5)
#   # echo merge (r,d2)
#   for k,v in d.fieldPairs:
#     echo k,":=",v
#   # echo merge(r, (c:5,d:1))
#   call(echo,(1,2,3))


# test "reshuffle":
#   let z = (x:1, y:2)
#   let y = (y:2,x:1)
#   check y == reshuffle[typeof(y), typeof(z)](z)

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
  let ab = (a:1,b:2)
  let bc = (b:2,c:3)
  let abc = (a:1,b:2,c:3)
  check join(ab,bc) == some(abc)


test "joinSequences":
  var squares = collect:
    for i in -3..3:
      (x: i, y: (i*i))
  check len(squares) == 7
  let squares2 = collect:
    for i in -3..3:
      (y: i*i, z: i)
  let foo = join(squares, squares2)

  # 0 has one square all other values have 2 squares
  check len(foo) == 13

  for rec in foo:
    check rec["x"]*rec["x"] == rec["y"]
    check rec["z"]*rec["z"] == rec["y"]

test "proj":
  let table = collect:
    for i in -3..3:
      (x: i, y: (i*i))
  let xs = proj(table, ["x"])

test "groupby":
  let table = [
    (x: 1, y: 2),
    (x: 1, y: 3),
    (x: 2, y: 2)
  ]
  let grouped = groupBy(table, @["x"])
  let k1 = (x: 1)
  let k2 = (x: 2)
  echo typeof(grouped)
  check((grouped[k1]).len == 2)
  check(grouped[k2].len == 1)

