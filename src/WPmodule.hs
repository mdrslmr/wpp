{-
 - This code has been extracted from:
 - https://glocq.github.io/en/blog/20250428/
 - written by Grégoire Locqueville.
 - Some small refactoring has been made.
 - The last commits introduce some snippets from "Knuth's Algorithm X",
 - see README.md.
-}


module WPmodule (
    Shape,
    candidateRotations,
    allSolutionsSmart,
    allValidPieces,
    emptyBox
) where

import Linear.V3 (V3(V3))
import Linear.Matrix (M33, identity, transpose, det33, (!*!), (!*))

type Shape = [V3 Int]

genericPiece :: [V3 Int]
genericPiece = [ V3 0 0 0, V3 0 0 1, V3 0 0 2, V3 0 0 3, V3 0 1 2 ]

data Disposition = Disposition
  { rotation    :: M33 Int
  , translation :: V3 Int
  } deriving Show

dispositionCoordinates :: Disposition -> [V3 Int]
dispositionCoordinates disposition = fmap applyTransform genericPiece
  where
  -- Note that we are applying the translation after the rotation. We could
  -- technically apply the the translation first, but I think it makes
  -- more intuitive sense to first choose our piece's orientation and then
  -- translate it. In the end, what matters is that we stick to our convention.
  applyTransform :: V3 Int -> V3 Int
  applyTransform vector =
    translation disposition + (rotation disposition !* vector)

candidateRotations :: [M33 Int]
candidateRotations = [
  -- The `M33` type is actually just two nested `V3` in a trench coat:
  V3 (V3 m11 m12 m13)
     (V3 m21 m22 m23)
     (V3 m31 m32 m33)
  | m11 <- [-1..1], m12 <- [-1..1], m13 <- [-1..1]
  , m21 <- [-1..1], m22 <- [-1..1], m23 <- [-1..1]
  , m31 <- [-1..1], m32 <- [-1..1], m33 <- [-1..1]
  ]
candidateTranslations :: [V3 Int]
candidateTranslations = [ V3 x y z | x <- [1..5], y <- [1..5], z <- [1..5] ]

candidateDispositions :: [Disposition]
candidateDispositions =
  [ Disposition { rotation=rot, translation=trans } |
                                            rot   <- candidateRotations,
                                            trans <- candidateTranslations ]

-- | Does the given matrix encode a rotation?
isRotation :: M33 Int -> Bool
isRotation matrix = ((transpose matrix !*! matrix) == identity) &&
                    (det33 matrix == 1)

pieceFitsTheBox :: Disposition -> Bool
pieceFitsTheBox disposition =
  all cubeFitsTheBox (dispositionCoordinates disposition)
  where cubeFitsTheBox :: V3 Int -> Bool
        cubeFitsTheBox (V3 x y z) = x >= 1 && x <= 5 &&
                                    y >= 1 && y <= 5 &&
                                    z >= 1 && z <= 5

isValidDisposition :: Disposition -> Bool
isValidDisposition disposition = isRotation (rotation disposition) &&
                                 pieceFitsTheBox disposition
allValidDispositions :: [Disposition]
allValidDispositions = filter isValidDisposition candidateDispositions

allValidPieces :: [[V3 Int]]
allValidPieces = fmap dispositionCoordinates allValidDispositions

emptyBox :: Shape
emptyBox = [V3 x y z | x <- [1..5], y <- [1..5], z <- [1..5]]

-- filter pieces containing a given voxel and producing boxes where
-- check succeeds
pfltr :: V3 Int -> Shape -> [Shape] -> [Shape]
pfltr _ _ [] = []
pfltr f box (p:ps) | f `elem` p = p : pfltr f box ps
                   | otherwise = pfltr f box ps

subsolutionsSmart :: [Shape] -- candidates
                  -> Int   -- ^ number of remaining subsolutions
                  -> Shape -- ^ box
                  -> [[Shape]]
subsolutionsSmart _ 0 _ = [[]]
subsolutionsSmart _ _ [] = [[]]
subsolutionsSmart as n (freeVoxel:box) = do
  newPiece <- pfltr freeVoxel box as

  -- remove pieces having voxels in common with the newPiece
  -- the idea is taken from Knuth's Algorithm X
  let box' = filter (`notElem` newPiece) box
  let bout = filter (`elem` newPiece) box
  let as' = filter (not.any (`elem` (newPiece<>bout)))  as
  otherPieces <- subsolutionsSmart as' (n - 1) box'
  return $ newPiece : otherPieces

allSolutionsSmart :: [Shape] -> [[Shape]]
allSolutionsSmart as = subsolutionsSmart as 25 emptyBox

