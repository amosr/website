---
title: Let's Make Loops
summary: 
---

Typesafe Loops
=====

Kinds
-----

We have three kinds.
The most familiar is ```Data```, which is your usual ```*``` for types that have a runtime representation.

```haskell
Data     :: Kind
a        :: Data
```

Next, we have ```Rate``` kinds, which are a very coarse symbolic signifier of the length of an array or loop. 
In the absence of dependent types, performing arbitrary computations on rates would be prohibitively hard, if not impossible.

```haskell
Rate     :: Kind
k        :: Rate
```

Instead, we only allow certain limited computations, and take a conservative view of equality:
if two arrays have the same rate syntactically they are assured to be equal, but the converse is not necessarily true.

```haskell
Append   :: Rate ~> Rate ~> Rate
Cross    :: Rate ~> Rate ~> Rate
```

Other rate computations that are too hard to capture exactly are approximated by introducing existential rates for the result.
For example, the output rate of a filter is the number of elements that satisfy the predicate.
Since we cannot evaluate this during type checking, we simply say that there exists some rate for the result, but we don't know what it is.
Essentially, this means that the result rate is not equal to any of the outer rates.

```haskell
filter   :: [k : Rate]. [a z : Data]
         -- Predicate 
         .  (a -> Bool)
         -- Input vector of rate k
         -> RateVec k a
         -- Introduce existential for k'
         -> ([k' : Rate]. RateVec k' a -> z)
         -> z
```


Finally, ```Proc``` kinds are used to stop leaking loop computations out of the loop environment.
For each loop, we introduce a new existential ```Proc``` and require that all loop combinators are annotated with the same process.

```haskell
Proc     :: Kind
p        :: Proc
```

Types
-----

We have three different array representations.
```Vector a```s are buffers of ```a```s with no type-level rate information.

```haskell
Vector   ::                 Data ~> Data
```

```RateVec k a```s have been converted from ```Vector a``` and anointed with a rate ```k```.
```haskell
RateVec  ::         Rate ~> Data ~> Data

ratify0  :: [z : Data]
         .  Nat
         -> ([k : Rate]. z)
         -> z

ratifyN  :: [a0..aN z : Data]
         .  Vector    a0 .. Vector   aN
         -> ([k : Rate]. RateVec k a0 .. RateVec k aN -> z)
         -> z
```

```Series p k a``` exist inside a process ```p```, and only exist in memory as a single element at a time, unless explicitly converted to or from a manifest buffer.
```haskell
Series   :: Proc ~> Rate ~> Data ~> Data

series   :: [p : Proc]. [k : Rate]. [a : Data]
         .  RateVec k a -> Series p k a
```

Selectors convert from one rate to others.
Selectors rely on Series, so can only exist within the context of a specific process.
Sel1 is so named because it only has one output rate.
```haskell
Sel1     :: Proc ~> Rate ~> Rate ~> Data

mkSel1   :: [p : Proc]. [k1 kL : Rate]
         .  Series p k1 Bool 
         -> ([k2 : Rate]. Sel1 p k1 k2 -> Process  p kL)
         -> Process  p kL

pack     :: [p : Proc]. [k1 k2 : Rate]. [a : Data]
         .  Sel1 p k1 k2
         -> Series p k1 a
         -> Series p k2 a
```

Segment descriptors represent nested arrays.
The constructor here relies on a Series, but I imagine the same segment descriptor could be used by multiple processes. 
Indeed, a segment descriptor could even be used as an argument to a function, so I don't think it should be restricted to a particular process.

```haskell
Segd     ::         Rate ~> Rate ~> Data

mkSegd   :: [p : Proc]. [k1 kL : Rate]
         .  Series  p k1 Nat 
         -> ([k2 : Rate]. Segd  k1 k2 -> Process  p kL)
         -> Process  p kL
```

Processes are indexed by a proc and a rate describing the loop size.
The proc is introduced as an existential by ```runProc```, which ensures that different calls to runProc cannot share processes.
Only processes of the same proc and loop size can be merged, or joined, together.
Loop sizes can be changed in specific ways, for example a smaller loop can be injected into a larger one, and we end up with a constructive proof witness that all loops in the process can be converted to the same size.
```haskell
Process  :: Proc ~> Rate         ~> Data

runProc  :: [k : Rate] [a : Data]
         . ([p : Proc]. Unit -> Process p k)
         -> Unit

pjoin    :: [p : Proc]. [k : Rate]
         .  Process p k
         -> Process p k
         -> Process p k
```

Combinators
-----------

