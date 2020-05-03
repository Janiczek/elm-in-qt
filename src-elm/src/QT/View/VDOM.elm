module QT.View.VDOM exposing (encode)

import Json.Encode as Encode exposing (Value)
import QT.View.Internal
    exposing
        ( Attribute(..)
        , Element(..)
        , QMLValue(..)
        )


encode : Element -> Value
encode element =
    case element of
        Empty ->
            Encode.object
                [ ( "type", Encode.string "empty" ) ]

        Node node ->
            Encode.object
                [ ( "type", Encode.string "node" )
                , ( "tag", Encode.string node.tag )
                , ( "attrs", encodeAttributes node.attrs )
                , ( "children", Encode.list encode node.children )
                ]


encodeAttributes : List Attribute -> Value
encodeAttributes attrs =
    Encode.object <|
        List.map encodeAttribute attrs


encodeAttribute : Attribute -> ( String, Value )
encodeAttribute (Attribute attr) =
    ( attr.name, encodeQMLValue attr.value )


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
