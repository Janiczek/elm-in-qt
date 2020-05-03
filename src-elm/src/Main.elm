port module Main exposing (main)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Platform
import Process
import QT.View as V exposing (Element)
import QT.View.Attributes as VA
import QT.View.VDOM as V
import Task


port qmlToElm : (Value -> msg) -> Sub msg


port elmToQML : Value -> Cmd msg


main : Program () Model Msg
main =
    -- TODO abstract our weird QT view to a new `QT.element : Program ...`
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


type alias Rectangle =
    { color : String
    , width : Int
    , height : Int
    }


type alias Model =
    { rectangles : List Rectangle }


type Msg
    = MsgFromQML Value
    | FinishedSleeping


type MsgToQML
    = ElmInitFinished Element
    | NewVDOM Element


init : () -> ( Model, Cmd Msg )
init flags =
    let
        model =
            { rectangles =
                [ Rectangle "red" 50 50
                , Rectangle "green" 20 50
                , Rectangle "blue" 50 20
                , Rectangle "cyan" 50 50
                , Rectangle "magenta" 10 10
                ]
            }
    in
    ( model
    , Cmd.batch
        [ sendToQML <| ElmInitFinished <| view model
        , sleepAndRemoveRectangle
        ]
    )


sleepAndRemoveRectangle : Cmd Msg
sleepAndRemoveRectangle =
    Task.perform (\() -> FinishedSleeping) <| Process.sleep 1000


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    diff model <|
        case msg of
            MsgFromQML value ->
                let
                    _ =
                        Debug.log "[ELM] msg from QML" (Encode.encode 0 value)
                in
                ( model
                , Cmd.none
                )

            FinishedSleeping ->
                let
                    newModel =
                        { model | rectangles = List.drop 1 model.rectangles }
                in
                ( newModel
                , if List.isEmpty newModel.rectangles then
                    Cmd.none

                  else
                    sleepAndRemoveRectangle
                )


diff : Model -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
diff oldModel ( newModel, cmd ) =
    let
        -- TODO inefficient - cache it? Perhaps in the `QT.element : Program` layer
        oldView =
            view oldModel

        newView =
            view newModel
    in
    if oldView == newView then
        ( newModel, cmd )

    else
        ( newModel
        , Cmd.batch
            [ cmd
            , sendToQML <| NewVDOM newView
            ]
        )


view : Model -> Element
view model =
    V.grid
        [ VA.spacing 2
        , VA.columns 3
        ]
    <|
        List.map viewRectangle model.rectangles


viewRectangle : Rectangle -> Element
viewRectangle { color, width, height } =
    V.rectangle
        [ VA.width width
        , VA.height height
        , VA.color color
        ]
        []


sendToQML : MsgToQML -> Cmd msg
sendToQML msg =
    elmToQML <|
        case msg of
            ElmInitFinished vdom ->
                Encode.object
                    [ ( "tag", Encode.string "ElmInitFinished" )
                    , ( "initialVDOM", V.encode vdom )
                    ]

            NewVDOM vdom ->
                Encode.object
                    [ ( "tag", Encode.string "NewVDOM" )
                    , ( "vdom", V.encode vdom )
                    ]


subscriptions : Model -> Sub Msg
subscriptions model =
    qmlToElm MsgFromQML
