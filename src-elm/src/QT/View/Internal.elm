module QT.View.Internal exposing
    ( Attribute(..)
    , Element(..)
    , QMLValue(..)
    )


type Element
    = Empty
    | Node
        { tag : String
        , attrs : List Attribute
        , children : List Element
        }


type Attribute
    = Attribute
        { name : String
        , value : QMLValue
        }


{-| <https://doc.qt.io/qt-5/qtqml-typesystem-basictypes.html>
TODO do the rest, like Enum etc.?
We perhaps don't need to support everything... We'll definitely leave some parts
of QML be... and only bootstrap Elm views off of what it offers
-}
type QMLValue
    = Bool_ Bool
    | Float_ Float
    | Int_ Int
    | String_ String
    | List_ (List QMLValue)
