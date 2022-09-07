import std/[options, sequtils, sugar, tables]
import ./seqSet, ./tupleops

# single-record operations generalized to operations on groups of records
proc project*(rows: openArray[tuple], keys: static openArray[string]): auto =
  rows.map((x: auto) => x.project keys)

proc reject*(rows: openArray[tuple], keys: static openArray[string]): auto =
  rows.map((x: auto) => x.reject keys)

proc rename*(rows: openArray[tuple], newOldPairs: static openArray[(string,
  string)]): auto =
  rows.map((x: auto) => x.rename newOldPairs)

proc join*(rows1: openArray[tuple], rows2: openArray[tuple]): auto =
  var res: seq[join(rows1[0], rows2[0]).T]
  for row1 in rows1:
    for row2 in rows2:
      let maybeRow = row1.join(row2)
      maybeRow.map(proc(row: auto) = res.add(row))
  res

proc groupBy*(rows: openArray[tuple], keys: static openArray[string]): auto =
  type T = typeof(rows[0])
  const otherKeys = tupleKeys(T).difference(keys)
  type K = typeof(project(rows[0], keys))
  type V = typeof(project(rows[0], otherKeys))

  var res: Table[K, seq[V]]

  for row in rows:
    let k = project(row, keys)
    let v = project(row, otherKeys)
    mgetOrPut(res, k, @[]).add(v)

  return res

proc where*[T](rows: openArray[T], predicate: T->bool): seq[T] =
  ## get all rows for which the predicate is true
  filter(rows, predicate)
