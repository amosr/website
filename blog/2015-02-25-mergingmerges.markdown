---
title: Merging merges, more or less
summary: Transcript of talk given at FP-Syd. Using DFAs (finite state machines) for fusion.
---

Merging merges, more or less
=====

The slides are available [here](/talks/2015-02-25-MergingMerges.pdf).
A very rough implementation is on [github](https://github.com/amosr/merges).
I have just quickly written some notes about the slides below.

Motivation
------

First, suppose we have two sources of Ints, perhaps from a hard drive or from network.
We would like to filter each source by some predicate, and pairwise zip the results together.
Then, with the zipped result, we want to perform some IO action - firing a missile from one place to another, say.
```haskell
zipf :: Source Int -> Source Int -> IO ()
zipf xs ys
 = let xs'  = filter (>0) xs
       ys'  = filter (<0) ys
       zz   = zip xs' ys'
   in  mapM_ fire_missile zz
```
The question is, can we execute this in constant memory? In this case, we can.

However, what if we remove one source, and have both filters working over the same source:
```haskell
bad :: Source Int -> IO ()
bad xs
 = let xs'  = filter (>0) xs
       xs'' = filter (<0) xs
       zz   = zip xs' xs''
   in  mapM_ fire_missile zz
```
Here, we are pulling from a single source and classifying them according to whether they are negative or positive.
But if we pull from the source and read five positives in a row, we must keep those five positives around in memory until we see five corresponding negatives.
Indeed, if the source were comprised entirely of positive numbers, we would have to buffer the entire source before throwing it all away!

My motivation, then, is to outlaw the second program at compile time, while being able to extract efficient code for the first.


Combinators
-----

We can describe many array combinators as a sort of DFAs, or finite state machines.
In these DFAs, each state is given a type, and the state type determines the alphabet for transitions out of that state.
The state types are:
```haskell
data StateType
 = Pull Name    -- Attempt to read from input
 | Out  Name    -- Write an output to name
 | If           -- An 'if' based on the value of last read inputs
 | Done
```
The alphabet for output transitions is determined by the state:
```haskell
alphabet :: StateType -> [Sigma]
-- Pulls can succeed or fail
alphabet (Pull n) = [Empty, Some n]
-- Outs can only succeed
alphabet (Out n)  = [()]
-- Ifs have two branches, true and false
alphabet (If)     = [True, False]
-- Done can have no output transitions
alphabet (Done)   = []
```

With just these, we can write a bunch of cool combinators: zip, map, filter, merge, append, and probably others.
In the implementation, I have an `Update` transition too, which allows fold, scan, group by and so on, but left it out here for simplicity.

The slides (pages 5-8) show some combinators.


Fusion
-------

Given two combinator machines, we can merge them together with a sort of parallel execution.
The resulting machine has size at worst of the product of the two input machines.

```haskell
merge :: Machine l1 -> Machine l2 -> Maybe (Machine (l1,l2))
```

We start by looking at the initial states of both machines (slide 12).
If one machine is trying to pull from the output of the other, it cannot move until the other machine has produced an "out".
If either machine can move, it's somewhat arbitrary which machine to choose.

In the case of slide 12, the zip machine is trying to pull from `xs'`, which is produced by the filter machine, so only the filter machine can execute.
For each output transition, we create a new state where one machine has moved, but the other stays.

This is very similar to computing the intersection of two machines, if you imagine that you add dummy self-transitions to each machine, for the other's transitions.
These dummy transitions allow one machine to execute, while leaving the other machine in the same state.
The dummy transitions are only added for the difference of the transition, so if both machines require the same transition, they must agree on it.

On slide 25 we have the result of merging two machines, but the red states are somewhat superfluous: they are states where the zip machine has finished, but the filter machine keeps consuming its input.
This is a special case of producer/consumer fusion: the filter machine produces values, the zip machine is its only consumer, and they share no other inputs or outputs.

In the case of producer/consumer fusion, we can use a much simpler merging algorithm which simply executes the consumer machine until it attempts to read the producer's value, then switching over to the producer machine until it finishes or produces a value.
In slides 26 to 33, green indicates the active machine, and yellow inactive.
This simpler merge algorithm can produce fewer states when it is applicable.

In slides 34 to 38, the same producer/consumer fusion is applied to the other filter machine.

Deadlock
-------
Now, let us go back to the bad machine.
In this case, we can fuse one of the filter machines and the zip machine using producer/consumer fusion, as before.
However, when fusing the resulting machine with the other filter, they both share an input, and we must fall back to the general case.

We execute both machines as usual, until slide 41, where both machines are at "if" nodes.
Here, we create nodes for all possible outcomes of the ifs - we make no attempt at checking functional equality.
One of these cases is when the left if returns false, and the right if returns true.
Then, we end up at slide 45, where the left machine is attempting to pull from `xs` again, but because it's a shared source, both machines must pull at the same time.
Meanwhile, the right machine is attempting to pull from `xs'`, which is the output of the left machine.
Neither machine can make any progress, so this results in deadlock, and we reject this program.

It is worth stressing that if both filters had used the same predicate, say `(>0)`, it would be possible to merge them, but this algorithm would still deadlock.