```haskell
rep      :: [p : Proc] [k : Rate] [a : Data]
         .  a -> Series p k a

reps     :: [p : Proc]. [k1 k2 : Rate]. [a : Data]
         .  Segd k1 k2 -> Series p k1 a -> Series p k2 a

indices  :: [p : Proc]. [k1 k2 : Rate].
         .  Segd k1 k2 -> Series p k2 Nat

map      :: [p : Proc]. [k : Rate] [a b : Data]
         .  (a -> b) -> Series p k a -> Series p k b

mapN     :: [p : Proc] [k : Rate] [a0..aN : Data]
         .  (a0 -> .. aN) -> Series p k a0 -> .. Series p k aN

sappend  :: [p : Proc]. [k l : Rate]. [a : Data]
         .  Series p         k    a
         -> Series p           l  a
         -> Series p (Append k l) a

scross   :: [p : Proc]. [kR kO : Rate]. [a b : Data]
         .  Series p        kR      a
         -> RateVec            kO     b
         -> Series p (Cross kR kO) (a,b)

generate :: [p : Proc]. [k : Rate]. [a : Data]
         .  (Nat  -> a) -> Series p k a

reduce   :: [p : Proc]. [k : Rate]. [a : Data]
         .  Ref a -> (a -> a -> a) -> a -> Series p k a -> Process p k


folds    :: [p : Proc]. [k1 k2 : Rate]. [a : Data]
         .  Segd  k1 k2 -> Series p k1 a -> Series k2 b

scatter  :: [p : Proc]. [k : Rate]. [a : Data]
         .  Vector a -> Series p k Nat  -> Series p k a -> Process p k

gather   :: [p : Proc]. [k1 k2 : Rate]. [a : Data]
         .  RateVec k1 a -> Series p k2 Nat  -> Series p k2 a

fill     :: [p : Proc]. [k : Rate]. [a : Data]
         .  Series p k a
         -> Process p k
```

Changing rates
-----------------
To merge processes together, they must have the same size.
However, we can inject certain loops inside larger ones. 
The general rule seems to be to inject more specific, or smaller, loops inside more general, larger ones, but that's not always right.

```haskell
Inject   :: Rate ~> Rate ~> Data

iid      :: [k : Rate]
         .  Inject k k

pinj     :: [p : Proc]. [k k' : Rate]
         .  Inject    k k'
         -> Process p k
         -> Process p   k'
```

Injecting into appends is simple: given an append of two consecutive loops ```k``` and ```l```,
we could inject a ```k``` into the left, or an ```l``` into the right.

```haskell
injAppL  :: [k k' l : Rate]
         .  Inject k         k'
         -> Inject k (Append k' l)

injAppR  :: [k l l' : Rate]
         .  Inject l           l'
         -> Inject l (Append k l')
```

We can also perform arbitrary injections over the contents of an append.
```haskell
injApp   :: [k k' l l' : Rate]
         .  Inject         k            k'
         -> Inject           l             l'
         -> Inject (Append k l) (Append k' l')
```

Given a filter, or Sel1, we can inject the known-smaller filter result into the original rate.

```haskell
injSel1  :: [p : Proc]. [j k l : Rate]
         .  Sel1  p   k l
         -> Inject  j   l
         -> Inject  j k
```

Here, it gets hairy.
Given a ```Segd k1 k2```, we could plausibly go in either direction.
Since ```mkSegd``` introduces the new rate, k2, moving from k2 to k1 seems to make more sense: k1 is the more general rate that we were originally working over.

```haskell
injSegd  :: [j k l : Rate]
         .  Segd      k l
         -> Inject  j   l
         -> Inject  j k
```

A loop of size ```k * l``` can be converted to a nested loop, whose outer rate is ```k``` with an inner loop of ```l``` at each iteration.
We only track the outer rates in the types.

```haskell
injCross :: [j k l : Rate]
         .  Inject j (Cross k l)
         -> Inject j        k
```



Examples
----------

### Segmented ###

