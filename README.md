# wpp

This initial version of this software is largely taken from Grégoire Locqueville:
https://glocq.github.io/en/blog/20250428/

In version (file names ending in as) a haskell implementation of Knuth's algorithm X
has been used:  https://github.com/AlexeyFeigin/algorithm-x .
This makes the search approximately 1000 times faster than
the initial algorithm.

Still the initial setup creation is done with the original code.

See this thread on mastodon: https://sciences.social/@hn50@social.lansky.name/115239775879997755

***Note***
In order to run this software `cabal.project` has been added,
algorithm-x is expected to be placed parallel to this (`wpp`)
directory named `algorithm-x` and the cabal file had to be
adopted for version bounds, and I renamed it to `AlgorithmX.cababl`,
matching the `name` in the cabal file.


## Source code
`WPmodule.hs` contains, more or less, the original code.

`wooden_puzzle_parallel.hs` uses `WPmodule` and adds code for running in
parallel as well as printing maps of the results using the module `WPmap`. 

Some snippets from "Knuths Algorithm X"
https://en.wikipedia.org/wiki/Knuth%27s_Algorithm_X already used
by https://rtomas.web.cern.ch/rtomas/Ypentacubes/ have been introduced.
I.e.  from the list of candidates (`as`) all pieces having a voxel in common
with the just retrieved `newPiece` are removed (`as'`) before passing
it on to obtain the next subsolution. Accordingly the free voxel used
in the current step is removed from the list of voxels before
passing it on to the next step.

### Version using algorithm-x
In the versions `WPmoduleAx.hs` and `wooden_puzzle_ax.hs` the implementation
https://github.com/AlexeyFeigin/algorithm-x of Knuth's algorithm X
is used.

### Checking the results
`compWoodenPuzzle.hs` does some basic analysis of the solutions.
It checks if the solutions would only differ by the order they
are listed (permutations). This is does not happen. And it counts
the number of unique solutions, not being symmetric transformations of each other.
As found elsewhere, in total there are 60672 solutions, which are not just different
perturbations and 1264 unique solutions.

### Helper code
`StaticPieces.hs` contains the list of all possible placements of the pieces in static lists.
`StaticPiecesMain.hs` has been used to create the static lists from the original candidates.

### Parallel running
Grégoirei's function `pickFreeVoxel` starts in the corner (1 1 1).
There are 12 pieces that can be placed in this corner. For running
parallel these 12 pieces are extracted from the candidates pieces
and for each one of them a thread is created running with one of these
12 pieces and the remaining candidates, not containing any piece
that contains the voxel (1 1 1). This way twelve threads are run
in parallel. By chance my laptop has twelve cores, allowing
to run the threads simultaneously
(not just by splitting time between thread).

This has also been used in `wooden_puzzle_ax.hs` using algorithm-x.


## The representation as 2d maps

The output lists the 3d solution as fife 2d maps.

Each 2d map represents one of the fife layers of the 5x5x5 cube.

The 5 voxels in a piece are named by the letters A to E according to:

```
        E
    A B C D
```

The 25 pieces in the solutions are just numbered, as they appear from 1 to 25.

In the 2d maps the 5x5 voxels are named by the piece number (L:1..25) and the voxel name (N:A..E): `N.L`.

