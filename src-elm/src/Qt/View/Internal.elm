module Qt.View.Internal exposing
    ( Attribute
    , AttributeValue(..)
    , Element(..)
    , NodeData
    , QMLValue(..)
    , getNodeData
    , isProperty
    , transformEventHandlers
    )

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)


type Element msg
    = Empty
    | Node (NodeData msg)


type alias NodeData msg =
    { tag : String
    , attrs : Dict String (AttributeValue msg)
    , children : List (Element msg)
    }


type alias Attribute msg =
    ( String, AttributeValue msg )


{-| The `msg` here will typically be one of two types:

  - user-defined `Msg`
  - an `Int` (event ID) that we're using in the generated QML code to know which
    handler we're talking about, without resorting to needing `msgToString` and
    `msgFromString` from the user.

Note we must diff the `msg` ones, since different event IDs might just mean it's
the same event handler in a different generation of QML objects.

TODO check this claim ^ after we get proper VDOM diffing and patching

-}
type AttributeValue msg
    = Property QMLValue
    | EventHandler msg


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


isProperty : AttributeValue msg -> Bool
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
                    Dict.foldr
                        (\name attr ( accAttrs, accEvents, accLastEventId ) ->
                            let
                                ( newAttr, eventsAfterAttr, lastEventIdAfterAttr ) =
                                    transformEventHandler
                                        accEvents
                                        accLastEventId
                                        attr
                            in
                            ( Dict.insert name newAttr accAttrs
                            , eventsAfterAttr
                            , lastEventIdAfterAttr
                            )
                        )
                        ( Dict.empty, eventsAfterChildren, lastEventIdAfterChildren )
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
    -> AttributeValue msg
    -> ( AttributeValue Int, Dict Int msg, Int )
transformEventHandler events lastEventId attr =
    case attr of
        Property qmlValue ->
            ( Property qmlValue
            , events
            , lastEventId
            )

        EventHandler msg ->
            let
                newEventId =
                    lastEventId + 1
            in
            ( EventHandler newEventId
            , Dict.insert newEventId msg events
            , newEventId
            )


getNodeData : Element msg -> Maybe (NodeData msg)
getNodeData element =
    case element of
        Empty ->
            Nothing

        Node nodeData ->
            Just nodeData
