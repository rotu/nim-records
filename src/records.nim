import std/tables
import macros
import std/sets
import records/tupleops
import std/typetraits

type KeySet = HashSet[string]

# proc intersection *(s1:KeySet, s2:KeySet):KeySet =
#   var s = intersection(toHashSet(s1), toHashSet(s2)).toSeq
#   s.sort
#   KeySet(s)

# proc union *(s1:KeySet, s2:KeySet):KeySet =
#   union(toHashSet(s1), toHashSet(s2)).toSeq

type Record[T:tuple] = object
  data: T

proc toRecord*[T:tuple](x:T): auto = 
  let sorted = sortFields(x)
  Record[typeof(sorted)](data: sorted)

proc toTuple*[T:tuple](x:Record[T]): T =
  x.data

proc `==`*[T1,T2](t1:Record[T1], t2:Record[T2]): bool =
  for x1,x2 in fields(t1.data,t2.data):
    if x1 != x2:
        return false
  true

proc keyset*[T](): KeySet =
  tupleKeys[T]().toHashSet

proc keyset*[T](t:Record[T]): KeySet = 
  keyset[T]()

proc `[]`*[T](r:Record[T], key:static string): auto =
  get[T](r, key)

proc get *[T](r:Record[T], key:static string): auto =
  r.data[key]

proc merge *[T1,T2](r1:Record[T1], r2:Record[T2]): auto =
  toRecord(concat(r1.data, r2.data))

proc proj*[T](r:Record[T], keys:static KeySet): auto =
  toRecord(toTuple(r).project(keys.toSeq()))

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