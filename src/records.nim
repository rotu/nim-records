import std/tables
import macros
import std/sets
import records/tupleops
import std/options
import std/sequtils
import records/seqSet

export seqSet
type KeySet * = static[SeqSet]

type Record[T: tuple] = object
   ## A record is a mapping of static keys to typed values
   data: T

proc toRecord*[T: tuple](x: T): auto =
   let sorted = sortFields(x)
   Record[typeof(sorted)](data: sorted)

proc toTuple*[T: tuple](x: Record[T]): auto =
   x.data

proc `==`*[T1, T2](t1: Record[T1], t2: Record[T2]): bool =
   for x1, x2 in fields(t1.data, t2.data):
      if x1 != x2:
         return false
   true

proc keys*[T: tuple](R: typedesc[Record[T]]): KeySet = static(tupleKeys(
      T).toKeySet())
template keys*[](r: Record): KeySet = static(keys(typeof(r)))

proc get *[T](r: Record[T], key: static string): auto =
   ## Given a key, retrieve its value from a record
   let (x,) = proj(r.data,@[key])
   x

proc `[]`*[T](r: Record[T], key: static string): auto = 
   ## Given a key, retrieve its value from a record
   ## alias for 
   get[T](r, key)


proc merge*[T1, T2](r1: Record[T1], r2: Record[T2]): auto =
   toRecord(concat(r1.data, r2.data))

proc `&` *[T1, T2](r1: Record[T1], r2: Record[T2]): auto =
   merge(r1, r2)

proc proj*[T](r: Record[T], keys: KeySet): auto =
   toRecord(toTuple(r).proj(@keys))

proc join*[R1: Record, R2: Record](r1: R1, r2: R2): auto =
   const keys1 = difference(keys(R1), keys(R2))
   const keys2 = difference(keys(R2), keys(R1))
   const keysOverlap = intersection(keys(R1), keys(R2))

   let common1 = r1.proj(keysOverlap)
   let common2 = r2.proj(keysOverlap)

   let maybevalue = (r1.proj(keys1) & common1 & r2.proj(keys2))
   if common1 == common2:
      some(maybevalue)
   else:
      none(typeof(maybevalue))