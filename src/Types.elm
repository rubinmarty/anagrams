module Types exposing (Model, Msg(..))

import Browser.Navigation as Browser
import Url exposing (Url)
import WordBank exposing (WordBank)


type alias Model =
    { wordBank : WordBank
    , mWord : Maybe String
    , key : Browser.Key
    , searchBar : String
    , loaded : Bool
    , mouseOver : Maybe String
    }


type Msg
    = NoOp
    | Select (Maybe String)
    | Internal Url
    | External String
    | Search
    | SearchBar String
    | GoHome
    | AcceptWordBank WordBank
    | MouseOver (Maybe String)
