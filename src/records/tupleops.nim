import std/[options, tables, macros]
import ./seqSet

type TupleKeys* = seq[string]
type TupleKeysIn* = static[openArray[string]]

proc concat*(t1: tuple, t2: tuple): tuple =
  ## Given two tuples, return a new tuple with their combined contents
  ## Note these tuples must be either positional or named tuples with non-overlapping key sets
  macro concatImpl(): untyped =
    result = newNimNode(nnkTupleConstr)
    for arg in [bindSym("t1"), bindSym("t2")]:
      expectKind(arg.getTypeImpl(), {nnkTupleConstr, nnkTupleTy})
      for i, d in pairs(arg.getTypeImpl):
        case kind(d):
          of nnkSym:
            # un-named tuple field
            result.add newTree(nnkBracketExpr, arg, newLit(i))
          of nnkIdentDefs:
            # named tuple field
            let prop = d[0]
            result.add newColonExpr(prop,
              newTree(nnkDotExpr, arg, prop)
            )
          else:
            error("Unexpected field kind: `" & $kind(d) & "`")
  concatImpl()

proc `&` *(t1: tuple, t2: tuple): auto = concat(t1, t2)

proc tupleKeys*(T: type tuple): seq[string] =
  ## Return all field names of the given tuple type

  macro tupleKeysImpl(): untyped =
    # building an array
    result = newNimNode nnkBracket
    let tt = getTypeImpl (bindSym "T")

    let typedescSym = tt[0]
    typedescSym.expectKind nnkSym
    assert typedescSym.strVal == "typeDesc"

    let tupleType = getTypeImpl tt[1]
    if len(tupleType) == 0:
      # corner case: empty tuples are of kind nnkTupleConstr
      tupleType.expectKind {nnkTupleConstr, nnkTupleTy}
    else:
      tupleType.expectKind nnkTupleTy
      for f in tupleType.children:
        let fieldName = f[0]
        fieldName.expectKind nnkSym
        result.add(newLit fieldName.strVal)
  # and convert to a seq
  @(tupleKeysImpl())

template tupleKeys*(t: tuple): TupleKeys =
  ## Return all the field names of the given tuple
  tupleKeys(typeof t)

proc project*[T: tuple](t: T, keys: static openArray[string]): auto =
  ## Rearrange/select named fields from a named tuple,
  ## returning a new named tuple

  macro projImpl(): untyped =
    let res = newNimNode(nnkPar)
    when keys.len != 0:
      for key in @keys:
        res.add(newColonExpr(
          ident key,
          newDotExpr(bindSym "t", ident key)
        ))
    res
  return projImpl()

proc reject*(t: tuple, keys: static openArray[string]): tuple =
  ## Given a tuple and a set of keys, return key-value pairs whose keys
  ## are *not* in the given key set
  project(t, t.tupleKeys.difference @keys)

proc join*(t1: tuple, t2: tuple): auto =
  ## Given two tuples, check whether they agree on all shared keys
  ## If they do, return some tuple with all key-value pairs
  ## If not, return none
  const v = venn(tupleKeys t1, tupleKeys t2)

  let maybevalue = t1 & (t2.project v[right])

  let common1 = t1.project v[middle]
  let common2 = t2.project v[middle]
  if common1 == common2:
    some maybevalue
  else:
    none (typeof maybevalue)

proc meet*(t1: tuple, t2: tuple): auto =
  ## Given two tuples, check whether they agree on all shared keys
  ## If they do, return the tuple of all shared keys
  ## If not, return none
  const v = venn(tupleKeys t1, tupleKeys t2)
  let common = t1.project v[middle]
  if common == t2.project v[middle]:
    some common
  else:
    none(typeof common)

proc rename*(t: tuple, newOldPairs: static openArray[(string, string)]): auto =
  macro renameImpl(): untyped =
    result = newNimNode(nnkTupleConstr)
    let tupleType = getTypeImpl(bindSym "t")
    expectKind(tupleType, nnkTupleTy)
    for d in children(tupleType):
      d.expectKind(nnkIdentDefs)
      let prop = d[0]
      prop.expectKind(nnkSym)
      let thisKey = prop.strVal

      var didRename = false
      for (newKey, oldKey) in newOldPairs:
        if oldKey == thisKey:
          didRename = true
          result.add newColonExpr(
            ident(newKey),
            newTree(nnkDotExpr, bindSym "t", ident(oldKey))
          )
      if not didRename:
        result.add newColonExpr(
          prop,
          newTree(nnkDotExpr, bindSym "t", prop)
        )
  renameImpl()
