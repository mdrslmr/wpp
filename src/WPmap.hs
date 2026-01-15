
module WPmap (
    VShape,
    formatMap,
    cube
) where

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

type Map = [(V3 Int, Symbol)]

type VShape = [V3 Int]

cube :: [VShape] -> Map
cube = foldl symPiece []

symPiece :: Map -> VShape -> Map
symPiece m vs = zip vs [A,B,C,D,E] ++ m

formatMap :: Map -> String
formatMap m = formatLines 1 (sortBy myord m)
myord  :: (V3 Int, a) -> (V3 Int, a) -> Ordering
myord (V3 a b c, _) (V3 d e f, _) = compare c f `mappend`
                                    compare b e `mappend`
                                    compare a d

formatLines :: Int -> Map -> String
formatLines i ((_,s):xs) = show s ++ sep ++ formatLines (i+1) xs
            where sep | i `mod` 25 == 0 = "\n\n"
                      | i `mod`  5 == 0 = "\n"
                      | otherwise = " "
formatLines _ [] = "\n"
