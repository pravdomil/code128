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
    { value : Int
    , code : Code
    , codeA : Interpretation
    , codeB : Interpretation
    , codeC : Interpretation
    }


{-| -}
table : List Symbol
table =
    [ Symbol 0 (Code Two One Two Two Two Two) (Char_ ' ') (Char_ ' ') (Digits 0 0)
    , Symbol 1 (Code Two Two Two One Two Two) (Char_ '!') (Char_ '!') (Digits 0 1)
    , Symbol 2 (Code Two Two Two Two Two One) (Char_ '"') (Char_ '"') (Digits 0 2)
    , Symbol 3 (Code One Two One Two Two Three) (Char_ '#') (Char_ '#') (Digits 0 3)
    , Symbol 4 (Code One Two One Three Two Two) (Char_ '$') (Char_ '$') (Digits 0 4)
    , Symbol 5 (Code One Three One Two Two Two) (Char_ '%') (Char_ '%') (Digits 0 5)
    , Symbol 6 (Code One Two Two Two One Three) (Char_ '&') (Char_ '&') (Digits 0 6)
    , Symbol 7 (Code One Two Two Three One Two) (Char_ '\'') (Char_ '\'') (Digits 0 7)
    , Symbol 8 (Code One Three Two Two One Two) (Char_ '(') (Char_ '(') (Digits 0 8)
    , Symbol 9 (Code Two Two One Two One Three) (Char_ ')') (Char_ ')') (Digits 0 9)
    , Symbol 10 (Code Two Two One Three One Two) (Char_ '*') (Char_ '*') (Digits 1 0)
    , Symbol 11 (Code Two Three One Two One Two) (Char_ '+') (Char_ '+') (Digits 1 1)
    , Symbol 12 (Code One One Two Two Three Two) (Char_ ',') (Char_ ',') (Digits 1 2)
    , Symbol 13 (Code One Two Two One Three Two) (Char_ '-') (Char_ '-') (Digits 1 3)
    , Symbol 14 (Code One Two Two Two Three One) (Char_ '.') (Char_ '.') (Digits 1 4)
    , Symbol 15 (Code One One Three Two Two Two) (Char_ '/') (Char_ '/') (Digits 1 5)
    , Symbol 16 (Code One Two Three One Two Two) (Char_ '0') (Char_ '0') (Digits 1 6)
    , Symbol 17 (Code One Two Three Two Two One) (Char_ '1') (Char_ '1') (Digits 1 7)
    , Symbol 18 (Code Two Two Three Two One One) (Char_ '2') (Char_ '2') (Digits 1 8)
    , Symbol 19 (Code Two Two One One Three Two) (Char_ '3') (Char_ '3') (Digits 1 9)
    , Symbol 20 (Code Two Two One Two Three One) (Char_ '4') (Char_ '4') (Digits 2 0)
    , Symbol 21 (Code Two One Three Two One Two) (Char_ '5') (Char_ '5') (Digits 2 1)
    , Symbol 22 (Code Two Two Three One One Two) (Char_ '6') (Char_ '6') (Digits 2 2)
    , Symbol 23 (Code Three One Two One Three One) (Char_ '7') (Char_ '7') (Digits 2 3)
    , Symbol 24 (Code Three One One Two Two Two) (Char_ '8') (Char_ '8') (Digits 2 4)
    , Symbol 25 (Code Three Two One One Two Two) (Char_ '9') (Char_ '9') (Digits 2 5)
    , Symbol 26 (Code Three Two One Two Two One) (Char_ ':') (Char_ ':') (Digits 2 6)
    , Symbol 27 (Code Three One Two Two One Two) (Char_ ';') (Char_ ';') (Digits 2 7)
    , Symbol 28 (Code Three Two Two One One Two) (Char_ '<') (Char_ '<') (Digits 2 8)
    , Symbol 29 (Code Three Two Two Two One One) (Char_ '=') (Char_ '=') (Digits 2 9)
    , Symbol 30 (Code Two One Two One Two Three) (Char_ '>') (Char_ '>') (Digits 3 0)
    , Symbol 31 (Code Two One Two Three Two One) (Char_ '?') (Char_ '?') (Digits 3 1)
    , Symbol 32 (Code Two Three Two One Two One) (Char_ '@') (Char_ '@') (Digits 3 2)
    , Symbol 33 (Code One One One Three Two Three) (Char_ 'A') (Char_ 'A') (Digits 3 3)
    , Symbol 34 (Code One Three One One Two Three) (Char_ 'B') (Char_ 'B') (Digits 3 4)
    , Symbol 35 (Code One Three One Three Two One) (Char_ 'C') (Char_ 'C') (Digits 3 5)
    , Symbol 36 (Code One One Two Three One Three) (Char_ 'D') (Char_ 'D') (Digits 3 6)
    , Symbol 37 (Code One Three Two One One Three) (Char_ 'E') (Char_ 'E') (Digits 3 7)
    , Symbol 38 (Code One Three Two Three One One) (Char_ 'F') (Char_ 'F') (Digits 3 8)
    , Symbol 39 (Code Two One One Three One Three) (Char_ 'G') (Char_ 'G') (Digits 3 9)
    , Symbol 40 (Code Two Three One One One Three) (Char_ 'H') (Char_ 'H') (Digits 4 0)
    , Symbol 41 (Code Two Three One Three One One) (Char_ 'I') (Char_ 'I') (Digits 4 1)
    , Symbol 42 (Code One One Two One Three Three) (Char_ 'J') (Char_ 'J') (Digits 4 2)
    , Symbol 43 (Code One One Two Three Three One) (Char_ 'K') (Char_ 'K') (Digits 4 3)
    , Symbol 44 (Code One Three Two One Three One) (Char_ 'L') (Char_ 'L') (Digits 4 4)
    , Symbol 45 (Code One One Three One Two Three) (Char_ 'M') (Char_ 'M') (Digits 4 5)
    , Symbol 46 (Code One One Three Three Two One) (Char_ 'N') (Char_ 'N') (Digits 4 6)
    , Symbol 47 (Code One Three Three One Two One) (Char_ 'O') (Char_ 'O') (Digits 4 7)
    , Symbol 48 (Code Three One Three One Two One) (Char_ 'P') (Char_ 'P') (Digits 4 8)
    , Symbol 49 (Code Two One One Three Three One) (Char_ 'Q') (Char_ 'Q') (Digits 4 9)
    , Symbol 50 (Code Two Three One One Three One) (Char_ 'R') (Char_ 'R') (Digits 5 0)
    , Symbol 51 (Code Two One Three One One Three) (Char_ 'S') (Char_ 'S') (Digits 5 1)
    , Symbol 52 (Code Two One Three Three One One) (Char_ 'T') (Char_ 'T') (Digits 5 2)
    , Symbol 53 (Code Two One Three One Three One) (Char_ 'U') (Char_ 'U') (Digits 5 3)
    , Symbol 54 (Code Three One One One Two Three) (Char_ 'V') (Char_ 'V') (Digits 5 4)
    , Symbol 55 (Code Three One One Three Two One) (Char_ 'W') (Char_ 'W') (Digits 5 5)
    , Symbol 56 (Code Three Three One One Two One) (Char_ 'X') (Char_ 'X') (Digits 5 6)
    , Symbol 57 (Code Three One Two One One Three) (Char_ 'Y') (Char_ 'Y') (Digits 5 7)
    , Symbol 58 (Code Three One Two Three One One) (Char_ 'Z') (Char_ 'Z') (Digits 5 8)
    , Symbol 59 (Code Three Three Two One One One) (Char_ '[') (Char_ '[') (Digits 5 9)
    , Symbol 60 (Code Three One Four One One One) (Char_ '\\') (Char_ '\\') (Digits 6 0)
    , Symbol 61 (Code Two Two One Four One One) (Char_ ']') (Char_ ']') (Digits 6 1)
    , Symbol 62 (Code Four Three One One One One) (Char_ '^') (Char_ '^') (Digits 6 2)
    , Symbol 63 (Code One One One Two Two Four) (Char_ '_') (Char_ '_') (Digits 6 3)
    , Symbol 64 (Code One One One Four Two Two) (Char_ '\u{0000}') (Char_ '`') (Digits 6 4)
    , Symbol 65 (Code One Two One One Two Four) (Char_ '\u{0001}') (Char_ 'a') (Digits 6 5)
    , Symbol 66 (Code One Two One Four Two One) (Char_ '\u{0002}') (Char_ 'b') (Digits 6 6)
    , Symbol 67 (Code One Four One One Two Two) (Char_ '\u{0003}') (Char_ 'c') (Digits 6 7)
    , Symbol 68 (Code One Four One Two Two One) (Char_ '\u{0004}') (Char_ 'd') (Digits 6 8)
    , Symbol 69 (Code One One Two Two One Four) (Char_ '\u{0005}') (Char_ 'e') (Digits 6 9)
    , Symbol 70 (Code One One Two Four One Two) (Char_ '\u{0006}') (Char_ 'f') (Digits 7 0)
    , Symbol 71 (Code One Two Two One One Four) (Char_ '\u{0007}') (Char_ 'g') (Digits 7 1)
    , Symbol 72 (Code One Two Two Four One One) (Char_ '\u{0008}') (Char_ 'h') (Digits 7 2)
    , Symbol 73 (Code One Four Two One One Two) (Char_ '\t') (Char_ 'i') (Digits 7 3)
    , Symbol 74 (Code One Four Two Two One One) (Char_ '\n') (Char_ 'j') (Digits 7 4)
    , Symbol 75 (Code Two Four One Two One One) (Char_ '\u{000B}') (Char_ 'k') (Digits 7 5)
    , Symbol 76 (Code Two Two One One One Four) (Char_ '\u{000C}') (Char_ 'l') (Digits 7 6)
    , Symbol 77 (Code Four One Three One One One) (Char_ '\u{000D}') (Char_ 'm') (Digits 7 7)
    , Symbol 78 (Code Two Four One One One Two) (Char_ '\u{000E}') (Char_ 'n') (Digits 7 8)
    , Symbol 79 (Code One Three Four One One One) (Char_ '\u{000F}') (Char_ 'o') (Digits 7 9)
    , Symbol 80 (Code One One One Two Four Two) (Char_ '\u{0010}') (Char_ 'p') (Digits 8 0)
    , Symbol 81 (Code One Two One One Four Two) (Char_ '\u{0011}') (Char_ 'q') (Digits 8 1)
    , Symbol 82 (Code One Two One Two Four One) (Char_ '\u{0012}') (Char_ 'r') (Digits 8 2)
    , Symbol 83 (Code One One Four Two One Two) (Char_ '\u{0013}') (Char_ 's') (Digits 8 3)
    , Symbol 84 (Code One Two Four One One Two) (Char_ '\u{0014}') (Char_ 't') (Digits 8 4)
    , Symbol 85 (Code One Two Four Two One One) (Char_ '\u{0015}') (Char_ 'u') (Digits 8 5)
    , Symbol 86 (Code Four One One Two One Two) (Char_ '\u{0016}') (Char_ 'v') (Digits 8 6)
    , Symbol 87 (Code Four Two One One One Two) (Char_ '\u{0017}') (Char_ 'w') (Digits 8 7)
    , Symbol 88 (Code Four Two One Two One One) (Char_ '\u{0018}') (Char_ 'x') (Digits 8 8)
    , Symbol 89 (Code Two One Two One Four One) (Char_ '\u{0019}') (Char_ 'y') (Digits 8 9)
    , Symbol 90 (Code Two One Four One Two One) (Char_ '\u{001A}') (Char_ 'z') (Digits 9 0)
    , Symbol 91 (Code Four One Two One Two One) (Char_ '\u{001B}') (Char_ '{') (Digits 9 1)
    , Symbol 92 (Code One One One One Four Three) (Char_ '\u{001C}') (Char_ '|') (Digits 9 2)
    , Symbol 93 (Code One One One Three Four One) (Char_ '\u{001D}') (Char_ '}') (Digits 9 3)
    , Symbol 94 (Code One Three One One Four One) (Char_ '\u{001E}') (Char_ '~') (Digits 9 4)
    , Symbol 95 (Code One One Four One One Three) (Char_ '\u{001F}') (Char_ '\u{007F}') (Digits 9 5)
    , Symbol 96 (Code One One Four Three One One) FNC3 FNC3 (Digits 9 6)
    , Symbol 97 (Code Four One One One One Three) FNC2 FNC2 (Digits 9 7)
    , Symbol 98 (Code Four One One Three One One) ShiftB ShiftA (Digits 9 8)
    , Symbol 99 (Code One One Three One Four One) CodeC CodeC (Digits 9 9)
    , Symbol 100 (Code One One Four One Three One) CodeB FNC4 CodeB
    , Symbol 101 (Code Three One One One Four One) FNC4 CodeA CodeA
    , Symbol 102 (Code Four One One One Three One) FNC1 FNC1 FNC1
    , Symbol 103 (Code Two One One Four One Two) StartA StartA StartA
    , Symbol 104 (Code Two One One Two One Four) StartB StartB StartB
    , Symbol 105 (Code Two One One Two Three Two) StartC StartC StartC
    ]
