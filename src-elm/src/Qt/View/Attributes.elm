module Qt.View.Attributes exposing
    ( color
    , columns
    , height
    , property
    , spacing
    , text
    , width
    )

import Qt.View.Internal as Internal
    exposing
        ( Attribute(..)
        , QMLValue(..)
        )


property : String -> QMLValue -> Attribute msg
property name value =
    Property
        { name = name
        , value = value
        }


text : String -> Attribute msg
text content =
    property "text" <| String_ content


{-| TODO float?
-}
width : Int -> Attribute msg
width width_ =
    property "width" <| Int_ width_


{-| TODO float?
-}
height : Int -> Attribute msg
height height_ =
    property "height" <| Int_ height_


color : String -> Attribute msg
color color_ =
    property "color" <| String_ color_


columns : Int -> Attribute msg
columns columns_ =
    property "columns" <| Int_ columns_


spacing : Int -> Attribute msg
spacing spacing_ =
    property "spacing" <| Int_ spacing_
