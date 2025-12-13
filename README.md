# wpp

This software is largely taken from Grégoire Locqueville:
https://glocq.github.io/en/blog/20250428/

## Source code

`WPmodule.hs` contains the code from the above link , with a few tiny
modifications.

`wooden_puzzle_parallel.hs` uses `WPmodule` and adds code for running in
parallel as well as printing maps (https://github.com/mdrslmr/wooden\_map)
of the results. 

`compWoodenPuzzle.hs` does some basic analysis of the solutions. It finds
solutions containing twins (pieces placed side by side) and back-to-back
pieces.
Second it checks if the solutions would only differ by the order they
are listed (permutations). And it counts how many solutions are just
rotations or reflections of the others.

## Data

`data/wp-inf.txt` Is the result produced with running a 12 core laptop
for about 48h. It contains 1898 solutions. The solutions are not just
perturbations of one another. But there are some which are rotations or
reflections of each other.


## Comment

The original authors (Grégoire Locqueville) ingenious function
`pickFreeVoxel` speeds up the search by building the puzzle up step by
step and prevents to try paths that just differ in the order they are
listed. This too prevents to have solutions that are just perturbations
of each other.

My first attempt to exclude some combinations of pieces (twins, back to back)
was a bad idea. It initially, by chance, actually did speed up to
find the very first solution quicker. But when I tried to find more solutions
it looks like this exclusion actually slowed down finding them. 

The analysis produced by running `cbal run comp` using the result in `data` 
shows:
```
orig length 1898  -- (number of solutions)
nub length 1898   -- (number of solutions with duplicates removed)
twins found: 1754 -- (number of pieces side by side)
btb found: 1829   -- (number of pieces back to back)
```

Since the orig length and the "nub" (duplicate removed) length are
identical, there are no identical solutions that are just printed
in a different order (no perturbations).

There are very many twins and btb in the solutions, so my first
attempt, that unfortunately succeeded by chance, was a typical
"N=1" study.

## Parallel
Grégoirei's function `pickFreeVoxel` starts in the corner (1 1 1).
There are 12 pieces that can be placed in this corner. For running
parallel these 12 pieces are extracted from the candidates pieces
and for each one of them a thread is created running with one of these
12 pieces and the remaining candidates, not containing any piece
that contains the voxel (1 1 1). This way twelve threads are run
in parallel. By chance my laptop has twelve cores, allowing
to run the threads simultaneously
(not just by splitting time between thread).


