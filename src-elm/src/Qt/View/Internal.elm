module Qt.View.Internal exposing
    ( Attribute(..)
    , Element(..)
    , EventHandlerData
    , PropertyData
    , QMLValue(..)
    , isProperty
    , transformEventHandlers
    )

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)


type Element msg
    = Empty
    | Node
        { tag : String
        , attrs : List (Attribute msg)
        , children : List (Element msg)
        }


type Attribute msg
    = Property PropertyData
      {- TODO I'm unsure this is OK naming. QT seems to have two meanings for
         properties, or maybe I'm just skim-reading the documentation wrong. (This
         is my second day in QT! Have mercy :D )
      -}
    | EventHandler (EventHandlerData msg)


type alias PropertyData =
    { name : String
    , value : QMLValue
    }


type alias EventHandlerData msg =
    { eventName : String
    , msg : msg -- TODO maybe document this (this can be either msg or Int depending on whether you've subscribed to the event handlers already)
    }


{-| <https://doc.qt.io/qt-5/qtqml-typesystem-basictypes.html>
TODO do the rest, like Enum etc.?
We perhaps don't need to support everything... We'll definitely leave some parts
of QML be... and only bootstrap Elm views off of what it offers
-}
type QMLValue
    = Bool Bool
    | Float Float
    | Int Int
    | String String
    | -- like `parent`, `margin`
      Raw String


isProperty : Attribute msg -> Bool
isProperty attr =
    case attr of
        Property _ ->
            True

        EventHandler _ ->
            False


transformEventHandlers : Int -> Element msg -> ( Element Int, Dict Int msg, Int )
transformEventHandlers lastEventId element =
    transformEventHandlersHelp
        Dict.empty
        lastEventId
        element


transformEventHandlersHelp :
    Dict Int msg
    -> Int
    -> Element msg
    -> ( Element Int, Dict Int msg, Int )
transformEventHandlersHelp events lastEventId element =
    case element of
        Empty ->
            ( Empty
            , events
            , lastEventId
            )

        Node node ->
            let
                ( newChildren, eventsAfterChildren, lastEventIdAfterChildren ) =
                    List.foldr
                        (\child ( accChildren, accEvents, accLastEventId ) ->
                            let
                                ( newChild, eventsAfterChild, lastEventIdAfterChild ) =
                                    transformEventHandlersHelp
                                        accEvents
                                        accLastEventId
                                        child
                            in
                            ( newChild :: accChildren
                            , eventsAfterChild
                            , lastEventIdAfterChild
                            )
                        )
                        ( [], events, lastEventId )
                        node.children

                ( newAttrs, newEvents, newLastEventId ) =
                    List.foldr
                        (\attr ( accAttrs, accEvents, accLastEventId ) ->
                            let
                                ( newAttr, eventsAfterAttr, lastEventIdAfterAttr ) =
                                    transformEventHandler
                                        accEvents
                                        accLastEventId
                                        attr
                            in
                            ( newAttr :: accAttrs
                            , eventsAfterAttr
                            , lastEventIdAfterAttr
                            )
                        )
                        ( [], eventsAfterChildren, lastEventIdAfterChildren )
                        node.attrs
            in
            ( Node
                { tag = node.tag
                , attrs = newAttrs
                , children = newChildren
                }
            , newEvents
            , newLastEventId
            )


transformEventHandler :
    Dict Int msg
    -> Int
    -> Attribute msg
    -> ( Attribute Int, Dict Int msg, Int )
transformEventHandler events lastEventId attr =
    case attr of
        Property prop ->
            ( Property prop, events, lastEventId )

        EventHandler handler ->
            let
                newEventId =
                    lastEventId + 1
            in
            ( EventHandler
                { eventName = handler.eventName
                , msg = newEventId
                }
            , Dict.insert newEventId handler.msg events
            , newEventId
            )
