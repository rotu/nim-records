import std/sequtils
import std/algorithm

type SeqSet* = seq[string]
## a dead simple set implementation based on sequences.

# proc `==` *(s: SeqSet, s2: SeqSet): bool {.borrow.}
# proc `@` *(s: SeqSet): seq[string] {.borrow.}
# proc `card` *(s: SeqSet): int = len(seq[string](s))
# proc `concat` *(s1: SeqSet, s2: SeqSet): SeqSet {.borrow.}
# proc `add` *(s1:var SeqSet,v1:sink string) {.borrow.}

proc toSeqSet*(strings: openArray[string]): SeqSet =
   assert (len(strings) == len(deduplicate(strings)))
   SeqSet(@strings)

type VennPart* {.pure.} = enum 
   left
   middle
   right

proc `==~`*(ss1,ss2:SeqSet): bool =
   ## order-insensitive equality check
   (sorted @ss1) == (sorted @ss2)

proc venn *(ss1, ss2: SeqSet): array[VennPart, SeqSet] =
   ## takes a pair of SeqSets A, B and computes their venn diagram
   ## left: A - B
   ## middle: A intersect B
   ## right: B - A
   result[left] = toSeqSet(filter(ss1, proc(x: string): bool = x notin ss2))
   result[middle] = toSeqSet(filter(ss1, proc(x: string): bool = x in ss2))
   result[right] = toSeqSet(filter(ss2, proc(x: string): bool = x notin ss1))

proc intersect*(s1, s2: SeqSet): SeqSet =
   venn(s1, s2)[middle]

proc union*(s1, s2: SeqSet): SeqSet =
   let t = venn(s1, s2)
   concat(s1, t[right])

proc difference*(s1, s2: SeqSet): SeqSet =
   venn(s1, s2)[left]

proc symmetricDifference*(s1, s2: SeqSet): SeqSet =
   let t = venn(s1, s2)
   concat(t[left], t[right])
