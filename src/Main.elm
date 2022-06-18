module Main exposing (main)

import Browser
import Html exposing (..)


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags = ()
type alias Model = ()


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( (), Cmd.none )


type Msg
    = Msg1
    | Msg2


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg1 ->
            ( model, Cmd.none )

        Msg2 ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Browser.Document Msg
view _ =
    { title = "Hallo Welt!"
    , body =
        [ div []
            [ text "yxcv" ]
      ]
    }
