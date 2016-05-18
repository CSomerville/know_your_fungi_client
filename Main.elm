import Html exposing (..)
import Html.App
import Html.Events exposing (onClick)
import Http
import Task exposing (andThen)
import List exposing (filter)
import Json.Decode as Json
import TypeAliases exposing (Taxis, Species, Model)
import AccessData exposing (getByDepth, setByDepth)
import Decoders
import Debug


-- MAIN

main =
  Html.App.program
    { init = init getFungi
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL


init : Cmd Msg -> ( Model, Cmd Msg )
init cmd =
  ( Model [] [] [] [] [] [] 0 ""
  , cmd
  )


-- UPDATE

type Msg
  = FetchFungiSuccess (List Taxis, List Taxis)
  | FetchFungiFailure Http.Error
  | FetchTaxisSuccess ((List Taxis, List Taxis, List Taxis), Int)
  | FetchTaxisFailure Http.Error
  | Deeper String
  | Shallower String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    FetchFungiSuccess (divisions, classes) ->
      ( { model | divisions = divisions, classes = classes }
      , Cmd.none
      )

    FetchFungiFailure _ ->
      ( model, Cmd.none )

    FetchTaxisSuccess ((parents, currents, children), depth) ->
      ( model
          |> setByDepth (depth - 1) parents
          |> setByDepth (depth) currents
          |> setByDepth (depth + 1) children
      , Cmd.none )

    FetchTaxisFailure _ ->
      ( model, Cmd.none )

    Deeper (newId) ->
      if model.depth < 4 then
        ( { model | depth = model.depth + 1, currentId = newId }
        , callApi (model.depth + 1) newId
        )
      else
        ( model, Cmd.none )

    Shallower (newId) ->
      if model.depth > 0 then
        ( { model | depth = model.depth - 1, currentId = newId }
        , callApi (model.depth - 1) newId
        )
      else
        ( model, Cmd.none )


-- VIEW


currentlyVisible : Model -> List Taxis
currentlyVisible model =
  if model.depth == 0 then
    model.divisions
  else
    getByDepth model.depth model
      |> filter (\elem -> Maybe.withDefault "" elem.parentId == model.currentId)


oneTaxis : Taxis -> Html Msg
oneTaxis taxis =
  div [ onClick <| Deeper taxis.id ] [ text taxis.name ]


navigateUp : Model -> Msg
navigateUp model =
  let
    currentTaxis =
      getByDepth (model.depth - 1) model
        |> filter (\elem -> elem.id == model.currentId)
        |> List.head
        |> Maybe.withDefault (Taxis (Just "") "" "")
    parentId =
      Maybe.withDefault "" currentTaxis.parentId

  in
    Shallower parentId


view : Model -> Html Msg
view model =
  div []
    ( [ div
        [ onClick <| navigateUp model ]
        [ text <| "depth" ++ toString model.depth ]
      ] ++
      List.map oneTaxis (currentlyVisible model)
    )


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- HTTP

callApi : Int -> String -> Cmd Msg
callApi depth id =
  case depth of
    0 ->
      getFungi

    1 ->
      getTaxis ("divisions/" ++ id) Decoders.division depth

    2 ->
      getTaxis ("classes/" ++ id) Decoders.class depth

    3 ->
      getTaxis ("orders/" ++ id) Decoders.order depth

    _ ->
      Cmd.none


getFungi : Cmd Msg
getFungi =
  let url =
    "http://localhost:3000/api/fungi"
  in
    Task.perform FetchFungiFailure FetchFungiSuccess (Http.get Decoders.fungi url)


getTaxis : String -> Json.Decoder ( List Taxis, List Taxis, List Taxis ) -> Int -> Cmd Msg
getTaxis urlFrag decoder depth =
  let
    url =
      "http://localhost:3000/api/" ++ urlFrag
    request =
      Http.get decoder url
        |> Task.map (\res -> (res, depth))

  in
    Task.perform FetchTaxisFailure FetchTaxisSuccess request
