Strongly typed heterogeneous record types!

Given a tuple `t=(k0:v0, k1:v1, ...)`, there are a few core operations:

- `tupleKeys(t)`: return the field names as strings `@[k0, k1, ...]`
- `proj(t, keys)`: project the tuple onto the selected keys. Returns a tuple with only the given keys.
- `reject(t, keys)`: reject the giben keys, returning a tuple with all keys from t *not* in `keys`
- `join(t1, t2)`: given two tuples, compute their common keys. If the associated values agree, return a `some(s)`, where `s` is the smallest tuple containing both `t1` and `t2`. otherwise, return `none`.
