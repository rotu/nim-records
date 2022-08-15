import std/[algorithm, sequtils]

type SeqSet* = seq[string]
## a dead simple ordered set implementation based on sequences.

proc toSeqSet*(strings: openArray[string]): SeqSet =
  assert (len(strings) == len(deduplicate(strings)))
  SeqSet(@strings)

type VennPart* {.pure.} = enum
  left
  middle
  right

proc `==~`*(ss1, ss2: SeqSet): bool =
  ## order-insensitive equality check
  (sorted ss1) == (sorted ss2)

proc intersect*(s1, s2: SeqSet): SeqSet =
  filter(s1, proc(x: string): bool = x in s2)

proc difference*(s1, s2: SeqSet): SeqSet =
  filter(s1, proc(x: string): bool = x notin s2)

proc venn *(ss1, ss2: SeqSet): array[VennPart, SeqSet] =
  ## takes a pair of SeqSets A, B and computes their venn diagram
  ## left: A - B
  ## middle: A intersect B
  ## right: B - A
  result[left] = ss1.difference(ss2)
  result[middle] = ss1.intersect(ss2)
  result[right] = ss2.difference(ss1)

proc union*(s1, s2: SeqSet): SeqSet =
  concat(s1, difference(s2, s1))

proc isSubset*(s1, s2: SeqSet): bool =
  difference(s1, s2).len == 0

proc symmetricDifference*(s1, s2: SeqSet): SeqSet =
  concat(difference(s1, s2), difference(s2, s1))
