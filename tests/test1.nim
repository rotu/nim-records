# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import sugar

import linear




test "callall":
  var y: array[3,float32]
  var f: array[3,()->int]
  var n: array[3,int] = [0,1,2]
  for i in 0..<3:
    f[i] = (()=>i)

  echo callAll(f)
  echo n
  # check callAll(f) == n

import std/typetraits
import std/sequtils


import macros

# macro dumpTypeInst(x: typed): untyped =
#   var res = newSeq[string]()
#   for f in x.getTypeInst.children:
#     echo "repr=",f[0].repr
#     res &= f[0])
#   # let z = x.getTypeInst.children
#   # newLit(x.getTypeImpl.repr)
#   # newLit(x.getTypeInst.repr)
#   res

type R =  object
  a: int
  b: int

macro dumpTypeImpl(x: typed): untyped =
  newLit(x.getTypeImpl.lispRepr)


test "tuplecat":
  let c =  concat( (1, 2) , (3, "a") )
  echo (c[3] & "foo")
  let d = (a:1,b:2)
  let d2 = (c:3,d:5)
  # for f,g in fieldPairs(d):
  #   echo f," ="
  # echo dumpTypeInst(d)
  echo merge(d, d2)
  let r = R(a:1,b:5)
  # echo merge (r,d2)
  for k,v in d.fieldPairs:
    echo k,":=",v
  # echo merge(r, (c:5,d:1))
  call(echo,(1,2,3))

test "zipplus":
  let z = call(`+`,(1,2))
  let t = (1,2)
  call(echo, t)
