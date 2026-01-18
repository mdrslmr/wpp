{-# LANGUAGE TupleSections #-}
module WPstats (
    stFreq
) where

import Data.Maybe (fromMaybe)
import qualified Data.IntMap as IM (IntMap, insert, lookup, empty)
import qualified Data.Map as DM (fromList, insert, insert, lookup, Map, elems)
import WPmodule ( Shape )
import StaticPieces (staticPieces2)

shapeNum :: DM.Map Shape (Int, Int)
shapeNum = DM.fromList $ zip staticPieces2 $
                map (,0) [1.. length staticPieces2]

stFreq :: [[Shape]] -> IM.IntMap Int
stFreq xs = toFreq IM.empty $ DM.elems $ stFreqI xs

toFreq :: IM.IntMap Int -> [(Int, Int)] -> IM.IntMap Int 
toFreq im [] = im
toFreq im ((_,c):xs) = toFreq (IM.insert c (f+1) im) xs
        where
            f = fromMaybe 0 (IM.lookup c im) 

stFreqI :: [[Shape]] -> DM.Map Shape (Int, Int)
stFreqI xs = doShapes shapeNum (concat xs)

doShapes :: DM.Map Shape (Int, Int) -> [Shape] -> DM.Map Shape (Int, Int)
doShapes = foldl inc

inc :: DM.Map Shape (Int, Int) -> Shape -> DM.Map Shape (Int, Int)
inc ms s = DM.insert s v ms
        where
            (n,c) = fromMaybe (-1,0) (DM.lookup s ms)
            v = (n, c+1)


