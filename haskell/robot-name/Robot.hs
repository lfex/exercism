{-|
Module      : Robot
Copyright   : (c) Eric Bailey, 2015
License     : MIT

Maintainer  : Eric Bailey
Stability   : experimental
Portability : portable

Managing robot factory settings.
-}

module Robot (Robot, mkRobot, resetName, robotName) where

import           Control.Concurrent.STM
import           Control.Monad          (liftM)
import           System.Random          (randomRIO)

-- | A robot has a name that can be read ('robotName') and reset ('resetName').
data Robot = Robot { name :: TVar String }

-- | Creates a 'Robot' and gives it a random name.
mkRobot :: IO Robot
mkRobot = liftM Robot $ randomName >>= atomically . newTVar

-- | Given a 'Robot' @r@, generates a random name and atomically overwrites
-- @r@'s name.
resetName :: Robot -> IO ()
resetName = (randomName >>=) . resetName'
  where resetName' :: Robot -> String -> IO ()
        resetName' = atomically .: (writeTVar . name)

-- | Given a 'Robot', atomically reads and returns its name.
robotName :: Robot -> IO String
robotName = atomically . readTVar . name

-- | Generates a random robot name, such as RX837 or BC811.
randomName :: IO String
randomName = mapM randomRIO [a, a, d, d, d]
  where a = ('A', 'Z')
        d = ('0', '9')

-- | From "Data.Function.Pointless"
--
-- > (f .: g) x y = f (g x y)
--
-- or,
--
-- > f .: g = curry (f . uncurry g)
(.:) :: (c -> d) -> (a -> b -> c) -> a -> b -> d
(.:) = (.) . (.)
