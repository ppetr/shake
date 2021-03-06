
module Test.Assume(main) where

import Development.Shake
import Test.Type
import Control.Monad
import Development.Shake.FilePath


main = shaken test $ \args obj -> do
    want $ map obj args
    obj "*.out" %> \out -> do
        cs <- mapM (readFile' . obj . (:".src")) $ takeBaseName out
        writeFile' out $ concat cs


test build obj = do
    let set file c = writeFile (obj $ file : ".src") [c]
    let ask file c = do src <- readFile (obj $ file ++ ".out"); src === c

    forM_ ['a'..'f'] $ \c -> set c c
    build ["--sleep","abc.out"]
    ask "abc" "abc"

    set 'b' 'd'
    build ["--sleep","abc.out"]
    ask "abc" "adc"
    set 'b' 'p'
    build ["--sleep","abc.out","--touch"]
    build ["abc.out"]
    ask "abc" "adc"
    set 'c' 'z'
    build ["--sleep","abc.out"]
    ask "abc" "apz"

    build ["bc.out","c.out"]
    ask "bc" "pz"
    set 'b' 'r'
    set 'c' 'n'
    build ["--sleep","abc.out","--touch"]
    ask "abc" "apz"
    build ["ab.out","--always-make"]
    ask "ab" "ar"
    build ["c.out"]
    ask "c" "z"
