import tupleops
import macros
import std/algorithm

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
    assert (sorted(tupleKeys(T1)) == sorted(tupleKeys(T2)))
  dest <~ src

converter toTuple*[T: tuple](t: tuple): T =
  result =~ t

proc to*[T1: tuple](t: T1, T2: typedesc[tuple]): T2 =
  result =~ t

proc to*[T2: tuple](t: tuple): T2 =
  to(t, T2)

template `==~`*[T1: tuple, T2: tuple](t1: T1, t2: T2): bool =
  t1 == toTuple[T1](t2)

proc get*[T: tuple](t: T, key: static string): auto =
  macro getImpl(): typed =
    newDotExpr(bindSym("t"), ident(key))
  getImpl()

proc set*[T: tuple, V](t: T, key: static string, value: V): auto =
  macro setImpl(): typed =
    newAssignment(newDotExpr(bindSym("t"), ident(key)), bindSym("value"))
  setImpl()
