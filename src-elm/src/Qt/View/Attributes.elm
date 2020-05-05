module Qt.View.Attributes exposing
    ( anchorsCenterIn
    , boolProp
    , color
    , columns
    , floatProp
    , height
    , horizontalAlignment
    , intProp
    , layoutFillWidth
    , rawProp
    , spacing
    , stringProp
    , text
    , width
    )

import Qt.View.Internal as Internal
    exposing
        ( Attribute
        , AttributeValue(..)
        , QMLValue(..)
        )


property : String -> QMLValue -> Attribute msg
property name value =
    ( name, Property value )


intProp : String -> Int -> Attribute msg
intProp name value =
    property name <| Int value


floatProp : String -> Float -> Attribute msg
floatProp name value =
    property name <| Float value


stringProp : String -> String -> Attribute msg
stringProp name value =
    property name <| String value


boolProp : String -> Bool -> Attribute msg
boolProp name value =
    property name <| Bool value


rawProp : String -> String -> Attribute msg
rawProp name rawValue =
    property name <| Raw rawValue


text : String -> Attribute msg
text =
    stringProp "text"


width : Float -> Attribute msg
width =
    floatProp "width"


height : Float -> Attribute msg
height =
    floatProp "height"


color : String -> Attribute msg
color =
    stringProp "color"


columns : Int -> Attribute msg
columns =
    intProp "columns"


spacing : Int -> Attribute msg
spacing =
    intProp "spacing"


layoutFillWidth : Bool -> Attribute msg
layoutFillWidth =
    boolProp "Layout.fillWidth"


anchorsCenterIn : String -> Attribute msg
anchorsCenterIn =
    rawProp "anchors.centerIn"


horizontalAlignment : String -> Attribute msg
horizontalAlignment =
    rawProp "horizontalAlignment"
