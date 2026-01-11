module Main where

import Data.Time.Clock (getCurrentTime, diffUTCTime, UTCTime)
import Data.List (sortBy)
import Control.Concurrent (forkIO, putMVar, takeMVar, newMVar, MVar)
import WPmoduleAx (IShape)
import Control.Monad (when, unless)
import StaticPieces (staticPieces2List, staticPieces2)
import System.IO (hSetBuffering, stdout, BufferMode(LineBuffering))
import qualified Data.IntSet as I (member, notMember, fromList, Key)
import qualified Data.IntMap as IM (fromList) 
import Linear.V3 (V3(V3))
import AlgorithmX (SparseMatrix(SparseMatrix), algoX)
import Data.Maybe (fromMaybe)

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

boxMap :: [(Int, [V3 Int])]
boxMap = zip [1..] staticPieces2

conv :: Int -> [V3 Int]
conv i =  fromMaybe [] (lookup i boxMap)

convItoV :: [I.Key] -> [[V3 Int]]
convItoV = map conv

printSolutions :: Int -- thread number
                -> UTCTime -- starting time
                -> [[I.Key]] -- solutions
                -> MVar (Int, Int, Bool) -- synchronize printing
                -> MVar () -- communicate end of run from thread to main
                -> (Int -> Bool) -- condition for ending run
                -> IO ()
printSolutions n _ [] mv mvTh f = do
    (i,t, _) <- takeMVar mv
    putStrLn $ "Thread " <> show n <> " done."
    let done = t==1 || f i
    when done  $ putMVar mvTh ()
    putMVar mv (i, t-1, done)
    return ()
printSolutions n startTime (x:xs) mv mvTh f = do
    (i,t,done) <- takeMVar mv
    let i' = i+1
    unless done $ do
        endTime <- getCurrentTime
        let v = convItoV x :: [VShape]
        print x
        print v
        putStrLn ""
        putStrLn $ formatMap $ cube v
        putStrLn $ "Thread " <> show n <> " found solution "
                <> show i' <> " in " <> show (realToFrac
                (diffUTCTime endTime startTime) :: Double) <> " seconds."
        putStrLn ""
        let done' = f i'
        when done' $ putMVar mvTh ()
        putMVar mv (i', t, done')
        unless done' $ do
            printSolutions n startTime xs mv mvTh f


findAllParallel :: Int -> [IShape] -> [IShape] -> UTCTime ->
                    MVar (Int, Int, Bool) -> MVar () -> (Int -> Bool) -> IO ()
findAllParallel _ [] _ _ _ _  _ = return ()
findAllParallel n (f:fs) as startTime mv mvTh g = do
    let n' = n+1
    (i,t, done) <- takeMVar mv
    putMVar mv (i,t+1, done)
    putStrLn $ "start thread: " <> show n'
    let rows1 = IM.fromList $ zip [1..] (f:as)
    let m1 = SparseMatrix rows1 (I.fromList [1..125])
    _ <- forkIO $ printSolutions n'
                                 startTime
                                 (algoX m1)
                                 mv
                                 mvTh
                                 g
    findAllParallel n' fs as startTime mv mvTh g




main :: IO ()
main = do
    hSetBuffering stdout LineBuffering

    startTime <- getCurrentTime

    mv <- newMVar (0,0,False) -- #solutions, #running threads, run is done
    mvTh <- newMVar ()
    _ <- takeMVar mvTh
    findAllParallel 0
            (filter (1 `I.member`) (map I.fromList staticPieces2List))
            (filter (1 `I.notMember`) (map I.fromList staticPieces2List))
            startTime
            mv
            mvTh
            (const False)
            -- (>=20)

    _ <- takeMVar mvTh

    putStrLn "done"
