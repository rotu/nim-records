
import std/sequtils
import std/sugar

type scalar=float64

type
  VecSpace = object
    dimension: int
    name: string
    


proc `==`*[N:static[int],R] (x: Vec[N,R], y: Vec[N,R]): bool =
  for i in 0..<N:
    if x.coords[i] != y.coords[i]:
     return false
  return true


func toVector *[N:static[int], S](x:array[N,S]): Vec[N,S] =
   Vec[N,S](coords: x)

func zero*[N:static[int], R](): Vec[N,R]=
  let ar :array[N,R]
  return ar.toVector

type
  Semiring*[N] = object
    Zero: N
    One: N
    `+`: (x:N)->((y:N)->N)
    `*`: (x:N)->((y:N)->N)

type V3f = Vec[3,float32]
type V4d = Vec[4,float64]

proc map *[N:static[int],R,S](v:Vec[N,R], fn:R->S): Vec[N,S] =
    for i in 0..<N:
      result.coords[i]=fn(v.coords[i])

proc fpar *[N:static[int],R,S](fn:R->S): auto = 
  proc ff(v:Vec[N,R]) : Vec[N,S] = 
    var v2:Vec[N,S]
    for i in 0..<N:
      v2.coords[i] = fn(v.coords[i])
  return ff



    
# proc elementwise*[S:type, T:type](fn:S->T): auto =
#  proc fn2[N:static[int]](v:Vec[N,S]) : Vec[N,T] =
#     result:Vec[N,T]
#     for i in 0..N:
#       result[i] = fn(v[i])
#  return fn2

func inner[N:static[int],R](x:Vec[N,R], y:Vec[N,R]): R = 
  result:R
  for i in 0..N:
    result += x[i]*y[i] # todo: conjugate


func nonzero *(x:int): bool =
  return x != 0

func nonzero *[S=float32, n](x:Vec[n,S]) = 
  return x.any( x => x != 0)

func `+=`[V:Vec](x: var V; y: V) =
  for (i,a) in y.pairs:
    x[i]+=a

