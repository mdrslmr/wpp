module Main (main) where

import Linear.V3 (V3(V3))
import Data.List (partition, sort)
import StaticPieces(staticPieces2)

sortPieces :: [V3 Int] -> [[V3 Int]] -> [[V3 Int]]
sortPieces [] _ = [[]]
sortPieces [b] ps = filter (b `elem`) ps
sortPieces (b:box) ps = ms ++ sortPieces box ns
                        where (ms,ns) = partition  (b `elem`) ps

-- create static list of pieces sorted along the order of the box's voxels 
--dosort :: [[V3 Int]]
--dosort = sortPieces emptyBox (sort allValidPieces)

convV3toList :: V3 Int -> [Int]
convV3toList (V3 x y z) = [x,y,z]

convV3OieceToV3List :: [V3 Int] -> [[Int]]
convV3OieceToV3List [a,b,c,d,e] = [convV3toList a,
                                   convV3toList b,
                                   convV3toList c,
                                   convV3toList d,
                                   convV3toList e]

main :: IO ()
main = do
    print $ fmap convV3OieceToV3List staticPieces2

