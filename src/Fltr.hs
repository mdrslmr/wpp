module Fltr (
    fltr,
    fltrMax
) where

fltrMax :: (a -> Bool) -> Int -> [a] -> ([a],[a])
fltrMax f n xs = sepMax f n xs ([],[])

sepMax :: (a -> Bool) -> Int -> [a] -> ([a],[a]) -> ([a],[a])
sepMax _ _ [] (ys,rs) = (reverse ys,reverse rs)
sepMax _ 0 xs (ys,rs) = (reverse ys++xs,reverse rs)
sepMax f n (x:xs) (ys,rs) | f x =  sepMax f n xs (x:ys,rs)
                          | otherwise = sepMax f (n-1) xs (ys,x:rs)

fltr :: (a -> Bool) -> [a] -> ([a],[a])
--fltr p xs = (filter p xs, filter (not.p) xs)
fltr f xs = sep f xs ([],[])

sep :: (a -> Bool) -> [a] -> ([a],[a]) -> ([a],[a])
sep _ [] (ys,rs) = (reverse ys,reverse rs)
sep f (x:xs) (ys,rs) | f x =  sep f xs (x:ys,rs)
                     | otherwise = sep f xs (ys,x:rs)

