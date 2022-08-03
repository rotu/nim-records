import std/[options, sequtils, sugar, tables]
import ./seqSet, ./tupleops


# single-record operations generalized to operations on groups of records
proc project*(t: openArray[tuple], keys: TupleKeysIn): auto =
 t.map((x: auto) => project(x, keys))

proc join*(table1: openArray[tuple], table2: openArray[tuple]): auto =
 let res = collect:
  for row1 in table1:
   for row2 in table2:
    let mayberow = row1.join(row2)
    if (isSome(mayberow)):
     unsafeGet(mayberow)
 res

proc groupBy*(tbl: openArray[tuple], keys: TupleKeysIn): auto =
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
