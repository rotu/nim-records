import std/algorithm
import std/sequtils

type SeqSet * = distinct seq[string]

proc `==` *(s: SeqSet, s2: SeqSet): bool {.borrow.}
proc `@` *(s: SeqSet): seq[string] {.borrow.}
proc `toSeq` *(s: SeqSet): seq[string] = seq[string](s)

proc toKeySet*(s1: static[seq[string]]): SeqSet =
   SeqSet(sorted(s1))

proc intersection*(s1, s2: SeqSet): SeqSet =
   var s: seq[string]
   for x in @s1:
      if x in @s2:
         s.add(x)
   SeqSet(s)

proc union*(s1, s2: SeqSet): SeqSet =
   let ss1 = concat(@s1, @s2)
   let ss2 = sorted(ss1)
   let ss3 = deduplicate(ss2, isSorted = true)
   SeqSet(ss3)

proc difference*(s1, s2: SeqSet): SeqSet =
   var s: seq[string]
   for x in @s1:
      if x notin @s2:
         s.add(x)
   SeqSet(s)
