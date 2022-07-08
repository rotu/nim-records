
import std/sequtils
import std/sugar
import std/tables
import macros
import std/sets
import tupleops
import std/typetraits
type RecordSchema * = Table[string, typedesc]

# default values
type
  Foo = enum
    x=0
    y="foo"
    w=2
    z

# https://nim-lang.org/docs/enumutils.html
const h:Foo = Foo.x

#[
    the schema for a record should be either:
        table key -> type
        function enum -> type
        ???


]#

type Record[T] = object
  data: T

proc `[]`[T](r:Record[T], key:static string): auto =
  r.data[key]

proc get[T](r:Record[T], key:static string): auto =
  r.data[key]

proc dataOf[T](r:Record[T]): T = 
  r.data

proc merge *[T1,T2](r1:Record[T1],r2:Record[T2]): auto = 
  Record(merge(r1.data,r2.data))

proc toRecord*(x:tuple): auto = 
  Record[typeof(x)](data: x)

proc tupleKeysToIndices[T:tuple](): Table[string, int] = 
  static: assert isNamedTuple(T), "Must be a named tuple"
  for (i, k) in getTypeImpl(T).pairs:
    result[k[0].repr] = i

proc tupleKeys[T:tuple](): HashSet[string] =
  for k in tupleKeysToIndices[T]().keys:
    result.incl(k)

proc fromSym(n:NimNode):string = 
  expectKind(n,nnkSym)
  n.repr

# proc macroSchemaFromTupleTypeImpl(ttype: NimNode):Table[string, NimNode] = 
#   expectKind(ttype, nnkTupleTy)
#   for f in ttype.children:
#     expectKind(f, nnkIdentDefs)
#     # must be a named tuple!
#     fields[fromSym(f[0])] = f[1]
#   newLit(fields)


macro recordSchemaFromNamedTuple(t: typed): Table[string, NimNode] =
  var fields: Table[string, NimNode]
  let ttype = t.getTypeImpl
  expectKind(ttype, nnkTupleTy)
  for f in ttype.children:
    expectKind(f, nnkIdentDefs)
    # must be a named tuple!
    fields[fromSym(f[0])] = f[1]
  newLit(fields)

# macro recordSchemaFromNamedTuple(t:typedesc): Table[string,NimNode] =
#   var fields: Table[string,NimNode]
#   for f in getTypeImpl(t).children:
#     fields[f[0].repr] = f[1]
#   newLit(fields)

#   static: assert isNamedTuple(T2), "Must be a named tuple"
# proc tupleKeysCompatible[T1, T2:tuple](): bool = 
#   static: assert isNamedTuple(T1), "Must be a named tuple"
#   static: assert isNamedTuple(T2), "Must be a named tuple"
#   if tupleKeys[T1]() != tupleKeys[T2]():
#     return false

#   const d1 = tupleKeysToIndices[T1]()
#   const d2 = tupleKeysToIndices[T2]()
#   for (k, i1) in d1.pairs:
#     let i2 = d2[k]
#     if not ( typeof(T1[i1]) is typeof(T2[i2])):
#       return false
#   true


proc keys*[T](r:Record[T]): HashSet[string] = 
  tupleKeys(r.data)

# macro tupleKeys(x:tuple): untyped =
#   var r: HashSet[string]
#   for k in getTypeImpl(x).children():
#     r.incl(k[0].repr)
#   newLit(r)

macro sameTypeAndValue(x:typed, y:typed):bool =
  if not sameType(x,y):
    return newLit(false)
  return newCall("==",x,y)

proc sameShape *[T1,T2](t1:Record[T1], t2:Record[T2]):bool =
  let d = t1.data
  let d2 = t2.data
  let s1 = recordSchemaFromNamedTuple(d)
  let s2 = recordSchemaFromNamedTuple(d2)
  var k1:HashSet
  var k2:HashSet
  for k in s1.keys:
    k1.incl(k)
  for k in s2.keys:
    k2.incl(k)
  if k1 != k2:
    return false
  for k in k1:
    if not sameType(k1[k],k2[k]):
      return false
  true

proc `==`*[T1,T2](t1:Record[T1], t2:Record[T2]): bool =
  for x1,x2 in fields(t1.data,t2.data):
    if x1 != x2:
        return false

  true

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