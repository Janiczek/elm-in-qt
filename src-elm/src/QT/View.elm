module QT.View exposing
    ( Attribute
    , Element
    , grid
    , node
    , nothing
    , rectangle
    , text
    , text_
    )

import Dict
import QT.View.Attributes as Attrs
import QT.View.Internal as Internal exposing (Element(..))


type alias Element =
    Internal.Element


type alias Attribute =
    Internal.Attribute


nothing : Element
nothing =
    Empty


node : String -> List Attribute -> List Element -> Element
node tag attrs children =
    Node
        { tag = tag
        , attrs = attrs
        , children = children
        }


text : List Attribute -> String -> Element
text attrs content =
    node
        "Text"
        (Attrs.text content :: attrs)
        []


{-| Like Html.text. No formatting etc.
-}
text_ : String -> Element
text_ content =
    text [] content


grid : List Attribute -> List Element -> Element
grid =
    node "Grid"


rectangle : List Attribute -> List Element -> Element
rectangle =
    node "Rectangle"
