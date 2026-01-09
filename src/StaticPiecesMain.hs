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

v3map = zip [V3 x y z | x <- [1..5], y <- [1..5], z <- [1..5]] [1..]

convV3toList :: V3 Int -> Int
convV3toList v = i
    where Just i = lookup v v3map 

convV3OieceToV3List :: [V3 Int] -> [Int]
convV3OieceToV3List [a,b,c,d,e] = [convV3toList a,
                                   convV3toList b,
                                   convV3toList c,
                                   convV3toList d,
                                   convV3toList e]

main :: IO ()
main = do
    print $ fmap convV3OieceToV3List staticPieces2

