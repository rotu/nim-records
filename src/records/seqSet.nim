import std/[algorithm, sequtils]

type TupleKeys* = static[seq[string]]
type TupleKeysIn* = static[openArray[string]]
type SeqSet* = seq[string]
## a dead simple set implementation based on sequences.

proc toSeqSet*(strings: openArray[string]): SeqSet =
   assert (len(strings) == len(deduplicate(strings)))
   SeqSet(@strings)

proc toSeqSet*(s: SeqSet): SeqSet = s

type VennPart* {.pure.} = enum
   left
   middle
   right

proc `==~`*(ss1, ss2: SeqSet): bool =
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

proc isSubset*(s1, s2: SeqSet): bool =
   s1.difference(s2).len == 0

proc symmetricDifference*(s1, s2: SeqSet): SeqSet =
   let t = venn(s1, s2)
   concat(t[left], t[right])
