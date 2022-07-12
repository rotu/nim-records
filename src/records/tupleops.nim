import std/sugar
import std/tables
import std/algorithm
import macros

type TupleKeys* = static[seq[string]]

proc concat*(t1: tuple, t2: tuple): auto =
  macro concatImpl(): untyped =
    let fields = collect:
      for arg in [bindSym("t1"), bindSym("t2")]:
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
  concatImpl()

proc `&` *(t1: tuple, t2: tuple): auto = concat(t1, t2)

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


proc `<~` *[T1: tuple|object, T2: tuple](dest: var T1; src: T2) =
  macro assignFromImpl(): untyped =
    var res = newNimNode(nnkStmtList)
    for n in getTypeImpl(T2).children:
      expectKind(n, nnkIdentDefs)
      let prop = n[0]
      res.add(newAssignment(newDotExpr(bindSym "dest", prop), newDotExpr(
          bindSym "src", prop)))
    res
  assignFromImpl()

proc `=~` *[T1: tuple, T2: tuple](dest: var T1; src: T2) =
  static:
    assert sorted(tupleKeys(T1)) == sorted(tupleKeys(T2))
  dest <~ src
