module Main where

import Data.Time.Clock (getCurrentTime, diffUTCTime, UTCTime)
import Linear.V3 (V3(V3))
import Data.List (sortBy)
import Control.Concurrent (forkIO, putMVar, takeMVar, newMVar, MVar, threadDelay)
import WPmodule ( Shape, allSolutionsSmart, allValidPieces )

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
                                -> IO ()
printSolutions n _ [] mv = do
    (i,t, s) <- takeMVar mv
    putStrLn $ "Thread " <> show n <> " done." 
    putMVar mv (i, t-1, s)
    return ()
printSolutions n startTime (x:xs) mv = do
    (i,t,_) <- takeMVar mv
    endTime <- getCurrentTime
    print x
    putStrLn ""
    putStrLn $ formatMap $ cube x
    putStrLn $ "Thread " <> show n <> " found solution " 
                <> show i <> " in " <> show (realToFrac
                (diffUTCTime endTime startTime) :: Double) <> " seconds."
    putStrLn ""
    putMVar mv (i+1, t,True)
    nextStart <- getCurrentTime
    printSolutions n nextStart xs mv
    

pickFirsts :: [Shape] -> ([Shape],[Shape]) -> ([Shape],[Shape])
pickFirsts [] (fs,rs) = (fs,rs)
pickFirsts (a:as) (fs,rs) | V3 1 1 1 `elem` a = pickFirsts as (a:fs,rs)
                          | otherwise = pickFirsts as (fs,a:rs)

findAllParallel :: Int ->  ([Shape], [Shape]) -> UTCTime ->
                    MVar (Int, Int, Bool) -> IO ()
findAllParallel _ ([], _) _ _ = return ()
findAllParallel n (f:fs,as) startTime mv = do
    putStrLn $ "start thread: " <> show n
    _ <- forkIO $ printSolutions n startTime (allSolutionsSmart (f:as)) mv
    (i,t, started) <- takeMVar mv
    putMVar mv (i,t+1, started)
    findAllParallel (n+1) (fs,as) startTime mv

waitMvar :: (Int -> Bool) -> MVar (Int, Int, Bool) -> IO ()
waitMvar f mv = do
    (i,t, started) <- takeMVar mv
    if  not started || (t>0 && f i) then
        do
            putMVar mv (i,t, started)
            threadDelay 10000000
            waitMvar f mv
    else
        do
            putMVar mv (i,t, started)

main :: IO ()
main = do
    startTime <- getCurrentTime

    mv <- newMVar (1,0,False)
    findAllParallel 1 (pickFirsts allValidPieces ([],[]))  startTime mv

--    waitMvar (<20) mv
    waitMvar (const True) mv

    putStrLn "done"
