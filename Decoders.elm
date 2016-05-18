module Decoders exposing (fungi, division, class, order, family)

import Json.Decode as Json exposing ((:=))
import TypeAliases exposing (Taxis, Species)


fungi : Json.Decoder (List Taxis, List Taxis)
fungi = Json.object2 (,) decodeDivisions decodeClasses


division : Json.Decoder (List Taxis, List Taxis, List Taxis)
division = Json.object3 (,,)
  decodeDivisions decodeClasses decodeOrders


class : Json.Decoder (List Taxis, List Taxis, List Taxis)
class = Json.object3 (,,)
  decodeClasses decodeOrders decodeFamilies


order : Json.Decoder (List Taxis, List Taxis, List Taxis)
order = Json.object3 (,,)
  decodeOrders decodeFamilies decodeGenuses


family : Json.Decoder (List Taxis, List Taxis, List Species)
family = Json.object3 (,,)
  decodeFamilies decodeGenuses decodeSpecies


decodeDivisions : Json.Decoder (List Taxis)
decodeDivisions =
  ("divisions" :=
    Json.list (
    Json.object3 Taxis
      (Json.maybe ("notThere" := Json.string))
      ("id" := Json.string)
      ("division" := Json.string)
    )
  )


decodeClasses : Json.Decoder (List Taxis)
decodeClasses =
  ("classes" :=
    Json.list (
    Json.object3 Taxis
      (Json.maybe ("division_id" := Json.string))
      ("id" := Json.string)
      ("class" := Json.string)
    )
  )


decodeOrders : Json.Decoder (List Taxis)
decodeOrders =
  ("orders" :=
    Json.list (
    Json.object3 Taxis
      (Json.maybe ("class_id" := Json.string))
      ("id" := Json.string)
      ("taxonomic_order" := Json.string)
    )
  )


decodeFamilies : Json.Decoder (List Taxis)
decodeFamilies =
  ("families" :=
    Json.list (
    Json.object3 Taxis
      (Json.maybe ("taxonomic_order_id" := Json.string))
      ("id" := Json.string)
      ("family" := Json.string)
    )
  )


decodeGenuses : Json.Decoder (List Taxis)
decodeGenuses =
  ("genuses" :=
    Json.list (
    Json.object3 Taxis
      (Json.maybe ("family_id" := Json.string))
      ("id" := Json.string)
      ("genus" := Json.string)
    )
  )


decodeSpecies : Json.Decoder (List Species)
decodeSpecies =
  ("species" :=
    Json.list (
    Json.object5 Species
      ("genus_id" := Json.string)
      ("id" := Json.string)
      ("species" := Json.string)
      ("image_source" := Json.string)
      ("first_paragraph" := Json.string)
    )
  )
