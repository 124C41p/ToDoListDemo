module Main exposing (main)

import Api exposing (addEntry, fetchList, removeEntry)
import Browser
import Browser.Dom as Dom
import Html exposing (..)
import Html.Attributes exposing (class, id, type_)
import Html.Events exposing (onClick, onInput)
import Task
import Html.Attributes exposing (for)
import Html.Attributes exposing (placeholder)


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
    | NoOp


focus : String -> Cmd Msg
focus id =
    Task.attempt (\_ -> NoOp) (Dom.focus id)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ErrorOccurred ->
            ( Error, Cmd.none )

        ListReceived ls ->
            ( Idle ls "", focus "new-entry-textfield" )

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

        NoOp ->
            ( model, Cmd.none )


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
    [ div [ class "container mt-3" ]
        [ div [ class "card" ]
            [ div [ class "card-header" ] [ text "TODOs" ]
            , div [ class "card-body" ]
                [ viewTodoList ls
                , viewTextBox str
                ]
            ]
        ]
    ]


viewTextBox : String -> Html Msg
viewTextBox str =
    div [ class "input-group" ]
        [ input [ type_ "text", class "form-control", onInput TextChanged, id "new-entry-textfield", placeholder "Neuer Eintrag" ] [ text str ]
        , button [ class "btn btn-outline-secondary", onClick EntryAdditionRequested ] [ text "Hinzufügen" ]
        ]


viewTodoList : TodoList -> Html Msg
viewTodoList ls =
    Html.table [ class "table", class "table-striped" ]
        [ tbody []
            (List.map2
                (\entry index ->
                    tr []
                        [ td [] [ text <| String.fromInt index ]
                        , td [] [ text entry.text ]
                        , td []
                            [ button [ class "btn", onClick (EntryRemovalRequested entry.id) ] [ text "❌" ]
                            ]
                        ]
                )
                ls
                (List.range 1 (List.length ls))
            )
        ]
