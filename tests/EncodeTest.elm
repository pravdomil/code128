module EncodeTest exposing (..)

import Code128 exposing (..)
import Expect exposing (Expectation)
import Samples exposing (samples)
import Test exposing (..)


{-| -}
suite : Test
suite =
    describe "Code128"
        [ describe "encode"
            tests
        ]


{-| -}
tests : List Test
tests =
    samples
        |> List.indexedMap
            (\i ( a, b ) ->
                test ("sample " ++ String.fromInt i ++ " \"" ++ a ++ "\"") <|
                    \_ ->
                        Code128.encode a
                            |> Result.toMaybe
                            |> Expect.equal b
            )
