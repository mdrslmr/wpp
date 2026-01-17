
module WPmap (
    VShape,
    formatMap,
    cube
) where

import Text.Printf
import Linear.V3 (V3(V3))
import Data.List (sortBy)

{-
 - Assigning symbols to the pieces parts:
 -
 -     E
 - A B C D
 -
-}

data Symbol = A | B | C | D | E
    deriving (Show, Eq, Ord)

type Map = [(V3 Int, Int, Symbol)]

type VShape = [V3 Int]

cube :: [VShape] -> Map
cube vs = foldl symPiece [] (zip [1..] vs)

symPiece :: Map -> (Int, VShape) -> Map
symPiece m (i, vs) = zip3 vs (repeat i) [A,B,C,D,E] ++ m

formatMap :: Map -> String
formatMap m = formatLines 1 (sortBy myord m)
myord  :: (V3 Int, Int, a) -> (V3 Int, Int, a) -> Ordering
myord (V3 a b c, _, _) (V3 d e f, _, _) = compare c f `mappend`
                                          compare b e `mappend`
                                          compare a d

formatLines :: Int -> Map -> String
formatLines i ((_,j,s):xs) = printf "%2d" j <> "." <> show s <> sep <>
                formatLines (i+1) xs
            where sep | i `mod` 25 == 0 = "\n\n"
                      | i `mod`  5 == 0 = "\n"
                      | otherwise = "  "
formatLines _ [] = "\n"
