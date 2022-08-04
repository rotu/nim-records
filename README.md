Strongly typed heterogeneous record types!

Some utility functions can be found in lenientTuple:

- `target <~ source`: copy all values from a tuple to another tuple or object
- `t1 ==~ t2`: check if two tuples are equal regardless of order
- `to(src:tuple, T:type tuple)`: convert from a tuple type to another tuple type that differs only in key order
- `=~`: assign from one tuple to another with the same keys, possibly in a different order
- `len`,`hasKey`,`[]`,`[]=`: operations that treat a tuple similar to a `Table[static string, typed]`.

TupleOps has some utility methods to combine and reason about Tuples.

- `tupleKeys(t)`: return the field names as strings `@[k0, k1, ...]`
- `project(t, keys)`: project the tuple onto the selected keys. Returns a tuple with only the given keys.
- `reject(t, keys)`: reject the given keys, returning a tuple with all keys from t *not* in `keys`
- `concat(t1, t2)` / `&`: given two tuples (positional or with non-overlapping keys), return a new tuple combining them. This will fail at compile time if the keys overlap.

Collections has an implementation of relational algebra on Nim named tuples. Viewing a relation as a `seq[tuple]`, the following relational operators are defined:

- Projection = `project(rows, ["someKey", ...])`
- Selection = `select(rows, predicate)`
- Natural join = `join(rows1, rows2)`
- Rename = `rename(rows, {"newKey1":"oldKey1", ...})`
