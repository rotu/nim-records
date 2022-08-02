import ./seqSet
import ./tupleops
import std/[options, sugar, tables]
import std/sequtils

# single-record operations generalized to operations on groups of records
proc proj*(t: openArray[tuple], keys: TupleKeysIn): auto =
 t.map((x: auto) => proj(x, keys))

proc join*(table1: openArray[tuple], table2: openArray[tuple]): auto =
 let res = collect:
  for row1 in table1:
   for row2 in table2:
    let mayberow = row1.join(row2)
    if (isSome(mayberow)):
     unsafeGet(mayberow)
 res

proc groupBy*(tbl: openArray[tuple], keys: TupleKeys): auto =
 type T = typeof(tbl[0])
 const otherKeys = tupleKeys(T).difference(keys)
 type K = typeof(block: (for row in tbl: proj(row, keys)))
 type V = typeof(block: (for row in tbl: proj(row, otherKeys)))
 type VV = seq[V]

 var res: Table[K, VV]

 for row in tbl:
  let k = proj(row, keys)
  let v = proj(row, otherKeys)
  mgetOrPut[K, VV](res, k, @[]).add(v)

 return res
