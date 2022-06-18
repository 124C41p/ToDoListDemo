module Main exposing (main)

import Api exposing (addEntry, fetchList, removeEntry)
import Browser
import Html exposing (..)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick, onInput)


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags =
    ()


type alias TodoEntry =
    { id : Int
    , text : String
    }


type alias TodoList =
    List TodoEntry


processTodoList : List ( Int, String ) -> Msg
processTodoList =
    List.map (\( id, txt ) -> TodoEntry id txt) >> ListReceived


type Model
    = Error
    | Loading
    | Idle TodoList String


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , fetchList
        ErrorOccurred
        processTodoList
    )


type Msg
    = ErrorOccurred
    | ListReceived TodoList
    | EntryAdditionRequested
    | EntryRemovalRequested Int
    | NewListRequested
    | TextChanged String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ErrorOccurred ->
            ( Error, Cmd.none )

        ListReceived ls ->
            ( Idle ls "", Cmd.none )

        EntryAdditionRequested ->
            case model of
                Idle _ str ->
                    ( Loading, addEntry str ErrorOccurred NewListRequested )

                _ ->
                    ( Error, Cmd.none )

        EntryRemovalRequested id ->
            ( Loading, removeEntry id ErrorOccurred NewListRequested )

        NewListRequested ->
            ( Loading, fetchList ErrorOccurred processTodoList )

        TextChanged str ->
            case model of
                Idle ls _ ->
                    ( Idle ls str, Cmd.none )

                _ ->
                    ( Error, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "Todo Liste"
    , body =
        case model of
            Error ->
                viewError

            Loading ->
                viewLoading

            Idle ls str ->
                viewIdle ls str
    }


viewError : List (Html Msg)
viewError =
    [ text "Ups, da ging was schief!" ]


viewLoading : List (Html Msg)
viewLoading =
    [ div [ class "spinner-border" ] [] ]


viewIdle : TodoList -> String -> List (Html Msg)
viewIdle ls str =
    viewList ls ++ viewTextBox str


viewTextBox : String -> List (Html Msg)
viewTextBox str =
    [ input [ type_ "text", onInput TextChanged ] [ text str ]
    , button [ onClick EntryAdditionRequested ] [ text "Hinzufügen" ]
    ]


viewList : TodoList -> List (Html Msg)
viewList ls =
    [ ul []
        (List.map
            (\entry ->
                li []
                    [ text entry.text
                    , button [ onClick (EntryRemovalRequested entry.id) ] [ text "Entfernen" ]
                    ]
            )
            ls
        )
    ]
