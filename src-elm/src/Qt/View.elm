module Qt.View exposing
    ( Attribute
    , Element
    , button
    , column
    , grid
    , node
    , nothing
    , rectangle
    , row
    , rowLayout
    , text
    , text_
    )

import Dict
import Qt.View.Attributes as Attrs
import Qt.View.Internal as Internal exposing (Element(..))


type alias Element msg =
    Internal.Element msg


type alias Attribute msg =
    Internal.Attribute msg


nothing : Element msg
nothing =
    Empty


node : String -> List (Attribute msg) -> List (Element msg) -> Element msg
node tag attrs children =
    Node
        { tag = tag
        , attrs = Dict.fromList attrs
        , children = children
        }


text : List (Attribute msg) -> String -> Element msg
text attrs content =
    node "Text"
        (Attrs.text content :: attrs)
        []


{-| Like Html.text. No formatting etc.
-}
text_ : String -> Element msg
text_ content =
    text [] content


grid : List (Attribute msg) -> List (Element msg) -> Element msg
grid =
    node "Grid"


row : List (Attribute msg) -> List (Element msg) -> Element msg
row =
    node "Row"


rowLayout : List (Attribute msg) -> List (Element msg) -> Element msg
rowLayout =
    node "RowLayout"


column : List (Attribute msg) -> List (Element msg) -> Element msg
column =
    node "Column"


rectangle : List (Attribute msg) -> List (Element msg) -> Element msg
rectangle =
    node "Rectangle"


button : List (Attribute msg) -> List (Element msg) -> Element msg
button =
    node "Button"
