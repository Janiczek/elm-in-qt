module Qt exposing (Model, Msg, UserOptions, element)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Platform
import Qt.View.Internal exposing (Element)
import Qt.View.Virtual as V


type alias Model model msg =
    { lastEventId : Int
    , subscribedEvents : Dict Int msg
    , userModel : model
    , userView : Element msg
    }


type Msg msg
    = EventEmitted Int
    | UserMsg msg
    | UnknownMsgFromQt Decode.Error


type MsgToQML msg
    = ElmInitFinished (Element msg)
    | NewView (Element msg)


type alias UserOptions flags model msg qtMsg =
    { init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> Element msg
    , qtToElm : (Value -> qtMsg) -> Sub qtMsg
    , elmToQt : Value -> Cmd qtMsg
    }


element : UserOptions flags model msg (Msg msg) -> Program flags (Model model msg) (Msg msg)
element user =
    Platform.worker
        { init = init user
        , update = update user
        , subscriptions = subscriptions user
        }


init : UserOptions flags model msg (Msg msg) -> flags -> ( Model model msg, Cmd (Msg msg) )
init user flags =
    let
        ( userModel, userCmd ) =
            user.init flags

        userView =
            user.view userModel
    in
    ( { lastEventId = 0
      , subscribedEvents = Dict.empty
      , userModel = userModel
      , userView = userView
      }
    , Cmd.batch
        [ Cmd.map UserMsg userCmd
        , sendToQt user <| ElmInitFinished userView
        ]
    )


update : UserOptions flags model msg (Msg msg) -> Msg msg -> Model model msg -> ( Model model msg, Cmd (Msg msg) )
update user msg model =
    case msg of
        EventEmitted eventId ->
            Debug.todo <| "EventEmitted " ++ String.fromInt eventId

        UserMsg userMsg ->
            let
                ( newUserModel, userCmd ) =
                    user.update userMsg model.userModel

                newUserView =
                    user.view newUserModel
            in
            ( { model
                | userModel = newUserModel
                , userView = newUserView
              }
            , Cmd.batch
                [ Cmd.map UserMsg userCmd
                , if model.userView == newUserView then
                    Cmd.none

                  else
                    sendToQt user <| NewView newUserView
                ]
            )

        UnknownMsgFromQt err ->
            Debug.todo <| "unknown msg from Qt: " ++ Decode.errorToString err


subscriptions : UserOptions flags model msg (Msg msg) -> Model model msg -> Sub (Msg msg)
subscriptions user model =
    Sub.batch
        [ Sub.map UserMsg <| user.subscriptions model.userModel
        , user.qtToElm msgFromQt
        ]


msgFromQt : Value -> Msg msg
msgFromQt value =
    case Decode.decodeValue msgFromQtDecoder value of
        Ok msg ->
            msg

        Err err ->
            UnknownMsgFromQt err


msgFromQtDecoder : Decoder (Msg msg)
msgFromQtDecoder =
    Decode.field "tag" Decode.string
        |> Decode.andThen
            (\tag ->
                case tag of
                    "EventEmitted" ->
                        Decode.map EventEmitted <| Decode.field "eventId" Decode.int

                    _ ->
                        Decode.fail tag
            )


sendToQt : UserOptions flags model msg (Msg msg) -> MsgToQML msg -> Cmd (Msg msg)
sendToQt user msg =
    user.elmToQt <|
        case msg of
            ElmInitFinished view ->
                Encode.object
                    [ ( "tag", Encode.string "ElmInitFinished" )
                    , ( "initialView", V.encode view )
                    ]

            NewView view ->
                Encode.object
                    [ ( "tag", Encode.string "NewView" )
                    , ( "view", V.encode view )
                    ]
