---
title: Amos Robinson
---

About me
========

I am a PhD student in the [Programming Languages and Systems group](http://www.cse.unsw.edu.au/~pls/) at UNSW in Sydney, Australia.
My supervisors are [Ben Lippmeier](http://benl.ouroborus.net/), [Manuel Chakravarty](http://www.cse.unsw.edu.au/~chak/) and [Gabrielle Keller](http://www.cse.unsw.edu.au/~keller/).
I am interested in optimisations for purely functional languages, specifically fusion for nested data parallelism.

I was also the winner of the inaugural 2014 [FP-Syd](http://fp-syd.ouroborus.net/) Coq Fight, perhaps the first ever live theorem proving competition.
I should note, however, that this doesn't translate into actual theorem prover proficiency.

![The dangers of greedy fusion](images/greedyvert.png)

Publications
------------

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

### Clustering
Finding the best fusion clustering is actually NP-hard (as proved by Alain Darte).
By converting combinator programs to integer linear programs, we can generally find good clusterings in adequate time.

* [Prototype implementation](https://github.com/amosr/clustering)
* [DDC implementation](https://github.com/DDCSF/ddc/blob/master/packages/ddc-core-flow/DDC/Core/Flow/Transform/Rates/Clusters/Linear.hs)
* [Coq proofs (in progress)](https://github.com/amosr/clustering-proof)

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



Personal
--------
I like writing short stories - fiction. [Some of them are here](/stories.html). Sometimes, the school newspaper even prints them!

I also like to make [music](https://soundcloud.com/amos-robinson-2) when I can.

