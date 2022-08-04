import std/macros
import ./seqSet, ./tupleops

proc `<~` *(dest: var (tuple | object); src: tuple) =
  ## Assign from.
  ## Assign all values in a named tuple to another tuple, possibly with more keys
  macro assignFromImpl(): untyped =
    var res = newNimNode(nnkStmtList)
    for prop in tupleKeys((src)):
      res.add(newAssignment(
        newDotExpr(bindSym "dest", ident prop),
        newDotExpr(bindSym "src", ident prop)
      ))
    res
  assignFromImpl()

proc `=~` *(dest: var tuple; src: tuple) =
  ## Assign all.
  ## Assign values from one named tuple to another with the same keys, possibly in a different order
  static:
    assert (tupleKeys dest) ==~ (tupleKeys src)
  dest <~ src

proc to*(t: tuple; T2: type tuple): T2 =
  result =~ t

template `==~`*(t1: tuple; t2: tuple): bool =
  ## check whether two named tuples are the same, ignoring order
  t1 == t2.to(typeof t1)

proc `[]`*(t: tuple; key: static string): auto =
  ## get a named tuple field by name
  macro getFieldImpl(): untyped =
    newDotExpr(bindSym "t", ident key)
  getFieldImpl()

proc `[]=`*(t: var tuple; key: static string; value: sink auto) =
  ## set a named tuple field by name
  macro setFieldImpl() =
    newAssignment(newDotExpr(bindSym "t", ident key), bindSym "value")
  setFieldImpl()

proc len*(T: type tuple): int =
  ## get the number of fields in a tuple type
  macro tupleLenImpl(): untyped =
    let ti = getTypeImpl(bindSym "T")

    ti.expectKind nnkBracketExpr
    let typedescSym = ti[0]

    typedescSym.expectKind nnkSym
    assert(typedescSym.strVal == "typeDesc")

    let tupleDef = ti[1]
    newLit(len tupleDef)

  tupleLenImpl()

template len*(t: tuple): int =
  ## get the number of fields in a tuple
  len(typeof t)

template hasKey*(t: tuple | (type tuple); key: static string): bool =
  ## true if there is a field with the given name in the tuple or tuple type
  key in (tupleKeys t)
