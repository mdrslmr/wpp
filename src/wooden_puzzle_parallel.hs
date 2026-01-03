module Main where

import Data.Time.Clock (getCurrentTime, diffUTCTime, UTCTime)
import Linear.V3 (V3(V3))
import Data.List (sortBy)
import Control.Concurrent (forkIO, putMVar, takeMVar, newMVar, MVar)
import WPmodule ( Shape, allSolutionsSmart)
import Control.Monad (when, unless)
import StaticPieces (staticPieces2)
import System.IO (hSetBuffering, stdout, BufferMode(LineBuffering))

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

cube :: [Shape] -> Map
cube = foldl symPiece []

symPiece :: Map -> Shape -> Map
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


printSolutions :: Int -> UTCTime -> [[Shape]] -> MVar (Int, Int, Bool)
                                -> MVar Bool
                                -> (Int -> Bool)
                                -> IO ()
printSolutions n _ [] mv mvTh f = do
    (i,t, _) <- takeMVar mv
    putStrLn $ "Thread " <> show n <> " done."
    let done = t==1 || f i
    when done  $ putMVar mvTh True
    putMVar mv (i, t-1, done)
    return ()
printSolutions n startTime (x:xs) mv mvTh f = do
    (i,t,done) <- takeMVar mv
    unless done $ do
        endTime <- getCurrentTime
        print x
        putStrLn ""
        putStrLn $ formatMap $ cube x
        putStrLn $ "Thread " <> show n <> " found solution "
                <> show i <> " in " <> show (realToFrac
                (diffUTCTime endTime startTime) :: Double) <> " seconds."
        putStrLn ""
        let done' = f i
        when done' $ putMVar mvTh True
        putMVar mv (i+1, t, done')
        unless done' $ do
            printSolutions n startTime xs mv mvTh f


pickFirsts :: [Shape] -> ([Shape],[Shape]) -> ([Shape],[Shape])
pickFirsts [] (fs,rs) = (fs,rs)
pickFirsts (a:as) (fs,rs) | V3 1 1 1 `elem` a = pickFirsts as (a:fs,rs)
                          | otherwise = pickFirsts as (fs,a:rs)
-- helper used to calculate number conflicting pieces with one
-- piece containg the middle piece -> 228
--conf :: [Shape] -> ([Shape],[Shape]) -> ([Shape],[Shape])
--conf [] (fs,rs) = (fs,rs)
--conf (a:as) (fs,rs) | any (`elem` [V3 1 3 3, V3 2 3 3, V3 3 3 3, V3 4 3 3, V3 3 2 3]) a = conf as (a:fs,rs)
--                          | otherwise = conf as (fs,a:rs)

findAllParallel :: Int ->  ([Shape], [Shape]) -> UTCTime ->
                    MVar (Int, Int, Bool) -> MVar Bool -> (Int -> Bool) -> IO ()
findAllParallel _ ([], _) _ _ _  _ = return ()
findAllParallel n (f:fs,as) startTime mv mvTh g = do
    putStrLn $ "start thread: " <> show n
    _ <- forkIO $ printSolutions n
                                 startTime
                                 (allSolutionsSmart (f:as))
                                 mv
                                 mvTh
                                 g
    (i,t, done) <- takeMVar mv
    putMVar mv (i,t+1, done)
    findAllParallel (n+1) (fs,as) startTime mv mvTh g




main :: IO ()
main = do
    hSetBuffering stdout LineBuffering

    startTime <- getCurrentTime

    mv <- newMVar (1,0,False)
    mvTh <- newMVar False
    _ <- takeMVar mvTh
    findAllParallel 1
            (pickFirsts staticPieces2 ([],[]))
            startTime
            mv
            mvTh
            (const False)
            -- (>=20)

    _ <- takeMVar mvTh

    putStrLn "done"
