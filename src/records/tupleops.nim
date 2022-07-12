import std/sugar
import std/tables
import std/algorithm
import macros

type TupleKeys * = static[seq[string]]

macro concat*(t1: tuple, t2: tuple): untyped =
  let fields = collect:
    for arg in [t1, t2]:
      expectKind(arg.getTypeImpl(), {nnkTupleConstr, nnkTupleTy})
      for i, d in pairs(arg.getTypeImpl):
        case kind(d):
          of nnkSym:
            # un-named tuple field
            newTree(nnkBracketExpr, arg, newLit(i))
          of nnkIdentDefs:
            # named tuple field
            let prop = d[0]
            newColonExpr(prop,
              newTree(nnkDotExpr, arg, prop)
            )
          else:
            error("Unexpected field kind: `" & $kind(d) & "`")
            newEmptyNode()
  newTree(nnkTupleConstr, fields)

proc `&` *(t1: tuple, t2: tuple): auto =
  concat(t1, t2)

proc tupleKeys*(T: typedesc[tuple]): TupleKeys =
  for c in getTypeImpl(T).children:
    expectKind(c, nnkIdentDefs)
    result.add(c[0].repr)

template tupleKeys*(t: tuple): TupleKeys =
  tupleKeys(typeof(t))

proc getFieldNames*[T: tuple](): TupleKeys =
  macro getFieldNamesImpl(): seq[string] =
    newLit:
      collect:
        for f in T.getTypeImpl.children:
          f[0].repr()
  getFieldNamesImpl()

proc proj*[T: tuple](t: T, tags: TupleKeys): tuple =
  ## Rearrange/select named fields from a named tuple,
  ## returning a new named tuple
  macro projImpl(): tuple =
    result = newNimNode(nnkTupleConstr)
    for tag in tags:
      result.add(newColonExpr(
        ident(tag),
        newDotExpr(bindSym("t"), ident(tag))
      ))
  projImpl()

proc proj*[T: tuple](t: T, ixes: static[seq[Ordinal]]) =
  ## Rearrange/select named fields from a positional tuple,
  ## returning a new positional tuple
  macro projImpl(): tuple =
    result = newNimNode(nnkTupleConstr)
    for ix in ixes:
      result.add(newTree(nnkBracketExpr, t, newLit(ix)))
  projImpl()

# order fields alphabetically
proc sortFields*[T: tuple](arg: T): tuple =
  const fields = sorted(getFieldNames[T]())
  proj(arg, fields)

proc reshuffle*[T1: tuple, T2: tuple](x: T1): T2 =
  for name, v1, v2 in fieldPairs(x, result):
    v2 = v1

proc `<~` *(dest: var (tuple | object); src: tuple) =
  macro assignFromImpl(dest: var object|tuple; src: tuple): untyped =
    var res = newNimNode(nnkStmtList)
    for n in src.getTypeImpl:
      expectKind(n, nnkIdentDefs)
      res.add(newAssignment(newDotExpr(dest, n[0]), newDotExpr(src, n[0])))
    res
  assignFromImpl(dest, src)

proc `=~` *(dest: var(tuple); src: tuple) =
  static:
    assert sorted(tupleKeys(dest)) == sorted(tupleKeys(src))
  dest <~ src
