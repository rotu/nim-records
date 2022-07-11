import unittest
import sugar

import records/tupleops
import std/typetraits
import std/sequtils
import macros

# test "call":
#   proc fn(a:string, b:string, c:string) =
#     check a=="a"
#     check b=="b"
#     check c=="c"

#   call(fn,("a","b"),(c:"c"))

test "fieldnames":
  let x = (a: 1, b: 2)
  type T = typeof(x)
  check getFieldNames[typeof(x)]() == @["a", "b"]
  check getFieldNames[T]() == @["a", "b"]
  check getFieldNames[tuple[b: int, a: string]]() == @["b", "a"]

test "sortfields":
  let x = (a: 1, b: 2, c: 3)
  check sortFields(x) == x
  check sortFields((x: 1, a: 2)) == (a: 2, x: 1)

test "assignfrom":
  var dest = (x: 1, y: 2)
  var src = (x: 3)
  dest <~ src

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


test "test sort":
  let z = (x: 1)
  check sortFields(z) == z
  let b = (x: 1, y: 2, w: "w")
  check sortFields(b) == (w: "w", x: 1, y: 2)
  # check tupleKeys(b) == ['x','y','w']
  # check tupleKeys(sortFields(b)) == ['w','x','y']

# test "reshuffle":
#   let z = (x:1, y:2)
#   let y = (y:2,x:1)
#   check y == reshuffle[typeof(y), typeof(z)](z)
