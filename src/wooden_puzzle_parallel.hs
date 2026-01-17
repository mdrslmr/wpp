module Main where

import Data.Time.Clock (getCurrentTime, diffUTCTime, UTCTime)
import Control.Concurrent (forkIO, putMVar, takeMVar, newMVar, MVar)
import WPmodule (Shape, allSolutionsSmart)
import Control.Monad (when, unless)
import StaticPieces (staticPieces2)
import System.IO (hSetBuffering, stdout, BufferMode(LineBuffering))
import WPmap (formatMap, cube)

printSolutions :: Int -- thread number
                -> UTCTime -- starting time
                -> [[Shape]] -- solutions
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
        print x
        putStrLn ""
        putStrLn $ formatMap $ cube x
        putStrLn $ "Thread " <> show n <> " found solution "
                <> show i' <> " in " <> show (realToFrac
                (diffUTCTime endTime startTime) :: Double) <> " seconds."
        putStrLn ""
        let done' = f i'
        when done' $ putMVar mvTh ()
        putMVar mv (i', t, done')
        unless done' $ do
            printSolutions n startTime xs mv mvTh f


findAllParallel :: Int -> [Shape] -> [Shape] -> UTCTime ->
                    MVar (Int, Int, Bool) -> MVar () -> (Int -> Bool) -> IO ()
findAllParallel _ [] _ _ _ _  _ = return ()
findAllParallel n (f:fs) as startTime mv mvTh g = do
    let n' = n+1
    (i,t, done) <- takeMVar mv
    putMVar mv (i,t+1, done)
    putStrLn $ "start thread: " <> show n'
    _ <- forkIO $ printSolutions n'
                                 startTime
                                 (allSolutionsSmart (f:as))
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
            (filter (1 `elem`) staticPieces2)
            (filter (1 `notElem`) staticPieces2)
            startTime
            mv
            mvTh
            (const False)
            -- (>=20)

    _ <- takeMVar mvTh

    putStrLn "done"
