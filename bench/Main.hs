{-# LANGUAGE BangPatterns #-}
module Main (main) where

import Kanren.Core
import Kanren.Goal
import qualified Kanren.Data.Binary as Binary
import           Kanren.Data.Binary (Binary)
import           Criterion.Main

exp3o :: Binary -> Term Binary -> Goal ()
exp3o n e3n = Binary.logo e3n (inject' 3) (inject' n) (inject' 0)

log3o :: Binary -> Term Binary -> Goal ()
log3o n log3n = do
  r <- fresh
  Binary.logo (inject' n) (inject' 3) log3n r

whnfGoalOnce :: Fresh v => (a -> v -> Goal ()) -> a -> Benchmarkable
whnfGoalOnce f = whnf $ \x ->
  case run (f x) of
    []  -> Nothing
    !r:_ -> Just r

main :: IO ()
main = defaultMain
  [ bgroup "3^n "
    [ bench (" n=" <> show n) $ whnfGoalOnce exp3o (fromIntegral n)
    | n <- [0..5 :: Int]
    ]
  , bgroup "log_3 n "
    [ bench (" n=" <> show n) $ whnfGoalOnce log3o (fromIntegral n)
    | p <- [0..5 :: Int]
    , let n = 3^p :: Int
    ]
  ]