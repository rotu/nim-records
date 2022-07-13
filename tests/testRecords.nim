import unittest
import sugar
import records
import std/options
import std/sequtils
import std/tables

test "canmakerecord":
  let mytuple = (x: 1, y: 2)
  var p = (mytuple).toRecord
  check p == p
  # check callAll(f) == n

test "get":
  let x = toRecord((a: 1, b: "B"))
  check get(x, "a") == 1
  check x["a"] == 1
  check get(x, "b") == "B"
  check x["b"] == "B"


test "keys":
  let x = toRecord((a: 1, b: 2))
  let y = toRecord((b: 1, a: 6))
  check keys(x) == keys(y)
  check x == x.proj(keys(x))

test "union order varies":
  let x = (a: 1).toRecord
  let y = (b: 2).toRecord
  let z = (c: 3).toRecord

  check(x.merge(y).merge(z) == z.merge(x).merge(y))
  check (x & y == y & x)

test "join":
  let x = (a: 1, b: 2).toRecord
  check join(x, x) == some(x)

test "joinSequences":
  var squares = collect:
    for i in -3..3:
      (x: i, y: (i*i)).toRecord
  check len(squares) == 7
  let squares2 = collect:
    for i in -3..3:
      (y: i*i, z: i).toRecord
  let foo = join(squares, squares2)

  # 0 has one square all other values have 2 squares
  check len(foo) == 13

  for rec in foo:
    check rec["x"]*rec["x"] == rec["y"]
    check rec["z"]*rec["z"] == rec["y"]

test "proj":
  let table = collect:
    for i in -3..3:
      (x: i, y: (i*i)).toRecord
  let xs = proj(table, toKeySet(["x"]))

test "groupby":
  let table = [
    (x: 1, y: 2).toRecord,
    (x: 1, y: 3).toRecord,
    (x: 2, y: 2).toRecord
  ]
  let grouped = groupBy(table, toKeySet(["x"]))
  let k1 = (x: 1).toRecord
  let k2 = (x: 2).toRecord
  echo typeof(grouped)
  check((grouped[k1]).len == 2)
  check(grouped[k2].len == 1)
