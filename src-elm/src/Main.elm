port module Main exposing (main)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Platform


port qmlToElm : (Value -> msg) -> Sub msg


port elmToQML : Value -> Cmd msg


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    {}


type Msg
    = MsgFromQML Value


type MsgToQML
    = JustStarted
    | Echo Value


init : () -> ( Model, Cmd Msg )
init flags =
    ( {}
    , sendToQML JustStarted
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgFromQML value ->
            let
                _ =
                    Debug.log "in Elm: we got some msg from QML" (Encode.encode 0 value)
            in
            ( model
            , sendToQML <| Echo value
            )


sendToQML : MsgToQML -> Cmd msg
sendToQML msg =
    elmToQML <|
        case msg of
            JustStarted ->
                Encode.object
                    [ ( "tag", Encode.string "JustStarted" ) ]

            Echo value ->
                Encode.object
                    [ ( "tag", Encode.string "Echo" )
                    , ( "value", value )
                    ]


subscriptions : Model -> Sub Msg
subscriptions model =
    qmlToElm MsgFromQML
