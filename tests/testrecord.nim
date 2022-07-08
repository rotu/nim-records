import unittest
import sugar

import records


test "canmakerecord":
  let mytuple =(x:1, y:2)
  var p = (mytuple).toRecord
  check p == p
  # check callAll(f) == n