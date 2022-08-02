import std/[options, sugar, tables, macros]
import ./seqSet



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

proc tupleKeys*(T: type tuple): TupleKeys =
  macro tupleKeysImpl(): untyped =
    # building an array
    result = newNimNode(nnkBracket)
    let tt = getTypeImpl(bindSym("T"))

    let typedescSym = tt[0]
    expectKind(typedescSym, nnkSym)
    assert(typedescSym.strVal == "typeDesc")

    let tupleType = getTypeImpl(tt[1])
    expectKind(tupleType, nnkTupleTy)
    for f in tupleType.children:
      let fieldName = f[0]
      expectKind(fieldName, nnkSym)
      result.add(newLit(fieldName.strVal))
  # and convert to a seq
  return @(tupleKeysImpl())

template tupleKeys*(t: tuple): TupleKeys = tupleKeys(typeof(t))

proc proj*(t: tuple, keys: TupleKeysIn): tuple =
  ## Rearrange/select named fields from a named tuple,
  ## returning a new named tuple
  when len(keys) == 0:
    ()
  else:
    macro projImpl(): tuple =
      result = newNimNode(nnkTupleConstr)
      for key in keys:
        result.add(newColonExpr(
          ident(key),
          newDotExpr(bindSym("t"), ident(key))
        ))
    projImpl()

proc reject*(t: tuple, keys: TupleKeysIn): auto =
  return proj(t, t.tupleKeys.difference(@keys))

proc join*(t1: tuple, t2: tuple): auto =
  const v = venn(tupleKeys(t1), tupleKeys(t2))
  let common1 = t1.proj(v[middle])
  let common2 = t2.proj(v[middle])

  let maybevalue = (t1.proj(v[left]) & common1 & t2.proj(v[right]))
  if common1 == common2:
    return some(maybevalue)
  else:
    none(typeof(maybevalue))


