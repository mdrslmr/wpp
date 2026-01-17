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


