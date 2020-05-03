module Qt.View.Internal exposing
    ( Attribute(..)
    , Element(..)
    , EventHandlerData
    , PropertyData
    , QMLValue(..)
    , isProperty
    )

import Json.Decode as Decode exposing (Decoder)


type Element msg
    = Empty
    | Node
        { tag : String
        , attrs : List (Attribute msg)
        , children : List (Element msg)
        }


type Attribute msg
    = Property PropertyData
      {- TODO I'm unsure this is OK naming. QT seems to have two meanings for
         properties, or maybe I'm just skim-reading the documentation wrong. (This
         is my second day in QT! Have mercy :D )
      -}
    | NotHandledEventHandler (NotHandledEventHandlerData msg)
    | EventHandler EventHandlerData


type alias PropertyData =
    { name : String
    , value : QMLValue
    }


type alias NotHandledEventHandlerData msg =
    { eventName : String
    , msg : msg
    }


type alias EventHandlerData =
    { eventName : String
    , eventId : Int
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


isProperty : Attribute msg -> Bool
isProperty attr =
    case attr of
        Property _ ->
            True

        NotHandledEventHandler _ ->
            False

        EventHandler _ ->
            False
