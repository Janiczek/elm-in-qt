module Qt exposing (Model, Msg, UserOptions, element)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Platform
import Qt.View.Encode as V
import Qt.View.Internal as V exposing (Element)


type alias Model model msg =
    { lastEventId : Int
    , events : Dict Int msg
    , userModel : model
    , {- `Element msg` are good for diffing;
         generation of `Element Int` is stateful:
         see `Qt.View.Internal.transformEventHandlers
      -}
      userViewUnhandled : Element msg
    , userView : Element Int
    }


type Msg msg
    = EventEmitted Int
    | UserMsg msg
    | UnknownMsgFromQt Decode.Error


type MsgToQML msg
    = ElmInitFinished (Element Int)
    | NewView (Element Int)


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

        {- TODO We're doing this once here and once in deriveView...
           Is there a better way?
           (See the comment below near `deriveView user Nothing`)
        -}
        userViewUnhandled =
            user.view userModel

        ( userView, _, _ ) =
            V.transformEventHandlers
                lastEventId
                userViewUnhandled
    in
    ( { lastEventId = lastEventId
      , events = Dict.empty
      , userModel = userModel
      , userViewUnhandled = userViewUnhandled
      , userView = userView
      }
    , Cmd.map UserMsg userCmd
    )
        {- We intentionally send Nothing here (because there's no previous view).
           We need to put something into the `Model.userView` though so in effect we
           compute it twice. I guess this could be solved by `userView : Maybe ...`
           but I don't want to compromise on that :) TODO think of something
        -}
        |> deriveView user Nothing


deriveView :
    UserOptions flags model msg (Msg msg)
    -> Maybe (Element msg)
    -> ( Model model msg, Cmd (Msg msg) )
    -> ( Model model msg, Cmd (Msg msg) )
deriveView user maybeOldView ( model, cmd ) =
    let
        newUserViewUnhandled =
            user.view model.userModel
    in
    if maybeOldView == Just newUserViewUnhandled then
        ( model, cmd )

    else
        let
            ( newUserView, newEvents, newLastEventId ) =
                V.transformEventHandlers
                    model.lastEventId
                    newUserViewUnhandled
        in
        ( { model
            | userView = newUserView
            , userViewUnhandled = newUserViewUnhandled
            , events = newEvents
            , lastEventId = newLastEventId
          }
        , Cmd.batch
            [ cmd
            , sendToQt user <| NewView newUserView
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
        |> deriveView user (Just model.userViewUnhandled)


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
