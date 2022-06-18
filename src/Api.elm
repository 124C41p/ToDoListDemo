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


idEncoder : Int -> Encode.Value
idEncoder id =
    Encode.object [ ( "id", Encode.int id ) ]


textEncoder : String -> Encode.Value
textEncoder str =
    Encode.object [ ( "text", Encode.string str ) ]


fetchList : msg -> (List ( Int, String ) -> msg) -> Cmd msg
fetchList errorMsg processor =
    Http.post
        { url = "/api/list"
        , body = Http.emptyBody
        , expect =
            Http.expectJson
                (Result.map processor >> Result.withDefault errorMsg)
                todoListDecoder
        }


removeEntry : Int -> msg -> msg -> Cmd msg
removeEntry id errorMsg doneMsg =
    Http.post
        { url = "/api/remove"
        , body = Http.jsonBody (idEncoder id)
        , expect =
            Http.expectWhatever
                (Result.map (always doneMsg) >> Result.withDefault errorMsg)
        }


addEntry : String -> msg -> msg -> Cmd msg
addEntry str errorMsg doneMsg =
    Http.post
        { url = "/api/add"
        , body = Http.jsonBody (textEncoder str)
        , expect =
            Http.expectWhatever
                (Result.map (always doneMsg) >> Result.withDefault errorMsg)
        }
