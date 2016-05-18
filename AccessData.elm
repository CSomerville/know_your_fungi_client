module AccessData exposing (..)

import TypeAliases exposing (..)


getByDepth : Int -> Model -> List Taxis
getByDepth depth model =
  case depth of
    0 ->
      model.divisions

    1 ->
      model.classes

    2 ->
      model.orders

    3 ->
      model.families

    4 ->
      model.genuses

    _ ->
      []


setByDepth : Int -> List Taxis -> Model -> Model
setByDepth depth taxis model =
  case depth of
    0 ->
      { model | divisions = taxis }

    1 ->
      { model | classes = taxis }

    2 ->
      { model | orders = taxis }

    3 ->
      { model | families = taxis }

    4 ->
      { model | genuses = taxis }

    _ ->
      model
