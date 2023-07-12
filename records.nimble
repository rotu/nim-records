import os

# Package
version = "0.5.3"
author = "Dan Rose"
description = "Operations on tuples as heterogeneous record types a la Relational Algebra"
license = "MIT"
srcDir = "src"
binDir = "build"
requires "nim >= 1.4.8"

task style, "enforce code style":
  var paths: seq[string]
  for path in listFiles(thisDir()):
    if splitFile(path).ext == ".nimble":
      paths.add(path)

  for dir in ["src", "tests"]:
    for path in walkDirRec(thisDir()):
      if splitFile(path).ext == ".nim":
        paths.add(path)

  echo ("prettying ", repr(paths))
  for path in paths:
    exec "nimpretty " & path

task bdoc, "build docs":
  exec "nim doc --project --outdir:build/doc src/records"
