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


init : () -> ( Model, Cmd Msg )
init flags =
    ( {}
    , elmToQML <| Encode.string "Just started!"
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgFromQML value ->
            let
                _ =
                    Debug.log "value" value
            in
            ( model
            , elmToQML <| Encode.string "Got that!"
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    qmlToElm MsgFromQML
