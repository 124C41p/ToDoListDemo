module Api exposing (addEntry, fetchList, removeEntry)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


todoListDecoder : Decoder (List ( Int, String ))
todoListDecoder =
    Decode.list <|
        Decode.map2
            (\id txt -> ( id, txt ))
            (Decode.field "id" Decode.int)
            (Decode.field "text" Decode.string)


idEncoder : Int -> Int -> Encode.Value
idEncoder id lag =
    Encode.object
        [ ( "id", Encode.int id )
        , ( "lag", Encode.int lag )
        ]


textEncoder : String -> Int -> Encode.Value
textEncoder str lag =
    Encode.object
        [ ( "text", Encode.string str )
        , ( "lag", Encode.int lag )
        ]


todolistEncoder : Int -> Encode.Value
todolistEncoder lag =
    Encode.object
        [ ( "lag", Encode.int lag )
        ]


fetchList : Int -> msg -> (List ( Int, String ) -> msg) -> Cmd msg
fetchList lag errorMsg processor =
    Http.post
        { url = "/api/list"
        , body = Http.jsonBody (todolistEncoder lag)
        , expect =
            Http.expectJson
                (Result.map processor >> Result.withDefault errorMsg)
                todoListDecoder
        }


removeEntry : Int -> Int -> msg -> msg -> Cmd msg
removeEntry id lag errorMsg doneMsg =
    Http.post
        { url = "/api/remove"
        , body = Http.jsonBody (idEncoder id lag)
        , expect =
            Http.expectWhatever
                (Result.map (always doneMsg) >> Result.withDefault errorMsg)
        }


addEntry : String -> Int -> msg -> msg -> Cmd msg
addEntry str lag errorMsg doneMsg =
    Http.post
        { url = "/api/add"
        , body = Http.jsonBody (textEncoder str lag)
        , expect =
            Http.expectWhatever
                (Result.map (always doneMsg) >> Result.withDefault errorMsg)
        }
