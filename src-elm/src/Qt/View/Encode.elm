module Qt.View.Encode exposing (encode)

import Dict exposing (Dict)
import Json.Encode as Encode exposing (Value)
import Qt.View.Internal
    exposing
        ( Attribute
        , AttributeValue(..)
        , Element(..)
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


partitionAttrs : Dict String (AttributeValue Int) -> ( List ( String, QMLValue ), List ( String, Int ) )
partitionAttrs attrs =
    Dict.foldl
        (\name attr ( props, handlers ) ->
            case attr of
                Property prop ->
                    ( ( name, prop ) :: props
                    , handlers
                    )

                EventHandler handler ->
                    ( props
                    , ( name, handler ) :: handlers
                    )
        )
        ( [], [] )
        attrs


encodeProperties : List ( String, QMLValue ) -> Value
encodeProperties props =
    Encode.object <|
        List.map encodeProperty props


encodeProperty : ( String, QMLValue ) -> ( String, Value )
encodeProperty ( name, qmlValue ) =
    ( name
    , encodeQMLValue qmlValue
    )


encodeEventHandlers : List ( String, Int ) -> Value
encodeEventHandlers handlers =
    Encode.object <|
        List.map encodeEventHandler handlers


encodeEventHandler : ( String, Int ) -> ( String, Value )
encodeEventHandler ( name, eventId ) =
    ( name
    , Encode.int eventId
    )


encodeQMLValue : QMLValue -> Value
encodeQMLValue value =
    case value of
        Bool bool ->
            Encode.bool bool

        Float float ->
            Encode.float float

        Int int ->
            Encode.int int

        String string ->
            Encode.string string

        Raw rawValue ->
            Encode.object
                [ ( "rawValue", Encode.string rawValue ) ]
