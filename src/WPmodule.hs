{-
 - This code has been (mostly) extracted 
 - from https://glocq.github.io/en/blog/20250428/
 - written by Grégoire Locqueville.
 -
-}


module WPmodule (
    Shape,
    candidateRotations,
    allSolutionsSmart,
    allValidPieces 
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
  [ Disposition rot trans | rot   <- candidateRotations
                          , trans <- candidateTranslations ]

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


conflict :: Shape -> Shape -> Bool
conflict occs piece = any (`elem` piece) occs

pickFreeVoxel :: Shape -> V3 Int
pickFreeVoxel alreadyOccupiedVoxels =
  head $
  filter (`notElem` alreadyOccupiedVoxels)
  [V3 x y z | x <- [1..5], y <- [1..5], z <- [1..5]]

subsolutionsSmart :: [Shape] -- candidates
                  -> Int   -- ^ How many pieces should be in the subsolution we're looking for?
                  -> Shape -- ^ Unavailable voxels, already occupied by some piece
                  -> [[Shape]]
subsolutionsSmart _ 0 _ = [[]]
subsolutionsSmart as n occupiedVoxels = do
  let freeVoxel = pickFreeVoxel occupiedVoxels
  newPiece <- filter
                  (\piece -> elem freeVoxel piece &&
                             not (conflict occupiedVoxels piece)
                  )
                  as

  let updatedOccupiedVoxels = newPiece <> occupiedVoxels
  otherPieces <- subsolutionsSmart as (n - 1) updatedOccupiedVoxels
  return $ newPiece : otherPieces

allSolutionsSmart :: [Shape] -> [[Shape]]
allSolutionsSmart as = subsolutionsSmart as 25 []