```haskell
segs    [p : Proc] [k1 kT : Rate]
        (lens      : RateVec k1 Nat)
        (base      : RateVec k1 Nat)
        (things    : RateVec kT Float32)
        (out1 out2 : Vector     Float32)
        : Process p k1
 = do   lens' = series lens                             -- Series k1 Nat
        base' = series base                             -- Series k1 Nat
        mkSegd [:p k1 k1:] lens'                        -- Process p k1
            (/\(k2 : Rate). \(segd : Segd k1 k2).       
            do  bases   = reps    segd base'            -- Series k2 Nat
                offsets = indices segd                  -- Series k2 Nat
                ixs     = map2    add bases offsets     -- Series k2 Nat
                results = gather  things ixs            -- Series k2 Float32
                firsts  = gather  things base'          -- Series k1 Float32
                firstsr = reps    segd firsts           -- Series k2 Float32

                pout1   = fill    out1 results          -- Process p k2
                pout2   = fill    out2 firstsr          -- Process p k2

                pouts   = pjoin pout1 pout2             -- Process p k2

                i       = injSegd segd iid              -- Inject k2 k1

                pinj i pouts)                           -- Process p k1
```

### Partitioning ###
```haskell
part [p : Proc] [k : Rate]
     (ins : RateVec k Int)
     (out : Vector    Int)
          : Process p (Append k k)
 = do   ins' = series   ins                             -- Series  p k  Int
        gts  = map (>5) ins'                            -- Series  p k  Bool
        lts  = map (<5) ins'                            -- Series  p k  Bool
        mkSel1 gts                                      -- Process p (Append k k)
            (/\(kg : Rate). (\sg : Sel1 k kg).
        mkSel1 lts                                      -- Process p (Append k k)
            (/\(kl : Rate). (\sl : Sel1 k kl).
            do  gs   = pack    sg  ins'                 -- Series  p kg Int
                ls   = pack    sl  ins'                 -- Series  p kl Int

                ap   = sappend gs  ls                   -- Series  p (Append kg kl) Int
                pout = fill    out ap                   -- Process p (Append kg kl)

                isg  = injSel1 sg  iid                  -- Inject  kg k
                isl  = injSel1 sl  iid                  -- Inject  kl k

                i    = injApp isg isl                   -- Inject (Append kg kl) (Append k k)

                pinj pout))                             -- Process p (Append k k)
```


### Duplicating work ###
An append can duplicate work.

```haskell
dupe [p : Proc] [k : Rate]
     (ins : RateVec k Int)
     (out : Vector    Int)
          : Process p (Append k k)
 = do   ins' = series   ins                             -- Series  p k  Int
        exp  = map expensive ins'                       -- Series  p k  Int
        ap   = sappend exp exp                          -- Series  p (Append k k) Int
        fill out ap                                     -- Process p (Append k k)
```
Will be translated into something imperative like this, with calls to expensive for both sides of the append:
```c
int o = 0;
for (int i = 0; i != ins.length; ++i) {
    out[o++] = expensive(ins[i]);
}
for (int i = 0; i != ins.length; ++i) {
    out[o++] = expensive(ins[i]);
}
```
Is this a problem?

I think this could be outlawed with linear types, or by changing append to introduce two new process contexts:
```haskell
append :: [p : Proc]. [k1 k2 : Rate]. [a : Data]
       .  ([p' : Proc]. Series p' k1 a)
       -> ([p' : Proc]. Series p' k2 a)
       -> Series p (Append k1 k2) a
```
Here, each side of the append must be a series in a fresh existential context, which means it cannot refer to outside Series in process p.
We could still write the above program, but the duplication would have to be explicit:

```haskell
dupe [p : Proc] [k : Rate]
     (ins : RateVec k Int)
     (out : Vector    Int)
          : Process p (Append k k)
 = do   ap = sappend                                    -- Series  p  (Append k k) Int
            (/\(p' : Proc).
            do  ins' = series   ins                     -- Series  p' k  Int
                exp  = map expensive ins'               -- Series  p' k  Int
                exp)
            (/\(p' : Proc).
            do  ins' = series   ins                     -- Series  p' k  Int
                exp  = map expensive ins'               -- Series  p' k  Int
                exp)
        fill out ap                                     -- Process p (Append k k)
```

However this doesn't play nicely with filters or other existentials, so we would need to change its type to allow for that, which actually gets rather confusing.
I think at this point, we're screwed.

```haskell
append :: [p : Proc]. [a z : Data]
       .  ([p' p'' : Proc].
                ([k1 k2 : Rate]. Series p' k1 a -> Series p'' k2
                    -> (Series p (Append k1 k2) a -> z) -> z) -> z)
       -> z

append
 (/\(p1 p2 : Proc).
   \(f : [k1 k2 : Rate]. Series p1 k1 -> Series p2 k2
                      -> (Series p (Append k1 k2) a -> z)
                      -> z).
    f (_ : Series p1 k3 a) (_ : Series p2 k4 a)
      (\(ap : Series p (Append k3 k4) a). return z))
``` 

