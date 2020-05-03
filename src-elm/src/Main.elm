port module Main exposing (main)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Qt
import Qt.View as V exposing (Element)
import Qt.View.Attributes as VA
import Qt.View.Events as VE


port qtToElm : (Value -> msg) -> Sub msg


port elmToQt : Value -> Cmd msg


main : Program () (Qt.Model Model Msg) (Qt.Msg Msg)
main =
    Qt.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , qtToElm = qtToElm
        , elmToQt = elmToQt
        }


type alias Model =
    { counter : Int }


type Msg
    = Increment
    | Decrement


init : () -> ( Model, Cmd Msg )
init flags =
    ( { counter = 0 }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }
            , Cmd.none
            )

        Decrement ->
            ( { model | counter = model.counter - 1 }
            , Cmd.none
            )


view : Model -> Element Msg
view model =
    V.rowLayout
        [ VA.width 220
        , VA.anchorsCenterIn "parent"
        ]
        [ V.button
            [ VE.onClick Decrement
            , VA.text "-"
            ]
            []
        , V.text
            [ VA.layoutFillWidth True
            , VA.horizontalAlignment "Text.AlignHCenter"
            ]
            (String.fromInt model.counter)
        , V.button
            [ VE.onClick Increment
            , VA.text "+"
            ]
            []
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
