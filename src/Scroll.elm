module Scroll exposing (..)

import Http


type alias Model a =
    { perLoad : Int
    , grow : Int -> Http.Request (List a)
    , growing : Bool
    , reachedEnd : Bool
    , items : List a
    }


init : Int -> (Int -> Http.Request (List a)) -> Model a
init perLoad grow =
    { perLoad = perLoad
    , grow = grow
    , growing = False
    , reachedEnd = False
    , items = []
    }


setItems : Model a -> List a -> Model a
setItems model items =
    { model | items = items }


items : Model a -> List a
items model =
    model.items


isGrowing : Model a -> Bool
isGrowing model =
    model.growing


type Msg a
    = Grow
    | OnDataRetrieved (Result Http.Error (List a))


update : Msg a -> Model a -> ( Model a, Cmd (Msg a) )
update msg model =
    case msg of
        Grow ->
            ( { model | growing = True }
            , (if model.growing then
                Cmd.none
               else
                model.grow (List.length model.items)
                    |> Http.send OnDataRetrieved
              )
            )

        OnDataRetrieved (Err _) ->
            ( { model | growing = False }, Cmd.none )

        OnDataRetrieved (Ok result) ->
            ( { model
                | growing = False
                , items = List.concat [ model.items, result ]
              }
            , Cmd.none
            )
