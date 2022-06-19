module Main exposing (main)

import Api exposing (addEntry, fetchList, removeEntry)
import Browser
import Browser.Dom as Dom
import Html exposing (..)
import Html.Attributes as Attribute exposing (class, for, height, id, placeholder, style, type_)
import Html.Events exposing (onClick, onInput)
import Task


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


type alias Model =
    { artificialLag : Int
    , formData : FormData
    }


type FormData
    = Loading
    | Data LoadedData


type alias LoadedData =
    { todoList : TodoList
    , newEntry : String
    }


processTodoList : List ( Int, String ) -> Msg
processTodoList =
    List.map (\( id, txt ) -> TodoEntry id txt) >> ListReceived


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( Model 0 Loading
    , fetchList
        0
        ErrorOccurred
        processTodoList
    )


type Msg
    = ErrorOccurred
    | ListReceived TodoList
    | EntryAdditionRequested String
    | EntryRemovalRequested Int
    | NewListRequested
    | TextChanged String
    | LagUpdated Int
    | NoOp


focus : String -> Cmd Msg
focus id =
    Task.attempt (\_ -> NoOp) (Dom.focus id)


updateNewEntry : String -> FormData -> FormData
updateNewEntry str formData =
    case formData of
        Loading ->
            Loading

        Data data ->
            Data { data | newEntry = str }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ErrorOccurred ->
            ( model, fetchList model.artificialLag ErrorOccurred processTodoList )

        ListReceived ls ->
            ( { model | formData = Data <| LoadedData ls "" }, focus "new-entry-textfield" )

        EntryAdditionRequested str ->
            ( { model | formData = Loading }, addEntry str model.artificialLag ErrorOccurred NewListRequested )

        EntryRemovalRequested id ->
            ( { model | formData = Loading }, removeEntry id model.artificialLag ErrorOccurred NewListRequested )

        NewListRequested ->
            ( { model | formData = Loading }, fetchList model.artificialLag ErrorOccurred processTodoList )

        TextChanged str ->
            ( { model | formData = updateNewEntry str model.formData }, Cmd.none )

        LagUpdated lag ->
            ( { model | artificialLag = lag }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "Todo Liste"
    , body = viewFormData model
    }


viewFormData : Model -> List (Html Msg)
viewFormData model =
    [ div [ class "container mt-3" ]
        [ div [ class "card" ]
            [ div [ class "card-header" ] [ h1 [ class "text-center" ] [ text "TODOs" ] ]
            , div [ class "card-body" ]
                (case model.formData of
                    Data data ->
                        [ div [ class "overflow-auto", style "height" "600px" ] [ viewTodoList data.todoList ]
                        , viewTextBox data.newEntry
                        , viewSlider model.artificialLag
                        ]

                    Loading ->
                        [ div [ class "d-flex justify-content-center" ]
                            [ div [ class "spinner-border" ] [] ]
                        ]
                )
            ]
        ]
    ]


viewTextBox : String -> Html Msg
viewTextBox str =
    div [ class "input-group" ]
        [ input [ type_ "text", class "form-control", onInput TextChanged, id "new-entry-textfield", placeholder "Neuer Eintrag" ] [ text str ]
        , button [ class "btn btn-outline-secondary", onClick (EntryAdditionRequested str) ] [ text "Hinzufügen" ]
        ]


viewSlider : Int -> Html Msg
viewSlider lag =
    div []
        [ label [ for "lagSlider", class "form-label" ] [ text "Künstlicher Server-Lag" ]
        , input
            [ type_ "range"
            , id "lagSlider"
            , class "form-range"
            , Attribute.min "0"
            , Attribute.max "1000"
            , Attribute.step "100"
            , Attribute.value (String.fromInt lag)
            , onInput (String.toInt >> Maybe.withDefault 0 >> LagUpdated)
            ]
            []
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
