module Qt exposing (Model, Msg, UserOptions, element)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Platform
import Qt.View.Diff as V
import Qt.View.Encode as V
import Qt.View.Internal as V
    exposing
        ( Element
        , Patch(..)
        )


type alias Model model msg =
    { lastEventId : Int
    , events : Dict Int msg
    , userModel : model
    , userView : Element msg
    }


type Msg msg
    = EventEmitted Int
    | UserMsg msg
    | UnknownMsgFromQt Decode.Error


type MsgToQML msg
    = ViewChanged (Patch Int)


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
        lastEventId =
            0

        ( userModel, userCmd ) =
            user.init flags

        userView =
            user.view userModel
    in
    ( { lastEventId = lastEventId
      , events = Dict.empty
      , userModel = userModel
      , userView = userView
      }
    , Cmd.map UserMsg userCmd
    )
        |> deriveView user Nothing


deriveView :
    UserOptions flags model msg (Msg msg)
    -> Maybe (Element msg)
    -> ( Model model msg, Cmd (Msg msg) )
    -> ( Model model msg, Cmd (Msg msg) )
deriveView user maybeOldView ( model, cmd ) =
    let
        newUserView =
            user.view model.userModel

        patch =
            case maybeOldView of
                Nothing ->
                    ReplaceWith newUserView

                Just oldView ->
                    V.diff
                        { old = oldView
                        , new = newUserView
                        }
    in
    if patch == NoOp then
        ( model, cmd )

    else
        let
            ( patchWithEventIds, newEvents, newLastEventId ) =
                V.transformEventHandlers
                    model.events
                    model.lastEventId
                    patch
        in
        ( { model
            | userView = newUserView
            , events = newEvents
            , lastEventId = newLastEventId
          }
        , Cmd.batch
            [ cmd
            , sendToQt user <| ViewChanged <| patchWithEventIds
            ]
        )


update :
    UserOptions flags model msg (Msg msg)
    -> Msg msg
    -> Model model msg
    -> ( Model model msg, Cmd (Msg msg) )
update user msg model =
    case msg of
        EventEmitted eventId ->
            case Dict.get eventId model.events of
                Nothing ->
                    -- Didn't find this event in our registered event handlers!
                    ( model, Cmd.none )

                Just userMsg ->
                    handleUserMsg user userMsg model

        UserMsg userMsg ->
            handleUserMsg user userMsg model

        UnknownMsgFromQt err ->
            -- TODO what to do here? Some kind of logging?
            ( model, Cmd.none )


handleUserMsg :
    UserOptions flags model msg (Msg msg)
    -> msg
    -> Model model msg
    -> ( Model model msg, Cmd (Msg msg) )
handleUserMsg user userMsg model =
    let
        ( newUserModel, userCmd ) =
            user.update userMsg model.userModel
    in
    ( { model | userModel = newUserModel }
    , Cmd.map UserMsg userCmd
    )
        |> deriveView user (Just model.userView)


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
            ViewChanged patch ->
                Encode.object
                    [ ( "tag", Encode.string "ViewChanged" )
                    , ( "patch", V.encodePatch patch )
                    ]
