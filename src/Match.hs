{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RankNTypes #-}
{-# OPTIONS_GHC -Wno-redundant-constraints #-}

module Match (
  on,
  matche,
  _Value,
  on',
  matche',
  Exhausted,
  _Tagged,
  _Value',
  enter',
) where

import Control.Lens (Iso, Prism, Prism', from, iso, prism', review, reviewing)
import Core
import Data.Tagged (Tagged (Tagged, unTagged))
import Data.Void (Void)
import Goal

on
  :: (Logical a, Fresh v)
  => Prism' (Logic a) v
  -> (v -> Goal x)
  -> (Term a -> Goal x)
  -> Term a
  -> Goal x
on p f g x = disj (g x) $ do
  vars <- fresh
  x === Value (review p vars)
  f vars

matche :: Term a -> Goal x
matche = const failo

_Value :: Prism' (Term a) (Logic a)
_Value = prism' Value $ \case
  Value x -> Just x
  Var _ -> Nothing

type Matched m a = Tagged m (Term a)

class Exhausted a
instance Exhausted Void
instance (Exhausted a, Exhausted b) => Exhausted (a, b)

_Tagged :: Iso b b' (Tagged a b) (Tagged a' b')
_Tagged = iso Tagged unTagged

_Value'
  :: Prism
      (Tagged m (Term a))
      (Tagged m' (Term a))
      (Tagged m (Logic a))
      (Tagged m' (Logic a))
_Value' = from _Tagged . _Value . _Tagged

enter' :: (Matched m a -> Goal x) -> Term a -> Goal x
enter' f = f . Tagged

on'
  :: (Logical a, Fresh v)
  => Prism (Tagged m (Logic a)) (Tagged m' (Logic a)) (Tagged () v) (Tagged Void v)
  -> (v -> Goal x)
  -> (Matched m' a -> Goal x)
  -> Matched m a
  -> Goal x
on' p f g (Tagged x) = disj (g (Tagged x)) $ do
  vars <- fresh
  let Tagged value = review (reviewing p) (Tagged vars)
  x === Value value
  f vars

matche' :: (Exhausted m) => Matched m a -> Goal x
matche' = const failo
