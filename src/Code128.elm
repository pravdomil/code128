module Code128 exposing (Error(..), Width(..), encode)

{-| Sources:
<https://en.wikipedia.org/wiki/Code_128>
<https://hackage.haskell.org/package/barcodes-code128>
-}


{-| -}
type alias Symbol =
    { value : Int
    , bars : Bars
    , a : Function
    , b : Function
    , c : Function
    }


{-| -}
type Bars
    = Bars6 Width Width Width Width Width Width


{-| -}
type Width
    = Width1
    | Width2
    | Width3
    | Width4


{-| -}
type Function
    = -- StartX starts code set.
      StartA
    | StartB
    | StartC
      -- CodeX changes code set.
    | CodeA
    | CodeB
    | CodeC
      -- ShiftX changes code set for following symbol.
    | ShiftA
    | ShiftB
      -- FNCx is for special purposes.
    | FNC1
    | FNC2
    | FNC3
    | FNC4
      -- Basics
    | Char_ Char
    | Digits Int Int
    | Stop



--


{-| -}
type Error
    = OutOfCodeSet String



--


{-| -}
encode : String -> Result Error (List Width)
encode a =
    let
        chars : List Char
        chars =
            a |> String.toList
    in
    chars
        |> encodeA
        |> onError (\_ -> encodeB chars)
        |> onError (\_ -> encodeC chars)
        |> Result.map (\v -> v ++ [ checkSum v, stop ])
        |> Result.map (\v -> (v |> List.concatMap (\vv -> barsToWidths vv.bars)) ++ [ Width2 ])


{-| -}
checkSum : List Symbol -> Symbol
checkSum a =
    a
        |> List.indexedMap (\i v -> v.value * max 1 i)
        |> List.foldl (+) 0
        |> remainderBy 103
        |> (\v ->
                table
                    |> List.filter (\vv -> vv.value == v)
                    |> List.head
                    |> Maybe.withDefault stop
           )


{-| -}
barsToWidths : Bars -> List Width
barsToWidths (Bars6 a b c d e f) =
    [ a, b, c, d, e, f ]



--


{-| -}
encodeA : List Char -> Result Error (List Symbol)
encodeA a =
    a
        |> List.map symbolFromCharA
        |> sequence
        |> Result.map ((::) startA)


{-| -}
symbolFromCharA : Char -> Result Error Symbol
symbolFromCharA a =
    table
        |> List.filter (\v -> v.a == Char_ a)
        |> List.head
        |> Result.fromMaybe (OutOfCodeSet (String.fromChar a))



--


{-| -}
encodeB : List Char -> Result Error (List Symbol)
encodeB a =
    a
        |> List.map symbolFromCharB
        |> sequence
        |> Result.map ((::) startB)


{-| -}
symbolFromCharB : Char -> Result Error Symbol
symbolFromCharB a =
    table
        |> List.filter (\v -> v.b == Char_ a)
        |> List.head
        |> Result.fromMaybe (OutOfCodeSet (String.fromChar a))



--


{-| -}
encodeC : List Char -> Result Error (List Symbol)
encodeC a =
    a
        |> toTuples
        |> Result.fromMaybe (OutOfCodeSet "0")
        |> Result.andThen
            (\v ->
                v
                    |> List.map symbolFromCharC
                    |> sequence
                    |> Result.map ((::) startC)
            )


{-| -}
symbolFromCharC : ( Char, Char ) -> Result Error Symbol
symbolFromCharC ( a, b ) =
    let
        maybeFn : Maybe Function
        maybeFn =
            Maybe.map2 Digits
                (a |> String.fromChar |> String.toInt)
                (b |> String.fromChar |> String.toInt)

        error : Error
        error =
            OutOfCodeSet (String.fromList [ a, b ])
    in
    case maybeFn of
        Just fn ->
            table
                |> List.filter (\v -> v.c == fn)
                |> List.head
                |> Result.fromMaybe error

        Nothing ->
            Err error


{-| -}
toTuples : List Char -> Maybe (List ( Char, Char ))
toTuples a =
    case a of
        [] ->
            Just []

        b :: c :: rest ->
            rest |> toTuples |> Maybe.map (\v -> ( b, c ) :: v)

        _ ->
            Nothing



--


