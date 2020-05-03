module Qt.View.Events exposing (on, onClick)

{-| The events here are basically the signals from QT documentation, like here:
<https://doc.qt.io/qt-5/qml-qtquick-controls2-abstractbutton.html#signals>

Note: signals don't bubble. QT isn't HTML :)

TODO we'll need to use decoders after all, eg. to get stuff from TextInput:
<https://doc.qt.io/qt-5/qml-qtquick-textinput.html#text-prop>
I guess the value given to decoders will be the whole object?

-}

import Qt.View.Internal exposing (Attribute(..))


on : String -> msg -> Attribute msg
on eventName msg =
    EventHandler
        { eventName = eventName
        , msg = msg
        }


onClick : msg -> Attribute msg
onClick msg =
    -- TODO case sensitivity?
    on "Clicked" msg
