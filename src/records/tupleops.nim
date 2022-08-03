import std/[options, sugar, tables, macros]
import ./seqSet

type TupleKeys* = seq[string]
type TupleKeysIn* = static[openArray[string]]

proc concat*(t1: tuple, t2: tuple): tuple =
  ## Given two tuples, return a new tuple with their combined contents
  ## Note these tuples must be either positional or named tuples with non-overlapping key sets
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
  ## Return all field names of the given tuple type

  macro tupleKeysImpl(): untyped =
    # building an array
    result = newNimNode(nnkBracket)
    let tt = getTypeImpl(bindSym("T"))

    let typedescSym = tt[0]
    expectKind(typedescSym, nnkSym)
    assert(typedescSym.strVal == "typeDesc")

    let tupleType = getTypeImpl(tt[1])
    if len(tupleType) == 0:
      # corner case: empty tuples are of kind nnkTupleConstr
      expectKind(tupleType, {nnkTupleConstr, nnkTupleTy})
    else:
      expectKind(tupleType, nnkTupleTy)
      for f in tupleType.children:
        let fieldName = f[0]
        expectKind(fieldName, nnkSym)
        result.add(newLit(fieldName.strVal))
  # and convert to a seq
  return @(tupleKeysImpl())

template tupleKeys*(t: tuple): TupleKeys =
  ## Return all the field names of the given tuple
  tupleKeys(typeof(t))

proc project*(t: tuple, keys: TupleKeysIn): tuple =
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

proc reject*(t: tuple, keys: TupleKeysIn): tuple =
  ## Given a tuple and a set of keys, return key-value pairs whose keys
  ## are *not* in the given key set
  return project(t, t.tupleKeys.difference(@keys))

proc join*(t1: tuple, t2: tuple): auto =
  ## Given two tuples, check whether they agree on all shared keys
  ## If they do, return some tuple with all key-value pairs
  ## If not, return none
  const v = venn(tupleKeys(t1), tupleKeys(t2))
  let common1 = t1.project(v[middle])
  let common2 = t2.project(v[middle])

  let maybevalue = (t1 & t2.project(v[right]))
  if common1 == common2:
    return some(maybevalue)
  else:
    none(typeof(maybevalue))

proc meet*(t1: tuple, t2: tuple): auto =
  ## Given two tuples, check whether they agree on all shared keys
  ## If they do, return the tuple of all shared keys
  ## If not, return none
  const v = venn(tupleKeys(t1), tupleKeys(t2))
  let common = t1.project(v[middle])
  if common == t2.project(v[middle]):
    return some(common)
  else:
    none(typeof(common))
