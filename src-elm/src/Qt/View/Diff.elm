module Qt.View.Diff exposing (Patch(..), diff)

{-| Inspired (heavily!) by
<https://github.com/heiskr/prezzy-vdom-example/blob/master/index.master.js>
<https://www.youtube.com/watch?v=l2Tu0NqH0qU>
-}

import Dict
import Qt.View.Internal
    exposing
        ( Attribute(..)
        , Element(..)
        , NodeData
        , getNodeData
        )


type Patch msg
    = NoOp
    | Create (Element msg)
    | Remove
    | ReplaceWith (Element msg)
    | Update
        { attrs : List (Patch msg)
        , children : List (Patch msg)
        }
    | SetAttr String (Attribute msg)
    | RemoveAttr String (Attribute msg)


diff :
    { old : Element msg
    , new : Element msg
    }
    -> Patch msg
diff ({ old, new } as elements) =
    if didChange elements then
        ReplaceWith new

    else
        Maybe.map2
            (\oldNode newNode ->
                let
                    nodes =
                        { old = oldNode
                        , new = newNode
                        }
                in
                Update
                    { attrs = diffAttrs nodes
                    , children = diffChildren nodes
                    }
            )
            (getNodeData old)
            (getNodeData new)
            |> Maybe.withDefault NoOp


didChange :
    { old : Element msg
    , new : Element msg
    }
    -> Bool
didChange { old, new } =
    case ( old, new ) of
        ( Empty, Empty ) ->
            False

        ( Empty, Node _ ) ->
            True

        ( Node _, Empty ) ->
            True

        ( Node oldNode, Node newNode ) ->
            oldNode.tag /= newNode.tag


diffAttrs :
    { old : NodeData msg
    , new : NodeData msg
    }
    -> List (Patch msg)
diffAttrs { old, new } =
    Dict.merge
        (\name oldAttr acc -> RemoveAttr name oldAttr :: acc)
        (\name oldAttr newAttr acc ->
            if oldAttr /= newAttr then
                SetAttr name newAttr :: acc

            else
                acc
        )
        (\name newAttr acc -> SetAttr name newAttr :: acc)
        old.attrs
        new.attrs
        []


diffChildren :
    { old : NodeData msg
    , new : NodeData msg
    }
    -> List (Patch msg)
diffChildren { old, new } =
    let
        patchesForCommon =
            List.map2
                (\oldChild newChild ->
                    diff
                        { old = oldChild
                        , new = newChild
                        }
                )
                old.children
                new.children

        oldLength =
            List.length old.children

        newLength =
            List.length new.children

        patchesForExtra =
            case compare oldLength newLength of
                LT ->
                    new.children
                        |> List.drop oldLength
                        |> List.map Create

                EQ ->
                    []

                GT ->
                    List.repeat (oldLength - newLength) Remove
    in
    patchesForCommon ++ patchesForExtra
