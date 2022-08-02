import std/[sugar, unittest, sequtils]
import records/collection
import records/lenientTuple
import std/tables

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
  check((grouped[k1]).len == 2)
  check(grouped[k2].len == 1)
