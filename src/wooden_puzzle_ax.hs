module Main where

import Data.Time.Clock (getCurrentTime, diffUTCTime, UTCTime)
import Control.Concurrent (forkIO, putMVar, takeMVar, newMVar, MVar)
import WPmoduleAx (IShape)
import Control.Monad (when, unless)
import StaticPieces (staticPieces2List, staticPieces2)
import System.IO (hSetBuffering, stdout, BufferMode(LineBuffering))
import qualified Data.IntSet as I (member, notMember, fromList, Key)
import qualified Data.IntMap as IM (fromList, filterWithKey, IntMap, insert,
                                   toList)
import Linear.V3 (V3)
import AlgorithmX (SparseMatrix(SparseMatrix), algoX)
import Data.Maybe (fromMaybe)
import WPmap ( VShape, formatMap, cube)



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


findAllParallel :: Int -> [(Int, IShape)] -> IM.IntMap IShape -> 
                   UTCTime ->
                    MVar (Int, Int, Bool) -> MVar () -> (Int -> Bool) -> IO ()
findAllParallel _ [] _ _ _ _  _ = return ()
findAllParallel n ((k,v):fs) as startTime mv mvTh g = do
    let n' = n+1
    (i,t, done) <- takeMVar mv
    putMVar mv (i,t+1, done)
    putStrLn $ "start thread: " <> show n'
    let rows1 = IM.insert k v as
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

    let allRows = IM.fromList $ zip [1..] (map I.fromList staticPieces2List)
    let firsts = IM.filterWithKey (\_ v -> 1 `I.member` v) allRows
    let rest =  IM.filterWithKey (\_ v -> 1 `I.notMember` v) allRows

    startTime <- getCurrentTime

    mv <- newMVar (0,0,False) -- #solutions, #running threads, run is done
    mvTh <- newMVar ()
    _ <- takeMVar mvTh
    findAllParallel 0
            (IM.toList firsts)
            rest
            startTime
            mv
            mvTh
            (const False)
            -- (>=20)

    _ <- takeMVar mvTh

    putStrLn "done"