# Output
As an example the last unique solution (last of the 1264( found is printed by running 
```
cat data/wp-algoX.txt | cabal run comp
```

```
orig length: 60672
solutions with length 25: 60672
nub length: 60672
last unique:
1264
[[V3 1 1 1,V3 1 2 1,V3 1 3 1,V3 1 4 1,V3 2 3 1],[V3 1 1 2,V3 1 1 3,V3 1 1 4,V3 1 1 5,V3 2 1 4],[V3 1 2 3,V3 2 2 3,V3 3 2 3,V3 4 2 3,V3 3 3 3],[V3 1 2 4,V3 2 2 4,V3 3 2 4,V3 4 2 4,V3 3 3 4],[V3 1 2 5,V3 2 2 5,V3 3 2 5,V3 4 2 5,V3 3 3 5],[V3 1 3 5,V3 1 3 4,V3 1 3 3,V3 1 3 2,V3 2 3 3],[V3 1 4 3,V3 2 4 3,V3 3 4 3,V3 4 4 3,V3 3 5 3],[V3 1 5 4,V3 1 5 3,V3 1 5 2,V3 1 5 1,V3 1 4 2],[V3 1 5 5,V3 2 5 5,V3 3 5 5,V3 4 5 5,V3 3 5 4],[V3 2 1 1,V3 3 1 1,V3 4 1 1,V3 5 1 1,V3 4 1 2],[V3 2 1 3,V3 3 1 3,V3 4 1 3,V3 5 1 3,V3 4 1 4],[V3 2 2 1,V3 3 2 1,V3 4 2 1,V3 5 2 1,V3 4 2 2],[V3 2 4 2,V3 2 3 2,V3 2 2 2,V3 2 1 2,V3 1 2 2],[V3 2 5 4,V3 2 5 3,V3 2 5 2,V3 2 5 1,V3 3 5 2],[V3 3 1 2,V3 3 2 2,V3 3 3 2,V3 3 4 2,V3 3 3 1],[V3 4 3 1,V3 4 3 2,V3 4 3 3,V3 4 3 4,V3 5 3 3],[V3 4 4 4,V3 3 4 4,V3 2 4 4,V3 1 4 4,V3 2 3 4],[V3 4 4 5,V3 3 4 5,V3 2 4 5,V3 1 4 5,V3 2 3 5],[V3 4 5 4,V3 4 5 3,V3 4 5 2,V3 4 5 1,V3 4 4 2],[V3 5 1 2,V3 5 2 2,V3 5 3 2,V3 5 4 2,V3 5 3 1],[V3 5 1 5,V3 4 1 5,V3 3 1 5,V3 2 1 5,V3 3 1 4],[V3 5 4 1,V3 4 4 1,V3 3 4 1,V3 2 4 1,V3 3 5 1],[V3 5 4 4,V3 5 3 4,V3 5 2 4,V3 5 1 4,V3 5 2 3],[V3 5 5 1,V3 5 5 2,V3 5 5 3,V3 5 5 4,V3 5 4 3],[V3 5 5 5,V3 5 4 5,V3 5 3 5,V3 5 2 5,V3 4 3 5]]

 1.A  10.A  10.B  10.C  10.D
 1.B  12.A  12.B  12.C  12.D
 1.C   1.E  15.E  16.A  20.E
 1.D  22.D  22.C  22.B  22.A
 8.D  14.D  22.E  19.D  24.A

 2.A  13.D  15.A  10.E  20.A
13.E  13.C  15.B  12.E  20.B
 6.D  13.B  15.C  16.B  20.C
 8.E  13.A  15.D  19.E  20.D
 8.C  14.C  14.E  19.C  24.B

 2.B  11.A  11.B  11.C  11.D
 3.A   3.B   3.C   3.D  23.E
 6.C   6.E   3.E  16.C  16.E
 7.A   7.B   7.C   7.D  24.E
 8.B  14.B   7.E  19.B  24.C

 2.C   2.E  21.E  11.E  23.D
 4.A   4.B   4.C   4.D  23.C
 6.B  17.E   4.E  16.D  23.B
17.D  17.C  17.B  17.A  23.A
 8.A  14.A   9.E  19.A  24.D

 2.D  21.D  21.C  21.B  21.A
 5.A   5.B   5.C   5.D  25.D
 6.A  18.E   5.E  25.E  25.C
18.D  18.C  18.B  18.A  25.B
 9.A   9.B   9.C   9.D  25.A



number of unique solutions: 1264
586.264451437 seconds.
```


