module Qt.View.Encode exposing (encode, encodePatch)

import Dict exposing (Dict)
import Json.Encode as Encode exposing (Value)
import Qt.View.Internal
    exposing
        ( Attribute
        , AttributeValue(..)
        , Element(..)
        , Patch(..)
        , QMLValue(..)
        , isProperty
        )


encodePatch : Patch Int -> Value
encodePatch patch =
    case patch of
        NoOp ->
            Encode.object [ ( "type", Encode.string "NoOp" ) ]

        Create element ->
            Encode.object
                [ ( "type", Encode.string "Create" )
                , ( "element", encode element )
                ]

        Remove ->
            Encode.object
                [ ( "type", Encode.string "Remove" ) ]

        ReplaceWith element ->
            Encode.object
                [ ( "type", Encode.string "ReplaceWith" )
                , ( "element", encode element )
                ]

        Update { attrs, children } ->
            Encode.object
                [ ( "type", Encode.string "Update" )
                , ( "attrs", Encode.list encodePatch attrs )
                , ( "children", Encode.list encodePatch children )
                ]

        SetAttr name attr ->
            Encode.object
                [ ( "type", Encode.string "SetAttr" )
                , ( "name", Encode.string name )
                , ( "attr", encodeAttr attr )
                ]

        RemoveAttr name ->
            Encode.object
                [ ( "type", Encode.string "RemoveAttr" )
                , ( "name", Encode.string name )
                ]


encodeAttr : AttributeValue Int -> Value
encodeAttr attr =
    case attr of
        Property qmlValue ->
            Encode.object
                [ ( "type", Encode.string "Property" )
                , ( "qmlValue", encodeQMLValue qmlValue )
                ]

        EventHandler eventId ->
            Encode.object
                [ ( "type", Encode.string "EventHandler" )
                , ( "eventId", Encode.int eventId )
                ]


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
