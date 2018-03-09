---
title: Amos Robinson
---

About me
========

I am a PhD student in the [Programming Languages and Systems group](http://www.cse.unsw.edu.au/~pls/) at UNSW in Sydney, Australia.
My supervisors are [Ben Lippmeier](http://benl.ouroborus.net/), [Manuel Chakravarty](http://www.cse.unsw.edu.au/~chak/) and [Gabrielle Keller](http://www.cse.unsw.edu.au/~keller/).
I am interested in optimisations for purely functional languages, specifically stream fusion.

![Clusterings for fusing a dataflow graph. The square nodes represent input streams, while round nodes represent scan combinators. Dashed lines are fusion-preventing dependencies. (Middle) shows a greedy clustering with four loops; (Right) shows optimising for minimal loops with three loops.](images/greedyvert.png)

Publications
------------

* [Machine fusion: merging merges, more or less](papers/robinson2017merges.pdf).
    Amos Robinson, Ben Lippmeier.  
    *Principles and Practice of Declarative Programming 2017*.

* [Icicle: write once, run once](papers/robinson2016icicle.pdf).
    Amos Robinson, Ben Lippmeier, Gabriele Keller.  
    *Functional High Performance Computing 2016*.

* [Polarized data parallel data flow](papers/lippmeier2016polarized.pdf)
    Ben Lippmeier, Amos Robinson, Fil Mackay  
    *Functional High Performance Computing 2016*.

* [Fusing filters with integer linear programming](papers/robinson2014fusingfilters.pdf).
    [(video)](https://www.youtube.com/watch?v=kBeJec5whQo) [(slides)](papers/robinson2014fusingfilters-slides.pdf) [(errata)](blog/2014-10-12-errata.html)  
    Amos Robinson, Ben Lippmeier, Gabriele Keller.  
    *Functional High Performance Computing 2014*.

* [Data flow fusion with series expressions in Haskell](papers/lippmeier2013flowfusion.pdf).  
    Ben Lippmeier, Manuel Chakravarty, Gabriele Keller, Amos Robinson.  
    *Haskell Symposium 2013*.

* [Rewrite rules for the Disciplined Disciple Compiler](http://code.ouroborus.net/ddc/doc/theses/2012-AmosRobinson-RewriteRules.pdf).  
    Honours thesis at UNSW.


Projects
--------

### Folderol: stream fusion for multiple queries or consumers
Folderol is an implementation of Machine fusion for fusing and executing concurrent streaming queries. Combinators in a streaming program are represented as processes in a Kahn process network. We keep the determinism of list and streaming programs, while being able to coordinating between multiple consumers, which is necessary for executing multiple queries. This project uses Template Haskell to construct process networks and generate fused processes at compile-time.

This project is a combination of conceptual work on a novel fusion system and low-level implementation details for generation of efficient code.

* [Code](https://github.com/amosr/folderol)
* [Coq proofs](https://github.com/amosr/papers/tree/master/2017mergingmerges/proof)

### Icicle: a streaming query language
When dealing with large data sets that do not fit in memory, it is crucial to limit the number of accesses and iterations over the data set. However, in a high level language it may not be immediately obvious how many iterations a particular program will require. The number of iterations becomes even less obvious in the presence of heuristic and statistics-based optimisations, as used by traditional databases: a small tweak to the query or even modifying the number of rows in a table can cause drastic changes to the query plan.

As data sets continue to grow, a high level language with predictable runtime characteristics becomes more necessary. Programmers should not need to understand the internal workings of a database or query optimiser in order to write fast queries.

At Ambiata, we have designed and implemented Icicle, a query language specifically for single-pass queries. This means that any query in our language is assured to compile into a single iteration over the data set. We use a type system based on temporal logic to ensure that queries can be executed in a single pass without violating causality. Queries are then compiled to a stream-based intermediate language, which allows multiple queries to be merged together, removing duplicate computations. Finally, queries are compiled to high-performance C code.

* [Code](https://github.com/amosr/icicle)

### Clustering
Finding the best fusion clustering is actually NP-hard (as proved by Alain Darte).
By converting combinator programs to integer linear programs, we can generally find good clusterings in adequate time.

* [Prototype implementation](https://github.com/amosr/clustering)
* [DDC implementation](https://github.com/DDCSF/ddc/blob/master/packages/ddc-core-flow/DDC/Core/Flow/Transform/Rates/Clusters/Linear.hs)
* [Coq proofs, unfinished](https://github.com/amosr/clustering-proof)

### Disciplined Disciple Compiler (DDC)
DDC is a research compiler for a strict functional language with effect typing.
It isn't particularly useful yet, but has some interesting optimisations.

* [Project page](http://disciple.ouroborus.net/)
* [Code](https://github.com/DDCSF/ddc)

### Linear Integer/Mixed Programming (LIMP)
A fairly simple Haskell library for expressing linear programs.
At the moment, there's only a simplifier, COIN/CBC bindings, and pretty-printing.

* [Base library](https://github.com/amosr/limp)
* [CBC bindings](https://github.com/amosr/limp-cbc)

### Audio pilot
A game that takes music and lets you fly around a tunnel. Written in Haskell, using OpenGL.

* [Code](https://github.com/amosr/game-pilot)
* [Video](https://www.youtube.com/watch?v=zDImm36ousc)


Social media
------------

* [Github](https://github.com/amosr/)

* [Twitter](https://twitter.com/MosRobinson)

* [Google plus](https://plus.google.com/115705715965008185675)

* <amosr@cse.unsw.edu.au>


