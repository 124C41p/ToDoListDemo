module Main exposing (main)

import Api exposing (addEntry, fetchList, removeEntry)
import Browser
import Browser.Dom as Dom
import Html exposing (..)
import Html.Attributes as Attribute exposing (class, disabled, for, id, placeholder, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
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
    | Available ActualFormData


type alias ActualFormData =
    { todoList : TodoList
    , newEntry : String
    }


processTodoListRawData : List ( Int, String ) -> Msg
processTodoListRawData =
    List.map (\( id, txt ) -> TodoEntry id txt) >> ListReceived


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( Model 0 Loading
    , fetchList
        0
        ErrorOccurred
        processTodoListRawData
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

        Available data ->
            Available { data | newEntry = str }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ErrorOccurred ->
            ( model, fetchList model.artificialLag ErrorOccurred processTodoListRawData )

        ListReceived ls ->
            ( { model | formData = Available <| ActualFormData ls "" }, focus "new-entry-textfield" )

        EntryAdditionRequested str ->
            ( { model | formData = Loading }, addEntry str model.artificialLag ErrorOccurred NewListRequested )

        EntryRemovalRequested id ->
            ( { model | formData = Loading }, removeEntry id model.artificialLag ErrorOccurred NewListRequested )

        NewListRequested ->
            ( { model | formData = Loading }, fetchList model.artificialLag ErrorOccurred processTodoListRawData )

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
    [ div [ class "container py-5 vh-100 d-flex flex-column" ]
        [ div [ class "card flex-grow-1 overflow-hidden" ]
            [ div [ class "card-header" ] [ h1 [ class "text-center" ] [ text "TODOs" ] ]
            , div [ class "card-body d-flex flex-column overflow-hidden gap-3" ]
                (case model.formData of
                    Available data ->
                        [ div [ class "flex-grow-1 overflow-auto" ] [ viewTodoList data.todoList ]
                        , viewTextBox data.newEntry
                        , viewSlider model.artificialLag
                        ]

                    Loading ->
                        [ div [ class "flex-grow-1 d-flex flex-column justify-content-center" ]
                            [ div [ class "d-flex justify-content-center" ]
                                [ div [ class "spinner-border" ] [] ]
                            ]
                        ]
                )
            ]
        ]
    ]


viewTextBox : String -> Html Msg
viewTextBox str =
    form
        (if str == "" then
            []

         else
            [ onSubmit (EntryAdditionRequested str) ]
        )
        [ div [ class "form-group" ]
            [ div [ class "input-group" ]
                [ input [ type_ "text", class "form-control", onInput TextChanged, id "new-entry-textfield", placeholder "Neuer Eintrag" ] [ text str ]
                , button [ class "btn btn-primary", type_ "submit", disabled (str == "") ] [ text "Hinzufügen" ]
                ]
            ]
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
                        , td [ class "text-end" ]
                            [ button [ class "btn", onClick (EntryRemovalRequested entry.id) ] [ text "❌" ]
                            ]
                        ]
                )
                ls
                (List.range 1 (List.length ls))
            )
        ]
