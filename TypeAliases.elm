module TypeAliases exposing (..)


type alias Taxis =
  { parentId : Maybe String
  , id : String
  , name : String
  }


type alias Species =
  { genusId : String
  , id : String
  , name : String
  , imageSource : String
  , firstParagraph : String
  }


type alias Model =
  { divisions : List Taxis
  , classes : List Taxis
  , orders : List Taxis
  , families : List Taxis
  , genuses : List Taxis
  , species : List Species
  , depth : Int
  , currentId : String
  }
