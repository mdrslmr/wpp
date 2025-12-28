module Main (main) where

import Linear.V3 (V3)
import Data.List (partition, sort)
import WPmodule (emptyBox, allValidPieces)

sortPieces :: [V3 Int] -> [[V3 Int]] -> [[V3 Int]]
sortPieces [] _ = [[]]
sortPieces [b] ps = filter (b `elem`) ps
sortPieces (b:box) ps = ms ++ sortPieces box ns
                        where (ms,ns) = partition  (b `elem`) ps

-- create static list of pieces sorted along the order of the box's voxels 
dosort :: [[V3 Int]]
dosort = sortPieces emptyBox (sort allValidPieces)

main :: IO ()
main = do
    print dosort

