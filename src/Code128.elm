module Code128 exposing (..)

{-| -}


{-| -}
type Error
    = EncodeError Char


{-| -}
type Width
    = One
    | Two
    | Three
    | Four


{-| -}
type Code
    = Code Width Width Width Width Width Width
    | StopCode


{-| -}
type Interpretation
    = Char_ Char
    | FNC1
    | FNC2
    | FNC3
    | FNC4
    | CodeA
    | CodeB
    | CodeC
    | ShiftA
    | ShiftB
    | Digits Int Int
    | Stop
    | StartA
    | StartB
    | StartC


{-| -}
type alias Symbol =
    { code : Code
    , value : Int
    , codeA : Interpretation
    , codeB : Interpretation
    , codeC : Interpretation
    }


{-| -}
table : List Symbol
table =
    [ Symbol (Code Two One Two Two Two Two) 0 (Char_ ' ') (Char_ ' ') (Digits 0 0)
    , Symbol (Code Two Two Two One Two Two) 1 (Char_ '!') (Char_ '!') (Digits 0 1)
    , Symbol (Code Two Two Two Two Two One) 2 (Char_ '"') (Char_ '"') (Digits 0 2)
    , Symbol (Code One Two One Two Two Three) 3 (Char_ '#') (Char_ '#') (Digits 0 3)
    , Symbol (Code One Two One Three Two Two) 4 (Char_ '$') (Char_ '$') (Digits 0 4)
    , Symbol (Code One Three One Two Two Two) 5 (Char_ '%') (Char_ '%') (Digits 0 5)
    , Symbol (Code One Two Two Two One Three) 6 (Char_ '&') (Char_ '&') (Digits 0 6)
    , Symbol (Code One Two Two Three One Two) 7 (Char_ '\'') (Char_ '\'') (Digits 0 7)
    , Symbol (Code One Three Two Two One Two) 8 (Char_ '(') (Char_ '(') (Digits 0 8)
    , Symbol (Code Two Two One Two One Three) 9 (Char_ ')') (Char_ ')') (Digits 0 9)
    , Symbol (Code Two Two One Three One Two) 10 (Char_ '*') (Char_ '*') (Digits 1 0)
    , Symbol (Code Two Three One Two One Two) 11 (Char_ '+') (Char_ '+') (Digits 1 1)
    , Symbol (Code One One Two Two Three Two) 12 (Char_ ',') (Char_ ',') (Digits 1 2)
    , Symbol (Code One Two Two One Three Two) 13 (Char_ '-') (Char_ '-') (Digits 1 3)
    , Symbol (Code One Two Two Two Three One) 14 (Char_ '.') (Char_ '.') (Digits 1 4)
    , Symbol (Code One One Three Two Two Two) 15 (Char_ '/') (Char_ '/') (Digits 1 5)
    , Symbol (Code One Two Three One Two Two) 16 (Char_ '0') (Char_ '0') (Digits 1 6)
    , Symbol (Code One Two Three Two Two One) 17 (Char_ '1') (Char_ '1') (Digits 1 7)
    , Symbol (Code Two Two Three Two One One) 18 (Char_ '2') (Char_ '2') (Digits 1 8)
    , Symbol (Code Two Two One One Three Two) 19 (Char_ '3') (Char_ '3') (Digits 1 9)
    , Symbol (Code Two Two One Two Three One) 20 (Char_ '4') (Char_ '4') (Digits 2 0)
    , Symbol (Code Two One Three Two One Two) 21 (Char_ '5') (Char_ '5') (Digits 2 1)
    , Symbol (Code Two Two Three One One Two) 22 (Char_ '6') (Char_ '6') (Digits 2 2)
    , Symbol (Code Three One Two One Three One) 23 (Char_ '7') (Char_ '7') (Digits 2 3)
    , Symbol (Code Three One One Two Two Two) 24 (Char_ '8') (Char_ '8') (Digits 2 4)
    , Symbol (Code Three Two One One Two Two) 25 (Char_ '9') (Char_ '9') (Digits 2 5)
    , Symbol (Code Three Two One Two Two One) 26 (Char_ ':') (Char_ ':') (Digits 2 6)
    , Symbol (Code Three One Two Two One Two) 27 (Char_ ';') (Char_ ';') (Digits 2 7)
    , Symbol (Code Three Two Two One One Two) 28 (Char_ '<') (Char_ '<') (Digits 2 8)
    , Symbol (Code Three Two Two Two One One) 29 (Char_ '=') (Char_ '=') (Digits 2 9)
    , Symbol (Code Two One Two One Two Three) 30 (Char_ '>') (Char_ '>') (Digits 3 0)
    , Symbol (Code Two One Two Three Two One) 31 (Char_ '?') (Char_ '?') (Digits 3 1)
    , Symbol (Code Two Three Two One Two One) 32 (Char_ '@') (Char_ '@') (Digits 3 2)
    , Symbol (Code One One One Three Two Three) 33 (Char_ 'A') (Char_ 'A') (Digits 3 3)
    , Symbol (Code One Three One One Two Three) 34 (Char_ 'B') (Char_ 'B') (Digits 3 4)
    , Symbol (Code One Three One Three Two One) 35 (Char_ 'C') (Char_ 'C') (Digits 3 5)
    , Symbol (Code One One Two Three One Three) 36 (Char_ 'D') (Char_ 'D') (Digits 3 6)
    , Symbol (Code One Three Two One One Three) 37 (Char_ 'E') (Char_ 'E') (Digits 3 7)
    , Symbol (Code One Three Two Three One One) 38 (Char_ 'F') (Char_ 'F') (Digits 3 8)
    , Symbol (Code Two One One Three One Three) 39 (Char_ 'G') (Char_ 'G') (Digits 3 9)
    , Symbol (Code Two Three One One One Three) 40 (Char_ 'H') (Char_ 'H') (Digits 4 0)
    , Symbol (Code Two Three One Three One One) 41 (Char_ 'I') (Char_ 'I') (Digits 4 1)
    , Symbol (Code One One Two One Three Three) 42 (Char_ 'J') (Char_ 'J') (Digits 4 2)
    , Symbol (Code One One Two Three Three One) 43 (Char_ 'K') (Char_ 'K') (Digits 4 3)
    , Symbol (Code One Three Two One Three One) 44 (Char_ 'L') (Char_ 'L') (Digits 4 4)
    , Symbol (Code One One Three One Two Three) 45 (Char_ 'M') (Char_ 'M') (Digits 4 5)
    , Symbol (Code One One Three Three Two One) 46 (Char_ 'N') (Char_ 'N') (Digits 4 6)
    , Symbol (Code One Three Three One Two One) 47 (Char_ 'O') (Char_ 'O') (Digits 4 7)
    , Symbol (Code Three One Three One Two One) 48 (Char_ 'P') (Char_ 'P') (Digits 4 8)
    , Symbol (Code Two One One Three Three One) 49 (Char_ 'Q') (Char_ 'Q') (Digits 4 9)
    , Symbol (Code Two Three One One Three One) 50 (Char_ 'R') (Char_ 'R') (Digits 5 0)
    , Symbol (Code Two One Three One One Three) 51 (Char_ 'S') (Char_ 'S') (Digits 5 1)
    , Symbol (Code Two One Three Three One One) 52 (Char_ 'T') (Char_ 'T') (Digits 5 2)
    , Symbol (Code Two One Three One Three One) 53 (Char_ 'U') (Char_ 'U') (Digits 5 3)
    , Symbol (Code Three One One One Two Three) 54 (Char_ 'V') (Char_ 'V') (Digits 5 4)
    , Symbol (Code Three One One Three Two One) 55 (Char_ 'W') (Char_ 'W') (Digits 5 5)
    , Symbol (Code Three Three One One Two One) 56 (Char_ 'X') (Char_ 'X') (Digits 5 6)
    , Symbol (Code Three One Two One One Three) 57 (Char_ 'Y') (Char_ 'Y') (Digits 5 7)
    , Symbol (Code Three One Two Three One One) 58 (Char_ 'Z') (Char_ 'Z') (Digits 5 8)
    , Symbol (Code Three Three Two One One One) 59 (Char_ '[') (Char_ '[') (Digits 5 9)
    , Symbol (Code Three One Four One One One) 60 (Char_ '\\') (Char_ '\\') (Digits 6 0)
    , Symbol (Code Two Two One Four One One) 61 (Char_ ']') (Char_ ']') (Digits 6 1)
    , Symbol (Code Four Three One One One One) 62 (Char_ '^') (Char_ '^') (Digits 6 2)
    , Symbol (Code One One One Two Two Four) 63 (Char_ '_') (Char_ '_') (Digits 6 3)
    , Symbol (Code One One One Four Two Two) 64 (Char_ '\u{0000}') (Char_ '`') (Digits 6 4)
    , Symbol (Code One Two One One Two Four) 65 (Char_ '\u{0001}') (Char_ 'a') (Digits 6 5)
    , Symbol (Code One Two One Four Two One) 66 (Char_ '\u{0002}') (Char_ 'b') (Digits 6 6)
    , Symbol (Code One Four One One Two Two) 67 (Char_ '\u{0003}') (Char_ 'c') (Digits 6 7)
    , Symbol (Code One Four One Two Two One) 68 (Char_ '\u{0004}') (Char_ 'd') (Digits 6 8)
    , Symbol (Code One One Two Two One Four) 69 (Char_ '\u{0005}') (Char_ 'e') (Digits 6 9)
    , Symbol (Code One One Two Four One Two) 70 (Char_ '\u{0006}') (Char_ 'f') (Digits 7 0)
    , Symbol (Code One Two Two One One Four) 71 (Char_ '\u{0007}') (Char_ 'g') (Digits 7 1)
    , Symbol (Code One Two Two Four One One) 72 (Char_ '\u{0008}') (Char_ 'h') (Digits 7 2)
    , Symbol (Code One Four Two One One Two) 73 (Char_ '\t') (Char_ 'i') (Digits 7 3)
    , Symbol (Code One Four Two Two One One) 74 (Char_ '\n') (Char_ 'j') (Digits 7 4)
    , Symbol (Code Two Four One Two One One) 75 (Char_ '\u{000B}') (Char_ 'k') (Digits 7 5)
    , Symbol (Code Two Two One One One Four) 76 (Char_ '\u{000C}') (Char_ 'l') (Digits 7 6)
    , Symbol (Code Four One Three One One One) 77 (Char_ '\u{000D}') (Char_ 'm') (Digits 7 7)
    , Symbol (Code Two Four One One One Two) 78 (Char_ '\u{000E}') (Char_ 'n') (Digits 7 8)
    , Symbol (Code One Three Four One One One) 79 (Char_ '\u{000F}') (Char_ 'o') (Digits 7 9)
    , Symbol (Code One One One Two Four Two) 80 (Char_ '\u{0010}') (Char_ 'p') (Digits 8 0)
    , Symbol (Code One Two One One Four Two) 81 (Char_ '\u{0011}') (Char_ 'q') (Digits 8 1)
    , Symbol (Code One Two One Two Four One) 82 (Char_ '\u{0012}') (Char_ 'r') (Digits 8 2)
    , Symbol (Code One One Four Two One Two) 83 (Char_ '\u{0013}') (Char_ 's') (Digits 8 3)
    , Symbol (Code One Two Four One One Two) 84 (Char_ '\u{0014}') (Char_ 't') (Digits 8 4)
    , Symbol (Code One Two Four Two One One) 85 (Char_ '\u{0015}') (Char_ 'u') (Digits 8 5)
    , Symbol (Code Four One One Two One Two) 86 (Char_ '\u{0016}') (Char_ 'v') (Digits 8 6)
    , Symbol (Code Four Two One One One Two) 87 (Char_ '\u{0017}') (Char_ 'w') (Digits 8 7)
    , Symbol (Code Four Two One Two One One) 88 (Char_ '\u{0018}') (Char_ 'x') (Digits 8 8)
    , Symbol (Code Two One Two One Four One) 89 (Char_ '\u{0019}') (Char_ 'y') (Digits 8 9)
    , Symbol (Code Two One Four One Two One) 90 (Char_ '\u{001A}') (Char_ 'z') (Digits 9 0)
    , Symbol (Code Four One Two One Two One) 91 (Char_ '\u{001B}') (Char_ '{') (Digits 9 1)
    , Symbol (Code One One One One Four Three) 92 (Char_ '\u{001C}') (Char_ '|') (Digits 9 2)
    , Symbol (Code One One One Three Four One) 93 (Char_ '\u{001D}') (Char_ '}') (Digits 9 3)
    , Symbol (Code One Three One One Four One) 94 (Char_ '\u{001E}') (Char_ '~') (Digits 9 4)
    , Symbol (Code One One Four One One Three) 95 (Char_ '\u{001F}') (Char_ '\u{007F}') (Digits 9 5)
    , Symbol (Code One One Four Three One One) 96 FNC3 FNC3 (Digits 9 6)
    , Symbol (Code Four One One One One Three) 97 FNC2 FNC2 (Digits 9 7)
    , Symbol (Code Four One One Three One One) 98 ShiftB ShiftA (Digits 9 8)
    , Symbol (Code One One Three One Four One) 99 CodeC CodeC (Digits 9 9)
    , Symbol (Code One One Four One Three One) 100 CodeB FNC4 CodeB
    , Symbol (Code Three One One One Four One) 101 FNC4 CodeA CodeA
    , Symbol (Code Four One One One Three One) 102 FNC1 FNC1 FNC1
    , Symbol (Code Two One One Four One Two) 103 StartA StartA StartA
    , Symbol (Code Two One One Two One Four) 104 StartB StartB StartB
    , Symbol (Code Two One One Two Three Two) 105 StartC StartC StartC
    ]
