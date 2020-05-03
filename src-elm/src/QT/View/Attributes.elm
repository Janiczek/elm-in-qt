module QT.View.Attributes exposing
    ( color
    , columns
    , height
    , spacing
    , text
    , width
    )

import QT.View.Internal as Internal
    exposing
        ( Attribute(..)
        , QMLValue(..)
        )



-- TODO `attribute` (custom)


text : String -> Attribute
text content =
    Attribute
        { name = "text"
        , value = String_ content
        }


{-| TODO float?
-}
width : Int -> Attribute
width width_ =
    Attribute
        { name = "width"
        , value = Int_ width_
        }


{-| TODO float?
-}
height : Int -> Attribute
height height_ =
    Attribute
        { name = "height"
        , value = Int_ height_
        }


color : String -> Attribute
color color_ =
    Attribute
        { name = "color"
        , value = String_ color_
        }


columns : Int -> Attribute
columns columns_ =
    Attribute
        { name = "columns"
        , value = Int_ columns_
        }


spacing : Int -> Attribute
spacing spacing_ =
    Attribute
        { name = "spacing"
        , value = Int_ spacing_
        }
