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

proc tupleKeys*[T: tuple](): TupleKeys =
  macro tupleKeysImpl(): seq[string] =
    var res: seq[string]
    for f in (getTypeImpl(T)).children:
      res.add(f[0].repr())
    return newLit(res)
  tupleKeysImpl()

proc tupleKeys*(T: typedesc[tuple]): TupleKeys =
  tupleKeys[T]()

proc tupleKeys*[T: tuple](t: T): TupleKeys =
  tupleKeys(typeof(t))

proc proj*[T: tuple](t: T, tags: static[openArray[string]]): tuple =
  ## Rearrange/select named fields from a named tuple,
  ## returning a new named tuple
  when len(tags) == 0:
    ()
  else:
    macro projImpl(): tuple =
      result = newNimNode(nnkTupleConstr)
      for tag in tags:
        result.add(newColonExpr(
          ident(tag),
          newDotExpr(bindSym("t"), ident(tag))
        ))
    projImpl()

# order fields alphabetically
proc sortTupleKeys*[T: tuple](arg: T): tuple =
  const fields = sorted(tupleKeys[T]())
  proj(arg, fields)
