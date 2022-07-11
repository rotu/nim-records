import std/tables
import macros
import std/sets
import records/tupleops
import std/typetraits
import std/algorithm
import std/options
import std/sequtils

type SortedSeq = distinct seq[string]
type KeySet = static[SortedSeq]

proc `==`*(s: SortedSeq, s2: SortedSeq): bool {.borrow.}
proc `@`*(s: SortedSeq): seq[string] {.borrow.}
converter `toHashSet`(s: SortedSeq): HashSet[string] = s.toHashSet()
proc `toSeq`*(s: SortedSeq): seq[string] = seq[string](s)

proc toKeySet(s1: static[seq[string]]): SortedSeq =
   SortedSeq(sorted(s1))

proc intersection(s1, s2: SortedSeq): SortedSeq =
   var s: seq[string]
   for x in @s1:
      if x in @s2:
         s.add(x)
   SortedSeq(s)

proc union(s1, s2: SortedSeq): SortedSeq =
   let ss1 = concat(@s1, @s2)
   let ss2 = sorted(ss1)
   let ss3 = deduplicate(ss2, isSorted = true)
   SortedSeq(ss3)

proc difference(s1, s2: KeySet): KeySet =
   var s: seq[string]
   for x in @s1:
      if x notin @s2:
         s.add(x)
   SortedSeq(s)

# proc intersection *(s1:KeySet, s2:KeySet):KeySet =
#   var s = intersection(toHashSet(s1), toHashSet(s2)).toSeq
#   s.sort
#   KeySet(s)

# proc union *(s1:KeySet, s2:KeySet):KeySet =
#   union(toHashSet(s1), toHashSet(s2)).toSeq

type Record[T: tuple] = object
   data: T

proc toRecord*[T: tuple](x: T): auto =
   let sorted = sortFields(x)
   Record[typeof(sorted)](data: sorted)

proc Data[T](t: typedesc[Record[T]]): static[typedesc] = T
template Data(r: Record): static[typedesc] = Data(typeof(r))

proc toTuple*[T: tuple](x: Record[T]): auto =
   x.data

proc `==`*[T1, T2](t1: Record[T1], t2: Record[T2]): bool =
   for x1, x2 in fields(t1.data, t2.data):
      if x1 != x2:
         return false
   true

proc keyset*[T: tuple](R: typedesc[Record[T]]): KeySet = static(tupleKeys(
      T).toKeySet())
template keyset*[](r: Record): KeySet = static(keyset(typeof(r)))

proc `[]`*[T](r: Record[T], key: static string): auto =
   get[T](r, key)

proc get *[T](r: Record[T], key: static string): auto =
   r.data[key]

proc merge *[T1, T2](r1: Record[T1], r2: Record[T2]): auto =
   toRecord(concat(r1.data, r2.data))

proc `&` *[T1, T2](r1: Record[T1], r2: Record[T2]): auto =
   merge(r1, r2)

proc proj*[T](r: Record[T], keys: static[SortedSeq]): auto =
   toRecord(toTuple(r).proj(@keys))

proc join*[R1: Record, R2: Record](r1: R1, r2: R2): auto =
   const r1part = difference(keyset(R1), keyset(R2))
   const r2part = difference(keyset(R2), keyset(R1))
   const olap = intersection(keyset(R1), keyset(R2))

   let common1 = r1.proj(olap)
   let common2 = r2.proj(olap)

   let maybevalue = (r1.proj(r1part) & common1 & r2.proj(r2part))
   if common1 == common2:
      some(maybevalue)
   else:
      none(typeof(maybevalue))


# proc macroSchemaFromTupleTypeImpl(ttype: NimNode):Table[string, NimNode] =
#   expectKind(ttype, nnkTupleTy)
#   for f in ttype.children:
#     expectKind(f, nnkIdentDefs)
#     # must be a named tuple!
#     fields[fromSym(f[0])] = f[1]
#   newLit(fields)


# type
#   Node[kind:static NimNodeKind] = distinct NimNode

# proc expect[kind: static NimNodeKind](node:NimNode):Node[kind] =
#   expectKind(node, kind)
#   Node[kind](node)

# type StrLit = Node[nnkStrLit]

# type RecordSchema2 * = Table[string, typedesc]




# import macros

# macro dumpTypeImpl(x: typed): untyped =
#   newLit(x.getTypeImpl.lispRepr)

# macro dumpTypeInst(x: typed): untyped =
#   newLit(x.getTypeInst.lispRepr)

# macro dumpType(x: typed): untyped =
#   newLit(x.getType.lispRepr)

# macro dumpSameType(x:typed, y:typed):untyped =
#   newLit(sameType(x,y))

# type Foo = object
#   x: int

# type Bar = distinct Foo
# type Baz = distinct Foo

# const fizz = (x:1)
# const foo = Foo(x:1)
# const bar = Bar(foo)
# const baz = Baz(foo)

# echo dumpSameType(foo,foo)
# echo dumpSameType(foo,bar)
# echo dumpSameType(bar,bar)
# echo dumpSameType(bar,baz)

# echo "named tuple ...."
# echo dumpTypeImpl(fizz)
# echo dumpTypeInst(fizz)
# echo dumpType(fizz)
# echo "...."
# echo dumpTypeImpl(foo)
# echo dumpTypeInst(foo)
# echo dumpType(foo)
# echo "----"
# echo dumpTypeImpl(bar)
# echo dumpTypeInst(bar)
# echo dumpType(bar)
# echo "----"
# echo dumpTypeImpl(1)
# echo dumpTypeInst(1)
# echo dumpType(1)
