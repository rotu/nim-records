import std/[options, sequtils, sugar, tables]
import ./seqSet, ./tupleops

# single-record operations generalized to operations on groups of records
proc project*(t: openArray[tuple], keys: static openArray[string]): auto =
 t.map((x: auto) => x.project keys)

proc rename*(t: openArray[tuple], newOldPairs: static openArray[(string,
  string)]): auto =
 t.map((x: auto) => x.rename newOldPairs)

proc join*(table1: openArray[tuple], table2: openArray[tuple]): auto =
 var res: seq[typeof unsafeGet(join(table1[0], table2[0]))]
 for row1 in table1:
  for row2 in table2:
   let maybeRow = row1.join(row2)
   if (isSome maybeRow):
    res.add(unsafeGet maybeRow)
 res

proc groupBy*(tbl: openArray[tuple], keys: static openArray[string]): auto =
 type T = typeof(tbl[0])
 const otherKeys = tupleKeys(T).difference(keys)
 type K = typeof(block: (for row in tbl: project(row, keys)))
 type V = typeof(block: (for row in tbl: project(row, otherKeys)))
 type VV = seq[V]

 var res: Table[K, VV]

 for row in tbl:
  let k = project(row, keys)
  let v = project(row, otherKeys)
  mgetOrPut[K, VV](res, k, @[]).add(v)

 return res
