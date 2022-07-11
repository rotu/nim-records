import unittest
import sugar
import records

test "canmakerecord":
  let mytuple = (x:1, y:2)
  var p = (mytuple).toRecord
  check p == p
  # check callAll(f) == n

test "keyset":
  let x = toRecord((a:1,b:2))
  let y = toRecord((b:1,a:6))
  check keyset(x) == keyset(y)

test "union order varies":
  let x = (a:1).toRecord
  let y = (b:2).toRecord
  let z = (c:3).toRecord
  
  check(x.merge(y).merge(z) == z.merge(x).merge(y))
