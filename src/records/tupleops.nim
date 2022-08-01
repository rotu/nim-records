import std/sugar
import std/tables
import macros
import ./seqSet
import std/options

type TupleKeys* = static[SeqSet]

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

proc tupleKeys[T: tuple](): TupleKeys =
  macro tupleKeysImpl(): untyped =
    # building an array
    result = newNimNode(nnkBracket)
    let tupleType = getTypeImpl(T)
    expectKind(tupleType, nnkTupleTy)
    for f in tupleType.children:
      let fieldName = f[0]
      expectKind(fieldName, nnkSym)
      result.add(newLit(fieldName.strVal))
  # and convert to a seq
  @(tupleKeysImpl())

proc tupleKeys*(T: type tuple): TupleKeys =
  tupleKeys[T]()

template tupleKeys*[T: tuple](t: T): TupleKeys =
  tupleKeys(typeof(t))

proc proj*[T: tuple](t: T, keys: static[openArray[string]]): tuple =
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

proc proj*[T: tuple](t: openArray[T], keys: static[openArray[string]]): auto =
  t.map((x: T) => proj(x, keys))

proc join*[T1: tuple, T2: tuple](t1: T1, t2: T2): auto =
  const v = venn(tupleKeys(T1), tupleKeys(T2))
  let common1 = t1.proj(v[middle])
  let common2 = t2.proj(v[middle])

  let maybevalue = (t1.proj(v[left]) & common1 & t2.proj(v[right]))
  if common1 == common2:
    some(maybevalue)
  else:
    none(typeof(maybevalue))

proc join*(table1: openArray[tuple], table2: openArray[tuple]): auto =
  let res = collect:
    for row1 in table1:
      for row2 in table2:
        let mayberow = row1.join(row2)
        if (isSome(mayberow)):
          unsafeGet(mayberow)
  res

proc groupBy*(tbl: openArray[tuple], keys: TupleKeys): auto =
  type T = typeof(tbl[0])
  const otherKeys = tupleKeys(T).difference(keys)
  type K = typeof(block: (for row in tbl: proj(row, keys)))
  type V = typeof(block: (for row in tbl: proj(row, otherKeys)))
  type VV = seq[V]

  var res: Table[K, VV]

  for row in tbl:
    let k = proj(row, keys)
    let v = proj(row, otherKeys)
    mgetOrPut[K, VV](res, k, @[]).add(v)

  return res
