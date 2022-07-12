import tupleops
import macros


converter toTuple*[T2: tuple](t1: tuple): T2 =
  result =~ t1

template `==`*[T1: tuple, T2: tuple and not T1](t1: T1, t2: T2): bool =
  t1 == toTuple[T1](t2)

template `=`*[T1: tuple, T2: tuple and not T1](t1: var T1, t2: T2) =
  t1 = toTuple[T1](t2)

