import std/[sequtils, sugar, tables, unittest]
import records/[relational, lenientTuple]

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

test "project":
  let table = collect:
    for i in -3..3:
      (x: i, y: (i*i))
  let xs = project(table, ["x"])

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

test "where":
  let rows = [
    (a: 1, b: 2),
    (a: 2, b: 4),
    (a: 3, b: 6)
  ]
  let xs = rows.where(r=>(r.a mod 2 == 1))
  check (a: 1, b: 2) in xs
  check (a: 2, b: 4) notin xs
  check (a: 3, b: 6) in xs
