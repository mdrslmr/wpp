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
 
## Statistics
The function `stFreq` from module `WPstats` produces a frequency list,
showing the number of times pieces occurs in the solutions paired with
the number of how many pieces with this number of occurrences exist.

Frequencies for all 60672 solutions:
```
totFreq: 
[(352,24),(458,48),(666,24),(700,24),(741,48),(752,48),(824,24),(834,24),(876,24),(986,24),(1060,48),(1072,48),(1130,48),(1157,48),(1159,48),(1190,48),(1213,48),(1218,24),(1394,48),(1546,48),(2657,48),(2731,48),(4667,48),(5445,48)]
```
All pieces are used, the sum of the second tuple entry is 960.

They are used either 24 or 48 times.


Frequencies for the unique solutions:
```
uqFreq: 
[(0,334),(1,11),(2,30),(3,13),(4,42),(5,8),(6,20),(7,2),(8,42),(9,3),(10,24),(11,1),(12,17),(13,5),(14,7),(15,1),(16,22),(17,4),(18,16),(19,4),(20,20),(21,4),(22,8),(23,1),(24,10),(25,6),(26,8),(27,1),(28,11),(29,2),(30,4),(31,2),(32,26),(33,6),(34,6),(35,1),(36,8),(37,3),(38,2),(39,1),(40,11),(42,7),(43,3),(44,7),(45,2),(46,5),(47,1),(48,5),(49,3),(50,6),(51,2),(52,6),(53,1),(54,2),(55,2),(56,4),(58,2),(60,2),(61,2),(62,6),(63,1),(64,7),(65,1),(66,4),(67,1),(69,2),(70,2),(71,2),(72,4),(73,1),(74,3),(75,3),(76,2),(77,2),(78,2),(81,1),(82,2),(84,3),(87,3),(90,2),(92,5),(93,2),(95,4),(96,2),(97,2),(99,1),(100,1),(102,2),(104,3),(105,1),(106,1),(109,1),(110,3),(111,1),(112,1),(114,1),(116,2),(117,1),(119,1),(120,2),(124,2),(125,2),(127,1),(128,1),(129,1),(130,1),(131,1),(137,2),(138,1),(143,1),(151,1),(152,1),(154,1),(157,1),(158,1),(161,1),(162,1),(164,1),(165,1),(168,1),(172,2),(173,1),(180,1),(181,1),(190,1),(196,1),(202,1),(208,1),(210,1),(212,1),(216,1),(217,1),(220,1),(223,1),(229,1),(235,2),(252,2),(254,1),(259,1),(265,1),(284,1),(301,1),(318,1),(349,1),(352,1),(384,1),(394,1),(415,1),(464,1),(482,1),(569,1),(585,1),(592,1),(776,1)]
```
