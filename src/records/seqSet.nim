import std/algorithm
import std/sequtils

type SeqSet* = distinct seq[string]

proc `==` *(s: SeqSet, s2: SeqSet): bool {.borrow.}
proc `@` *(s: SeqSet): seq[string] {.borrow.}
proc `card` *(s: SeqSet): int = len(seq[string](s))

# private
proc disjointUnion(l: SeqSet, r: SeqSet): SeqSet =
   merge(seq[string]result, seq[string]l, seq[string]r)

proc toSeqSet*(strings: openArray[string]): SeqSet =
   SeqSet(deduplicate(sorted(strings), isSorted = true))

type VennPart* = enum
   left
   middle
   right

type CompareError = object of CatchableError

proc venn *(ss1, ss2: SeqSet): array[VennPart, SeqSet] =
   ## takes a pair of SeqSets A, B and computes their venn diagram
   ## left: A - B
   ## middle: A intersect B
   ## right: B - A
   proc `add`(s: var SeqSet, v: string) {.borrow.}

   var i1 = 0
   var i2 = 0
   let s1 = @ss1
   let s2 = @ss2

   while true:
      if len(s1) <= i1:
         while (i2 < len(s2)):
            result[right].add(s2[i2])
            i2+=1
         return
      if len(s2) <= i2:
         while (i1 < len(s1)):
            result[left].add(s1[i1])
            i1+=1
         return

      if s1[i1] == s2[i2]:
         result[middle].add(s1[i1])
         i1+=1
         i2+=1
      elif s1[i1] < s2[i2]:
         result[left].add(s1[i1])
         i1+=1
      elif s1[i1] > s2[i2]:
         result[right].add(s1[i1])
         i2+=1
      else:
         raise newException(CompareError, "Order relation must be total!")

proc intersect*(s1, s2: SeqSet): SeqSet =
   venn(s1, s2)[middle]

proc union*(s1, s2: SeqSet): SeqSet =
   let t = venn(s1, s2)
   disjointUnion(disjointUnion(t[left], t[middle]), t[right])

proc difference*(s1, s2: SeqSet): SeqSet =
   venn(s1, s2)[left]

proc symmetricDifference*(s1, s2: SeqSet): SeqSet =
   let t = venn(s1, s2)
   disjointUnion(t[left], t[right])
