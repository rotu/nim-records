import tupleops
import macros
import ./seqSet

proc `<~` *(dest: var (tuple | object); src: tuple) =
  ## Assign from.
  ## Assign all values in a named tuple to the properties with corresponding names
  macro assignFromImpl(): untyped =
    var res = newNimNode(nnkStmtList)
    for prop in tupleKeys((src)):
      res.add(newAssignment(
        newDotExpr(bindSym "dest", ident(prop)),
        newDotExpr(bindSym "src", ident(prop))))
    res
  assignFromImpl()

proc `=~` *[T1: tuple, T2: tuple](dest: var T1; src: T2) =
  ## Assign all.
  ## Assign values from one named tuple to another,
  ## reordering as necessary
  static:
    assert tupleKeys(dest) ==~ tupleKeys(src)
  dest <~ src

proc to*(t: tuple, T2: type tuple): T2 =
  result =~ t

template `==~`*(t1: tuple, t2: tuple): bool =
  ## check whether two named tuples are the same, ignoring order
  t1 == t2.to(typeof t1)

proc get*(t: tuple, key: static string): auto =
  ## get a named tuple field by name
  macro getImpl(): untyped =
    newDotExpr(bindSym("t"), ident(key))
  getImpl()

proc `[]`*(t: tuple, key: static string): auto =
  ## get a named tuple field by name
  get(t, key)

proc set*(t: var tuple, key: static string, value: sink auto) =
  ## set a named tuple field by name
  macro setImpl(): typed =
    newAssignment(newDotExpr(bindSym("t"), ident(key)), bindSym("value"))
  setImpl()

proc `[]=`*(t: var tuple, key: static string, value: sink auto) =
  ## set a named tuple field by name
  set(t, key, value)
