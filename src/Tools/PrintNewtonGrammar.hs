{-# OPTIONS -fno-warn-incomplete-patterns #-}
module Tools.PrintNewtonGrammar where

-- pretty-printer generated by the BNF converter

import Tools.AbsNewtonGrammar
import Char

-- the top-level printing method
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : "," :ts -> showString t . space "," . rend i ts
    t  : ")" :ts -> showString t . showChar ')' . rend i ts
    t  : "]" :ts -> showString t . showChar ']' . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else (' ':s))

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- the printer class does the job
class Print a where
  prt :: Int -> a -> Doc
  prtList :: [a] -> Doc
  prtList = concatD . map (prt 0)

instance Print a => Print [a] where
  prt _ = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j<i then parenth else id


instance Print Integer where
  prt _ x = doc (shows x)


instance Print Double where
  prt _ x = doc (shows x)




instance Print YP where
  prt i e = case e of
   YPMulti yp0 yp -> prPrec i 0 (concatD [prt 0 yp0 , prt 1 yp])
   YPSing term -> prPrec i 1 (concatD [prt 0 term])


instance Print Term where
  prt i e = case e of
   TermNonConst scoeff mon -> prPrec i 0 (concatD [prt 0 scoeff , prt 0 mon])
   TermConst scoeff -> prPrec i 0 (concatD [prt 0 scoeff])


instance Print Mon where
  prt i e = case e of
   MonomX xmon -> prPrec i 0 (concatD [prt 0 xmon])
   MonomY ymon -> prPrec i 0 (concatD [prt 0 ymon])
   MonomXY xmon ymon -> prPrec i 0 (concatD [prt 0 xmon , prt 0 ymon])


instance Print XMon where
  prt i e = case e of
   XMonom n -> prPrec i 0 (concatD [doc (showString "X^") , prt 0 n])


instance Print YMon where
  prt i e = case e of
   YMonom n -> prPrec i 0 (concatD [doc (showString "Y^") , prt 0 n])


instance Print SCoeff where
  prt i e = case e of
   SCoeffP coeff -> prPrec i 0 (concatD [doc (showString "+") , prt 0 coeff])
   SCoeffM coeff -> prPrec i 0 (concatD [doc (showString "-") , prt 0 coeff])


instance Print Coeff where
  prt i e = case e of
   CoeffR coeff0 coeff -> prPrec i 0 (concatD [prt 1 coeff0 , doc (showString "/") , prt 1 coeff])
   CoeffI n -> prPrec i 1 (concatD [prt 0 n])



