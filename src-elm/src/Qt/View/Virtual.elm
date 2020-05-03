module Qt.View.Virtual exposing (encode)

import Json.Encode as Encode exposing (Value)
import Qt.View.Internal
    exposing
        ( Attribute(..)
        , Element(..)
        , EventHandlerData
        , PropertyData
        , QMLValue(..)
        , isProperty
        )


encode : Element Int -> Value
encode element =
    case element of
        Empty ->
            Encode.object
                [ ( "type", Encode.string "empty" ) ]

        Node node ->
            let
                ( properties, eventHandlers ) =
                    partitionAttrs node.attrs
            in
            Encode.object
                [ ( "type", Encode.string "node" )
                , ( "tag", Encode.string node.tag )
                , ( "props", encodeProperties properties )
                , ( "signals", encodeEventHandlers eventHandlers )
                , ( "children", Encode.list encode node.children )
                ]


partitionAttrs : List (Attribute Int) -> ( List PropertyData, List (EventHandlerData Int) )
partitionAttrs attrs =
    List.foldr
        (\attr ( props, handlers ) ->
            case attr of
                Property prop ->
                    ( prop :: props
                    , handlers
                    )

                EventHandler handler ->
                    ( props
                    , handler :: handlers
                    )
        )
        ( [], [] )
        attrs


encodeProperties : List PropertyData -> Value
encodeProperties props =
    Encode.object <|
        List.map encodeProperty props


encodeProperty : PropertyData -> ( String, Value )
encodeProperty prop =
    ( prop.name
    , encodeQMLValue prop.value
    )


encodeEventHandlers : List (EventHandlerData Int) -> Value
encodeEventHandlers handlers =
    Encode.object <|
        List.map encodeEventHandler handlers


encodeEventHandler : EventHandlerData Int -> ( String, Value )
encodeEventHandler handler =
    ( handler.eventName
    , Encode.int handler.msg
    )


encodeQMLValue : QMLValue -> Value
encodeQMLValue value =
    case value of
        Bool_ bool ->
            Encode.bool bool

        Float_ float ->
            Encode.float float

        Int_ int ->
            Encode.int int

        String_ string ->
            Encode.string string

        List_ list ->
            Encode.list encodeQMLValue list
