
import std/sequtils
import std/sugar
import std/tables

type scalar=float64

# keys
proc indexes[N,R](a:array[N,R]): auto = a.keys

proc arzip[N,R,S](a:array[N,R], b: array[N,S]): array[N,(R,S)] =
  for i in 0..<N:
    result[i] = (a,b)

proc arapply[N,R,S](f:R->S, a:array[N,R]): array[N,S] =
  for i in 0..<N:
    result[i] = f(a[i])

import macros
macro call*(fn:typed, args:tuple, kwargs:tuple=()): untyped =
  result = newCall(fn)
  for x in args:
    result.add(x)
  for kwarg in kwargs.getTypeImpl.children:
    var eqExpr = newNimNode(nnkExprEqExpr)
    eqExpr.add(kwarg[0], newDotExpr(kwargs, kwarg[1]))
    result.add(eqExpr)

macro concat*(args: varargs[typed]): untyped =
  result = newNimNode(nnkTupleConstr)
  for arg in args:
    for i in 0..<len(arg.getTypeImpl):
      result.add(newNimNode(nnkBracketExpr).add(arg, newIntLitNode(i)))

macro merge*(args: varargs[typed]): tuple =
  result = newNimNode(nnkTupleConstr)
  for arg in args:
    for f in arg.getTypeImpl.children:
      result.add(newColonExpr(
        f[0],
        newDotExpr(arg, f[0])
      ))

proc callAll *[N:static int, S](fs:array[N,()->S]): array[N,S] =
  for i in 0..<N:
    let x = (fs[i])()
    echo x
    result[i]=x



# proc partialAll *[N:static int,S](fs:array[N,(X)->S], ): array[N,S] =
#   for i in 0..<N:
#     let x = (fs[i])()
#     echo x
#     result[i]=x

# macro apply(f, t: typed): typed =
#   var args = newSeq[NimNode]()
#   let ty = getTypeImpl(t)
#   assert(ty.typeKind == ntyTuple)
#   for child in ty:
#     expectKind(child, nnkIdentDefs)
#     args.add(newDotExpr(t, child[0]))
#   result = newCall(f, args)

type
  Semiring*[N] = object
    Zero: N
    One: N
    `+`: (x:N)->((y:N)->N)
    `*`: (x:N)->((y:N)->N)

type V3f = array[3,float32]
type V4d = array[4,float64]




# proc elementwise*[S:type, T:type](fn:S->T): auto =
#  proc fn2[N:static[int]](v:Vec[N,S]) : Vec[N,T] =
#     result:Vec[N,T]
#     for i in 0..N:
#       result[i] = fn(v[i])
#  return fn2

func inner[N:static[int],R](x:array[N,R], y:array[N,R]): R =
  result:R
  for i in 0..N:
    result += x[i]*y[i] # todo: conjugate


func nonzero *(x:int): bool =
  return x != 0