{-| -}
table : List Symbol
table =
    [ Symbol 0 (Bars6 Width2 Width1 Width2 Width2 Width2 Width2) (Char_ ' ') (Char_ ' ') (Digits 0 0)
    , Symbol 1 (Bars6 Width2 Width2 Width2 Width1 Width2 Width2) (Char_ '!') (Char_ '!') (Digits 0 1)
    , Symbol 2 (Bars6 Width2 Width2 Width2 Width2 Width2 Width1) (Char_ '"') (Char_ '"') (Digits 0 2)
    , Symbol 3 (Bars6 Width1 Width2 Width1 Width2 Width2 Width3) (Char_ '#') (Char_ '#') (Digits 0 3)
    , Symbol 4 (Bars6 Width1 Width2 Width1 Width3 Width2 Width2) (Char_ '$') (Char_ '$') (Digits 0 4)
    , Symbol 5 (Bars6 Width1 Width3 Width1 Width2 Width2 Width2) (Char_ '%') (Char_ '%') (Digits 0 5)
    , Symbol 6 (Bars6 Width1 Width2 Width2 Width2 Width1 Width3) (Char_ '&') (Char_ '&') (Digits 0 6)
    , Symbol 7 (Bars6 Width1 Width2 Width2 Width3 Width1 Width2) (Char_ '\'') (Char_ '\'') (Digits 0 7)
    , Symbol 8 (Bars6 Width1 Width3 Width2 Width2 Width1 Width2) (Char_ '(') (Char_ '(') (Digits 0 8)
    , Symbol 9 (Bars6 Width2 Width2 Width1 Width2 Width1 Width3) (Char_ ')') (Char_ ')') (Digits 0 9)
    , Symbol 10 (Bars6 Width2 Width2 Width1 Width3 Width1 Width2) (Char_ '*') (Char_ '*') (Digits 1 0)
    , Symbol 11 (Bars6 Width2 Width3 Width1 Width2 Width1 Width2) (Char_ '+') (Char_ '+') (Digits 1 1)
    , Symbol 12 (Bars6 Width1 Width1 Width2 Width2 Width3 Width2) (Char_ ',') (Char_ ',') (Digits 1 2)
    , Symbol 13 (Bars6 Width1 Width2 Width2 Width1 Width3 Width2) (Char_ '-') (Char_ '-') (Digits 1 3)
    , Symbol 14 (Bars6 Width1 Width2 Width2 Width2 Width3 Width1) (Char_ '.') (Char_ '.') (Digits 1 4)
    , Symbol 15 (Bars6 Width1 Width1 Width3 Width2 Width2 Width2) (Char_ '/') (Char_ '/') (Digits 1 5)
    , Symbol 16 (Bars6 Width1 Width2 Width3 Width1 Width2 Width2) (Char_ '0') (Char_ '0') (Digits 1 6)
    , Symbol 17 (Bars6 Width1 Width2 Width3 Width2 Width2 Width1) (Char_ '1') (Char_ '1') (Digits 1 7)
    , Symbol 18 (Bars6 Width2 Width2 Width3 Width2 Width1 Width1) (Char_ '2') (Char_ '2') (Digits 1 8)
    , Symbol 19 (Bars6 Width2 Width2 Width1 Width1 Width3 Width2) (Char_ '3') (Char_ '3') (Digits 1 9)
    , Symbol 20 (Bars6 Width2 Width2 Width1 Width2 Width3 Width1) (Char_ '4') (Char_ '4') (Digits 2 0)
    , Symbol 21 (Bars6 Width2 Width1 Width3 Width2 Width1 Width2) (Char_ '5') (Char_ '5') (Digits 2 1)
    , Symbol 22 (Bars6 Width2 Width2 Width3 Width1 Width1 Width2) (Char_ '6') (Char_ '6') (Digits 2 2)
    , Symbol 23 (Bars6 Width3 Width1 Width2 Width1 Width3 Width1) (Char_ '7') (Char_ '7') (Digits 2 3)
    , Symbol 24 (Bars6 Width3 Width1 Width1 Width2 Width2 Width2) (Char_ '8') (Char_ '8') (Digits 2 4)
    , Symbol 25 (Bars6 Width3 Width2 Width1 Width1 Width2 Width2) (Char_ '9') (Char_ '9') (Digits 2 5)
    , Symbol 26 (Bars6 Width3 Width2 Width1 Width2 Width2 Width1) (Char_ ':') (Char_ ':') (Digits 2 6)
    , Symbol 27 (Bars6 Width3 Width1 Width2 Width2 Width1 Width2) (Char_ ';') (Char_ ';') (Digits 2 7)
    , Symbol 28 (Bars6 Width3 Width2 Width2 Width1 Width1 Width2) (Char_ '<') (Char_ '<') (Digits 2 8)
    , Symbol 29 (Bars6 Width3 Width2 Width2 Width2 Width1 Width1) (Char_ '=') (Char_ '=') (Digits 2 9)
    , Symbol 30 (Bars6 Width2 Width1 Width2 Width1 Width2 Width3) (Char_ '>') (Char_ '>') (Digits 3 0)
    , Symbol 31 (Bars6 Width2 Width1 Width2 Width3 Width2 Width1) (Char_ '?') (Char_ '?') (Digits 3 1)
    , Symbol 32 (Bars6 Width2 Width3 Width2 Width1 Width2 Width1) (Char_ '@') (Char_ '@') (Digits 3 2)
    , Symbol 33 (Bars6 Width1 Width1 Width1 Width3 Width2 Width3) (Char_ 'A') (Char_ 'A') (Digits 3 3)
    , Symbol 34 (Bars6 Width1 Width3 Width1 Width1 Width2 Width3) (Char_ 'B') (Char_ 'B') (Digits 3 4)
    , Symbol 35 (Bars6 Width1 Width3 Width1 Width3 Width2 Width1) (Char_ 'C') (Char_ 'C') (Digits 3 5)
    , Symbol 36 (Bars6 Width1 Width1 Width2 Width3 Width1 Width3) (Char_ 'D') (Char_ 'D') (Digits 3 6)
    , Symbol 37 (Bars6 Width1 Width3 Width2 Width1 Width1 Width3) (Char_ 'E') (Char_ 'E') (Digits 3 7)
    , Symbol 38 (Bars6 Width1 Width3 Width2 Width3 Width1 Width1) (Char_ 'F') (Char_ 'F') (Digits 3 8)
    , Symbol 39 (Bars6 Width2 Width1 Width1 Width3 Width1 Width3) (Char_ 'G') (Char_ 'G') (Digits 3 9)
    , Symbol 40 (Bars6 Width2 Width3 Width1 Width1 Width1 Width3) (Char_ 'H') (Char_ 'H') (Digits 4 0)
    , Symbol 41 (Bars6 Width2 Width3 Width1 Width3 Width1 Width1) (Char_ 'I') (Char_ 'I') (Digits 4 1)
    , Symbol 42 (Bars6 Width1 Width1 Width2 Width1 Width3 Width3) (Char_ 'J') (Char_ 'J') (Digits 4 2)
    , Symbol 43 (Bars6 Width1 Width1 Width2 Width3 Width3 Width1) (Char_ 'K') (Char_ 'K') (Digits 4 3)
    , Symbol 44 (Bars6 Width1 Width3 Width2 Width1 Width3 Width1) (Char_ 'L') (Char_ 'L') (Digits 4 4)
    , Symbol 45 (Bars6 Width1 Width1 Width3 Width1 Width2 Width3) (Char_ 'M') (Char_ 'M') (Digits 4 5)
    , Symbol 46 (Bars6 Width1 Width1 Width3 Width3 Width2 Width1) (Char_ 'N') (Char_ 'N') (Digits 4 6)
    , Symbol 47 (Bars6 Width1 Width3 Width3 Width1 Width2 Width1) (Char_ 'O') (Char_ 'O') (Digits 4 7)
    , Symbol 48 (Bars6 Width3 Width1 Width3 Width1 Width2 Width1) (Char_ 'P') (Char_ 'P') (Digits 4 8)
    , Symbol 49 (Bars6 Width2 Width1 Width1 Width3 Width3 Width1) (Char_ 'Q') (Char_ 'Q') (Digits 4 9)
    , Symbol 50 (Bars6 Width2 Width3 Width1 Width1 Width3 Width1) (Char_ 'R') (Char_ 'R') (Digits 5 0)
    , Symbol 51 (Bars6 Width2 Width1 Width3 Width1 Width1 Width3) (Char_ 'S') (Char_ 'S') (Digits 5 1)
    , Symbol 52 (Bars6 Width2 Width1 Width3 Width3 Width1 Width1) (Char_ 'T') (Char_ 'T') (Digits 5 2)
    , Symbol 53 (Bars6 Width2 Width1 Width3 Width1 Width3 Width1) (Char_ 'U') (Char_ 'U') (Digits 5 3)
    , Symbol 54 (Bars6 Width3 Width1 Width1 Width1 Width2 Width3) (Char_ 'V') (Char_ 'V') (Digits 5 4)
    , Symbol 55 (Bars6 Width3 Width1 Width1 Width3 Width2 Width1) (Char_ 'W') (Char_ 'W') (Digits 5 5)
    , Symbol 56 (Bars6 Width3 Width3 Width1 Width1 Width2 Width1) (Char_ 'X') (Char_ 'X') (Digits 5 6)
    , Symbol 57 (Bars6 Width3 Width1 Width2 Width1 Width1 Width3) (Char_ 'Y') (Char_ 'Y') (Digits 5 7)
    , Symbol 58 (Bars6 Width3 Width1 Width2 Width3 Width1 Width1) (Char_ 'Z') (Char_ 'Z') (Digits 5 8)
    , Symbol 59 (Bars6 Width3 Width3 Width2 Width1 Width1 Width1) (Char_ '[') (Char_ '[') (Digits 5 9)
    , Symbol 60 (Bars6 Width3 Width1 Width4 Width1 Width1 Width1) (Char_ '\\') (Char_ '\\') (Digits 6 0)
    , Symbol 61 (Bars6 Width2 Width2 Width1 Width4 Width1 Width1) (Char_ ']') (Char_ ']') (Digits 6 1)
    , Symbol 62 (Bars6 Width4 Width3 Width1 Width1 Width1 Width1) (Char_ '^') (Char_ '^') (Digits 6 2)
    , Symbol 63 (Bars6 Width1 Width1 Width1 Width2 Width2 Width4) (Char_ '_') (Char_ '_') (Digits 6 3)
    , Symbol 64 (Bars6 Width1 Width1 Width1 Width4 Width2 Width2) (Char_ '\u{0000}') (Char_ '`') (Digits 6 4)
    , Symbol 65 (Bars6 Width1 Width2 Width1 Width1 Width2 Width4) (Char_ '\u{0001}') (Char_ 'a') (Digits 6 5)
    , Symbol 66 (Bars6 Width1 Width2 Width1 Width4 Width2 Width1) (Char_ '\u{0002}') (Char_ 'b') (Digits 6 6)
    , Symbol 67 (Bars6 Width1 Width4 Width1 Width1 Width2 Width2) (Char_ '\u{0003}') (Char_ 'c') (Digits 6 7)
    , Symbol 68 (Bars6 Width1 Width4 Width1 Width2 Width2 Width1) (Char_ '\u{0004}') (Char_ 'd') (Digits 6 8)
    , Symbol 69 (Bars6 Width1 Width1 Width2 Width2 Width1 Width4) (Char_ '\u{0005}') (Char_ 'e') (Digits 6 9)
    , Symbol 70 (Bars6 Width1 Width1 Width2 Width4 Width1 Width2) (Char_ '\u{0006}') (Char_ 'f') (Digits 7 0)
    , Symbol 71 (Bars6 Width1 Width2 Width2 Width1 Width1 Width4) (Char_ '\u{0007}') (Char_ 'g') (Digits 7 1)
    , Symbol 72 (Bars6 Width1 Width2 Width2 Width4 Width1 Width1) (Char_ '\u{0008}') (Char_ 'h') (Digits 7 2)
    , Symbol 73 (Bars6 Width1 Width4 Width2 Width1 Width1 Width2) (Char_ '\t') (Char_ 'i') (Digits 7 3)
    , Symbol 74 (Bars6 Width1 Width4 Width2 Width2 Width1 Width1) (Char_ '\n') (Char_ 'j') (Digits 7 4)
    , Symbol 75 (Bars6 Width2 Width4 Width1 Width2 Width1 Width1) (Char_ '\u{000B}') (Char_ 'k') (Digits 7 5)
    , Symbol 76 (Bars6 Width2 Width2 Width1 Width1 Width1 Width4) (Char_ '\u{000C}') (Char_ 'l') (Digits 7 6)
    , Symbol 77 (Bars6 Width4 Width1 Width3 Width1 Width1 Width1) (Char_ '\u{000D}') (Char_ 'm') (Digits 7 7)
    , Symbol 78 (Bars6 Width2 Width4 Width1 Width1 Width1 Width2) (Char_ '\u{000E}') (Char_ 'n') (Digits 7 8)
    , Symbol 79 (Bars6 Width1 Width3 Width4 Width1 Width1 Width1) (Char_ '\u{000F}') (Char_ 'o') (Digits 7 9)
    , Symbol 80 (Bars6 Width1 Width1 Width1 Width2 Width4 Width2) (Char_ '\u{0010}') (Char_ 'p') (Digits 8 0)
    , Symbol 81 (Bars6 Width1 Width2 Width1 Width1 Width4 Width2) (Char_ '\u{0011}') (Char_ 'q') (Digits 8 1)
    , Symbol 82 (Bars6 Width1 Width2 Width1 Width2 Width4 Width1) (Char_ '\u{0012}') (Char_ 'r') (Digits 8 2)
    , Symbol 83 (Bars6 Width1 Width1 Width4 Width2 Width1 Width2) (Char_ '\u{0013}') (Char_ 's') (Digits 8 3)
    , Symbol 84 (Bars6 Width1 Width2 Width4 Width1 Width1 Width2) (Char_ '\u{0014}') (Char_ 't') (Digits 8 4)
    , Symbol 85 (Bars6 Width1 Width2 Width4 Width2 Width1 Width1) (Char_ '\u{0015}') (Char_ 'u') (Digits 8 5)
    , Symbol 86 (Bars6 Width4 Width1 Width1 Width2 Width1 Width2) (Char_ '\u{0016}') (Char_ 'v') (Digits 8 6)
    , Symbol 87 (Bars6 Width4 Width2 Width1 Width1 Width1 Width2) (Char_ '\u{0017}') (Char_ 'w') (Digits 8 7)
    , Symbol 88 (Bars6 Width4 Width2 Width1 Width2 Width1 Width1) (Char_ '\u{0018}') (Char_ 'x') (Digits 8 8)
    , Symbol 89 (Bars6 Width2 Width1 Width2 Width1 Width4 Width1) (Char_ '\u{0019}') (Char_ 'y') (Digits 8 9)
    , Symbol 90 (Bars6 Width2 Width1 Width4 Width1 Width2 Width1) (Char_ '\u{001A}') (Char_ 'z') (Digits 9 0)
    , Symbol 91 (Bars6 Width4 Width1 Width2 Width1 Width2 Width1) (Char_ '\u{001B}') (Char_ '{') (Digits 9 1)
    , Symbol 92 (Bars6 Width1 Width1 Width1 Width1 Width4 Width3) (Char_ '\u{001C}') (Char_ '|') (Digits 9 2)
    , Symbol 93 (Bars6 Width1 Width1 Width1 Width3 Width4 Width1) (Char_ '\u{001D}') (Char_ '}') (Digits 9 3)
    , Symbol 94 (Bars6 Width1 Width3 Width1 Width1 Width4 Width1) (Char_ '\u{001E}') (Char_ '~') (Digits 9 4)
    , Symbol 95 (Bars6 Width1 Width1 Width4 Width1 Width1 Width3) (Char_ '\u{001F}') (Char_ '\u{007F}') (Digits 9 5)
    , Symbol 96 (Bars6 Width1 Width1 Width4 Width3 Width1 Width1) FNC3 FNC3 (Digits 9 6)
    , Symbol 97 (Bars6 Width4 Width1 Width1 Width1 Width1 Width3) FNC2 FNC2 (Digits 9 7)
    , Symbol 98 (Bars6 Width4 Width1 Width1 Width3 Width1 Width1) ShiftB ShiftA (Digits 9 8)
    , Symbol 99 (Bars6 Width1 Width1 Width3 Width1 Width4 Width1) CodeC CodeC (Digits 9 9)
    , Symbol 100 (Bars6 Width1 Width1 Width4 Width1 Width3 Width1) CodeB FNC4 CodeB
    , Symbol 101 (Bars6 Width3 Width1 Width1 Width1 Width4 Width1) FNC4 CodeA CodeA
    , Symbol 102 (Bars6 Width4 Width1 Width1 Width1 Width3 Width1) FNC1 FNC1 FNC1
    , startA
    , startB
    , startC
    , stop
    ]


{-| -}
startA : Symbol
startA =
    Symbol 103 (Bars6 Width2 Width1 Width1 Width4 Width1 Width2) StartA StartA StartA


{-| -}
startB : Symbol
startB =
    Symbol 104 (Bars6 Width2 Width1 Width1 Width2 Width1 Width4) StartB StartB StartB


{-| -}
startC : Symbol
startC =
    Symbol 105 (Bars6 Width2 Width1 Width1 Width2 Width3 Width2) StartC StartC StartC


{-| -}
stop : Symbol
stop =
    Symbol 106 (Bars6 Width2 Width3 Width3 Width1 Width1 Width1) Stop Stop Stop



--


{-| Recover from a failure in a result.
-}
onError : (err -> Result err2 a) -> Result err a -> Result err2 a
onError fn a =
    case a of
        Ok b ->
            Ok b

        Err b ->
            fn b


{-| -}
sequence : List (Result x a) -> Result x (List a)
sequence a =
    a |> List.foldr (Result.map2 (::)) (Ok [])
