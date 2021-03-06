module Lab6

where
import Data.List
import System.Random
import Week6
import Data.Bits
import Control.Monad

carmichael :: [Integer]
carmichael = [ (6*k+1)*(12*k+1)*(18*k+1) | 
      k <- [2..], 
      isPrime (6*k+1), 
      isPrime (12*k+1), 
      isPrime (18*k+1) ]

--maxBaseTwo m n -- 40 0
--	| (2^n) <= m = maxBaseTwo m (n+1) -- 2^0 < 40, 2^1 < 40, 2^3 < 40, 2^4 < 40, 2^5(32) < 40
--	| otherwise = 2^(n-1) -- 2^(6-1) = 32

{-
-- Exec. 1
-}

-- bit games. less cpu per operation (does not affect O complexity)
modExp :: Integer -> Integer -> Integer -> Integer
modExp b 0 m = 1
modExp b e m = t * modExp ((b * b) `mod` m) (shiftR e 1) m `mod` m -- shiftR by 1 == div by 2!
  		   where 
  		   	t = if testBit e 0 
  		   		then b `mod` m else 1 -- is first bit equal to 1? mod!.. nope? number is 0. return 1!

-- similar like above.. more clear... divide problem to smaller ones. log << smaller/shorter
-- x^n % m, time complexity O(log n)
-- x^n mod m == (x^(n/2) mod m * x^(n/2) mod m) mod m. calculating x^(n/2) is a lot more faster then x^n. 
-- and also when it's even need to calculate x^(n/2) once.
modPow :: Integer -> Integer -> Integer -> Integer
modPow x n m
	| n == 0 = 1
	| n `mod` 2 == 0 = (nEvn*nEvn) `mod` m
	| otherwise = nOdd
	where 
		nEvn = modPow x (n `div` 2) m 
		nOdd = ((x `mod` m) * (modPow x (n-1) m)) `mod` m

{-
-- Exec. 2
-- :set +s

==== test 1
> expM 5 40 7
> 2
> (0.00 secs, 0 bytes)

> modPow 5 40 7
> 2
> (0.00 secs, 0 bytes)
==== equal! let's try something bigger..
==== test 2
> expM 5 m7 7
5
(0.02 secs, 6256416 bytes)

> modPow 5 m7 7
5
(0.00 secs, 0 bytes)

==== equal! we can see a different. ! expM is slightly slower. let's make more test
==== test 3
> expM 5 m8 7
 ...... 
no response for up to 5 minutes

> modPow 5 m8 7
5
(0.00 secs, 0 bytes)
==== let's change some parameters
==== test 4
*Lab6> expM m7 m7 5
3
(0.16 secs, 23221896 bytes)

*Lab6> modPow m7 m7 5
3
(0.00 secs, 0 bytes)
=== expM <<<< slower then modPow
=== let's make really big parameters
*Lab6> expM m25 m25 m20
.........
no response for up to 5 minutes

*Lab6> modPow m25 m25 m20
156175455061768046603120243644560050924639300080982366389461706113173413177743642179598792425197734839169835127399410109
730305610045516070320065354538477044132435637780607092173082368114854675698870532203505450789800397527260177934030996931
144116195638499144514733770837792942077219334139004528074648102796990515306425568706762730257710772532893492734816033343
351049936056013844572368364881217752219851855889246562331367413344087229461735879996771876677020472009875961358103226898
819218745207078916048501138763192617819288553206949888993144522560197724572498763867660333521450489444929304121981452955
060543450779617604716787951149494717929581766925541282107973397131718830405137819817221253563180366922062978575425419554
702906080748229153450081324950964097319883768896913487879273174385164817937882883814755145799049990605925534711533048360
309653888688776309210463262875415382183812879111734198167610463633149121777666073308986150274092561799032695073933308614
989437507678505938584622328533738182360618967670482771207242775299517802112575338817287999702146903223386842868228233263
320318644000742883891307569598976874011216709875394285870108940042480645128469406006678819439793869795432901521343501549
569357708107877227421058945797217291277425268077324973628919362678641203349598091830870858481170726158424103291522139054
801240605653
(1.64 secs, 182903928 bytes)

-}

{-
-- Exec. 3
-}
composites :: [Integer]
composites = filter (\n -> isPrime n == False) [1..]

{-
-- Exec. 4
the least number found is 4
if k=1, it is easily find fool number
when increasing k [1..n] it takes more time to find a number, 
and usually the number that was found is bigger
-}

--minFool k = filterM (\n -> (primeF k n)) composites
minFool :: Int -> IO Integer
minFool k = minFool' k composites
minFool' :: Int -> [Integer] -> IO Integer
minFool' k (c:cs) = do 
					isFermatPrime <- (primeF k c)
					if isFermatPrime
					then return c
					else minFool' k cs


carmTest k = minFool' k carmichael

testPrimeFCarmichael :: (Int -> Integer -> IO Bool) -> Integer -> Int -> [Integer] -> Int -> IO () 
testPrimeFCarmichael f n k [] a 		= print ("Tests failed: " ++ show n ++ " out of " ++ show a)
testPrimeFCarmichael f n k (x:xs) a 	= do
    prime <- f k x
    if prime
    	then do 
    		print ("Falsely labelled prime: " ++ show x)
      		testPrimeFCarmichael f (n+1) k xs a
      else 
      	testPrimeFCarmichael f n k xs a
        
testCarmichael :: Int -> IO()
testCarmichael k = testPrimeFCarmichael primeF 0 k (take 100 carmichael) 100

-- exec. 6
testMillerRabin :: Int -> IO()
testMillerRabin k = testPrimeFCarmichael primeMR 0 k (take 100 carmichael) 100

-- Example tests
t9  = testMillerRabin 1      -- Failed 13 / 100
t10 = testMillerRabin 2      -- Failed 1 / 100
t11 = testMillerRabin 3      -- Failed 0 / 100

-- exec. 7
--primeMer :: (Ord a) => Int -> Int -> [a] -> IO()
getPrimer k = primeMer k 1
primeMer 0 _ = print ("number of tests is zero")
primeMer k n =
	do
		isPrimeMR <- primeMR k (2^n-1)
		if isPrimeMR
			then do
				print (show (2^n-1))
				primeMer k (n+1)
		else
			primeMer k (n+1)