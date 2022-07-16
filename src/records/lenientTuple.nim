import tupleops
import macros
import ./seqSet

proc `<~` *[T1: tuple|object, T2: tuple](dest: var T1; src: T2) =
  ## Assign from.
  ## Assign all values in a named tuple to the properties with corresponding names
  macro assignFromImpl(): untyped =
    var res = newNimNode(nnkStmtList)
    for n in getTypeImpl(T2).children:
      expectKind(n, nnkIdentDefs)
      let prop = n[0]
      res.add(newAssignment(
        newDotExpr(bindSym "dest", prop),
        newDotExpr(bindSym "src", prop)))
    res
  assignFromImpl()

proc `=~` *[T1: tuple, T2: tuple](dest: var T1; src: T2) =
  ## Assign all.
  ## Assign values from one named tuple to another,
  ## reordering as necessary
  static:
    assert tupleKeys(dest) ==~ tupleKeys(src)
  dest <~ src


proc toTuple*[T2:tuple](t1:tuple):T2 = 
  result =~ t1

proc to*[T1: tuple](t: T1, T2: typedesc[tuple]): T2 =
  result =~ t

proc to*[T2: tuple](t: tuple): T2 =
  to(t, T2)

template `==~`*[T1: tuple, T2: tuple](t1: T1, t2: T2): bool =
  ## check whether two named tuples are the same, ignoring order
  t1 == toTuple[T1](t2)

proc get*[T: tuple](t: T, key: static string): auto =
  ## get a named tuple field by name
  macro getImpl(): untyped =
    newDotExpr(bindSym("t"), ident(key))
  getImpl()

proc `[]`*[T:tuple](t: T, key: static string): auto =
  ## get a named tuple field by name
  get[T](t, key)

proc set*[V](t: var tuple, key: static string, value: sink V): auto =
  ## set a named tuple field by name
  macro setImpl(): typed =
    newAssignment(newDotExpr(bindSym("t"), ident(key)), bindSym("value"))
  setImpl()

proc `[]=`*[V](t: var tuple, key: static string, value: sink V): auto =
  ## set a named tuple field by name
  set[V](t, key, value)