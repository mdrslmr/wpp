module Fltr (
    fltrMax
) where

fltrMax :: (a -> Bool) -> Int -> [a] -> [a]
fltrMax _ _ [] = []
fltrMax _ 0 xs = xs
fltrMax f n (x:xs) | f x = x : fltrMax f n xs
                   | otherwise = fltrMax f (n-1) xs
