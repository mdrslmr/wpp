module Main where

import Data.List (sort, nub)
import System.IO (hSetBuffering, stdout, BufferMode(LineBuffering))
import Linear.V3 (V3(V3))
import Linear.Matrix (M33, identity, transpose, (!*!), (!*))
import Text.Regex.TDFA ( AllTextMatches(getAllTextMatches), (=~) )
import WPmodule ( candidateRotations, Shape )

pattern :: String
pattern = "\\[(\\[[V,12345 ]+\\],*)+\\]"

toShape :: [String] -> [[Shape]]
toShape = map (\x -> (read x :: [Shape]))


len :: V3 Int -> Float
len (V3 x y z) = sqrt (x'*x' + y'*y' + z'*z')
                where
                    x' = fromIntegral x :: Float
                    y' = fromIntegral y :: Float
                    z' = fromIntegral z :: Float

exclude :: Shape -> Shape -> Bool
exclude [a1, _, _, d1, e1]  [a2, _, _, d2, e2] =
    a < 1.1 && d < 1.1 && e < 1.1
        where   a = len (a2 - a1)
                d = len (d2 - d1)
                e = len (e2 - e1)
exclude _ _  = False

exbtb :: Shape -> Shape -> Bool
exbtb [a1, _, _, d1, e1]  [a2, _, _, d2, e2] =
    a < 1.1 && d < 1.1 && e > 1.9
        where   a = len (a2 - a1)
                d = len (d2 - d1)
                e = len (e2 - e1)
exbtb _ _  = False

chkelm :: (Eq a) => (a -> a -> Bool) -> [a] -> Bool
chkelm _ [] = False
chkelm f (c:cs)  | any (f c) cs = True
                 | otherwise = chkelm f cs

twins :: [[Shape]] -> Int -> [Int]
twins [] _ = []
twins (x:xs) n | chkelm exclude x = n : twins xs (n+1)
            | otherwise        = twins xs (n+1)

btb :: [[Shape]] -> Int -> [Int]
btb [] _ = []
btb (x:xs) n | chkelm exbtb x = n : btb xs (n+1)
             | otherwise        = btb xs (n+1)

solsFromContent :: String -> [[Shape]]
solsFromContent content = toShape ms
                where
                    ms = getAllTextMatches (content =~ pattern) :: [String]

isOrtho :: M33 Int -> Bool
isOrtho matrix = (Linear.Matrix.transpose matrix !*! matrix) == identity


allOrthos :: [M33 Int]
allOrthos = filter isOrtho candidateRotations

rotcomp :: [Shape] -> [[Shape]] -> Int
rotcomp _ [] = 0
rotcomp c (a:as) = go c a  + rotcomp c as
    where go :: [Shape] -> [Shape] -> Int
          go x y |  x == sort y  = 1
                 |     otherwise = 0

rotShape :: (V3 Int -> V3 Int) -> Shape -> Shape
rotShape _ [] = []
rotShape f (a:as) = f a : rotShape f as

compSols :: (V3 Int -> V3 Int) -> [[Shape]] -> [Int]
compSols _ [] = []
compSols f (a:as) = rotcomp (sort (map (rotShape f) a)) as : compSols f as

mRot :: M33 Int -> V3 Int -> V3 Int
mRot m v = V3 3 3 3 + m !* (v - V3 3 3 3)

printRots :: [M33 Int] -> [[Shape]] -> Int -> IO ()
printRots [] _ t = do putStrLn  $ "total symmetric images: " <> show t
printRots (m:ms) solutions t = do
    let sols = compSols (mRot m) solutions
    putStrLn ""
    print m
    let ti = sum sols
    print ti
    print sols
    printRots ms solutions (t+ti)

nonDoublets :: [Shape] -> [[Shape]] -> [[Shape]]
nonDoublets _ [] = []
nonDoublets c (a:as) | doublet c a = rest
                     | otherwise = a : rest
    where doublet :: [Shape] -> [Shape] -> Bool
          doublet x y |  x == sort y  = True
                      |     otherwise = False
          rest = nonDoublets c as

nonSimilars :: (V3 Int -> V3 Int) -> [[Shape]] -> [[Shape]]
nonSimilars _ [] = []
nonSimilars f (a:as) = a : nonSimilars f
                        (nonDoublets (sort (map (rotShape f) a)) as)


findUnique :: [M33 Int] -> [[Shape]] -> [[Shape]]
findUnique [] us = us
findUnique (m:ms) solutions =
    findUnique ms (nonSimilars (mRot m) solutions)

main :: IO ()
main = do
    hSetBuffering stdout LineBuffering
    content <- getContents
    let solutions = solsFromContent content
    let sols25 = filter (\s -> length s == 25) solutions
    let nubsols = nub (map sort sols25)

{-
    printRots allOrthos nubsols 0
    putStrLn $ "    found in " <> show (length allOrthos) <>
                                            " othonormal transformations"
-}
    putStrLn $ "orig length: " <> show (length solutions)
    putStrLn $ "solutions with length 25: " <> show (length sols25)
    putStrLn $ "nub length: " <> show (length nubsols)
    let unique = findUnique allOrthos nubsols
    putStrLn $ "number of unique solutions: " <> show (length unique)



