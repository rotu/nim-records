# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import sugar

import linear

test "can create":
  var y: Vec[3,float32]
  check y == y

  let x: Vec[4,float] = [1.3,2.1,3.1,0.4].toVector

test "elementwise":
  var x:Vec[3,float32]
  let x2 = map(x,l=>l+1)

  echo x
  echo x2

  echo (fpar(r:float32 => r + 1)(x))
