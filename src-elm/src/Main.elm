port module Main exposing (main)

import Json.Encode as Encode exposing (Value)
import Qt
import Qt.View as V exposing (Element)
import Qt.View.Attributes as VA
import Qt.View.Events as VE
import Time exposing (Posix)


port qtToElm : (Value -> msg) -> Sub msg


port elmToQt : Value -> Cmd msg


main : Program () (Qt.Model Model Msg) (Qt.Msg Msg)
main =
    Qt.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , qtToElm = qtToElm
        , elmToQt = elmToQt
        }


type alias Model =
    { currentPage : Page
    , counter : Int
    , bouncingBallLastTimestamp : Int
    , bouncingBallPosition : ( Float, Float )
    , bouncingBallVelocity : ( Float, Float )
    }


type Page
    = Counter
    | BouncingBall


type Msg
    = Increment
    | Decrement
    | NavigateTo Page
    | Tick Posix


bouncingBallWidth : Float
bouncingBallWidth =
    300


bouncingBallHeight : Float
bouncingBallHeight =
    200


bouncingBallMultiplier : Float
bouncingBallMultiplier =
    0.5


init : () -> ( Model, Cmd Msg )
init flags =
    ( { currentPage = Counter
      , counter = 0
      , bouncingBallLastTimestamp = 0
      , bouncingBallPosition = ( 0, 0 )
      , bouncingBallVelocity = ( 4, 2 )
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }
            , Cmd.none
            )

        Decrement ->
            ( { model | counter = model.counter - 1 }
            , Cmd.none
            )

        NavigateTo page ->
            ( { model | currentPage = page }
            , Cmd.none
            )

        Tick posixTimestamp ->
            let
                timestamp =
                    Time.posixToMillis posixTimestamp

                delta =
                    toFloat <| timestamp - model.bouncingBallLastTimestamp

                ( x, y ) =
                    model.bouncingBallPosition

                ( dx, dy ) =
                    model.bouncingBallVelocity

                newX =
                    clamp 0 bouncingBallWidth <|
                        x
                            + delta
                            * bouncingBallMultiplier
                            * dx

                newY =
                    clamp 0 bouncingBallHeight <|
                        y
                            + delta
                            * bouncingBallMultiplier
                            * dy

                newDx =
                    if newX == 0 || newX == bouncingBallWidth then
                        negate dx

                    else
                        dx

                newDy =
                    if newY == 0 || newY == bouncingBallHeight then
                        negate dy

                    else
                        dy
            in
            ( { model
                | bouncingBallLastTimestamp = timestamp
                , bouncingBallPosition = ( newX, newY )
                , bouncingBallVelocity = ( newDx, newDy )
              }
            , Cmd.none
            )


button :
    { onClick : Msg
    , text : String
    , highlighted : Bool
    }
    -> Element Msg
button { onClick, text } =
    V.rectangle
        [ VA.width 50
        , VA.height 30
        , VA.color "#bdc3c7"
        ]
        [ V.text
            [ VA.anchorsCenterIn "parent" ]
            text
        , V.mouseArea
            [ VA.anchorsFill "parent"
            , VE.onClick onClick
            , VA.rawProp "onPressed" "{ parent.color = \"#f1c40f\" }"
            , VA.rawProp "onReleased" "{ parent.color = \"#bdc3c7\" }"
            ]
            []
        ]


view : Model -> Element Msg
view model =
    V.columnLayout
        []
        [ navigationView model.currentPage
        , currentPageView model
        ]


currentPageView : Model -> Element Msg
currentPageView model =
    case model.currentPage of
        Counter ->
            counterView model.counter

        BouncingBall ->
            bouncingBallView model.bouncingBallPosition


navigationView : Page -> Element Msg
navigationView currentPage =
    V.rowLayout []
        ([ Counter
         , BouncingBall
         ]
            |> List.map
                (\page ->
                    button
                        { onClick = NavigateTo page
                        , text = pageLabel page
                        , highlighted = page == currentPage
                        }
                )
        )


pageLabel : Page -> String
pageLabel page =
    case page of
        Counter ->
            "Counter"

        BouncingBall ->
            "Bouncing Ball"


counterView : Int -> Element Msg
counterView counter =
    V.rowLayout
        [ VA.width 220
        , VA.anchorsCenterIn "parent"
        ]
        [ button
            { onClick = Decrement
            , text = "-"
            , highlighted = False
            }
        , V.text
            [ VA.layoutFillWidth True
            , VA.horizontalAlignment "Text.AlignHCenter"
            ]
            (String.fromInt counter)
        , button
            { onClick = Increment
            , text = "+"
            , highlighted = False
            }
        ]


circle : ( Float, Float ) -> Float -> String -> Element Msg
circle ( x, y ) width color =
    V.rectangle
        [ VA.width width
        , VA.height width
        , VA.radius (width / 2)
        , VA.color color
        , VA.x x
        , VA.y y
        ]
        []


bouncingBallView : ( Float, Float ) -> Element Msg
bouncingBallView position =
    V.rectangle []
        [ circle position 10 "red" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 16 Tick
