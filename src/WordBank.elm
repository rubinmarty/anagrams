module WordBank exposing (Entry, Key, WordBank, contains, empty, get, getChild, getChildren, insert, size, steals, travel, value)

import Dict exposing (Dict)


alphabet : List Char
alphabet =
    [ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' ]


type alias Key =
    String


sort : String -> String
sort str =
    str
        |> String.toUpper
        |> String.toList
        |> List.sort
        |> String.fromList


add : Char -> Key -> Key
add ch key =
    sort <| String.cons ch key


concat : Key -> Key -> Key
concat k1 k2 =
    sort <| k1 ++ k2


type alias WordBank =
    { prefix : Key
    , data : Dict Key (List Entry)
    }


type alias Entry =
    { word : String
    , definition : String
    }


empty : WordBank
empty =
    WordBank "" Dict.empty


getChild : Char -> WordBank -> WordBank
getChild ch wb =
    { wb | prefix = add ch wb.prefix }


insert : String -> String -> WordBank -> WordBank
insert word definition wb =
    let
        oldData =
            get word wb

        newData =
            oldData ++ [ Entry word definition ]
    in
    { wb | data = Dict.insert (concat word wb.prefix) newData wb.data }


contains : Key -> WordBank -> Bool
contains key wb =
    get key wb /= []


value : WordBank -> List Entry
value { prefix, data } =
    Dict.get prefix data
        |> Maybe.withDefault []


travel : Key -> WordBank -> WordBank
travel key wb =
    { wb | prefix = concat key wb.prefix }


get : Key -> WordBank -> List Entry
get key wb =
    value <| travel key wb


getChildren : WordBank -> List ( Char, WordBank )
getChildren wb =
    List.map (\ch -> ( ch, getChild ch wb )) alphabet


size : WordBank -> Int
size wb =
    Dict.size wb.data


steals : Int -> WordBank -> List (List String)
steals depth wb =
    steals_ 'A' depth wb


steals_ : Char -> Int -> WordBank -> List (List String)
steals_ ch depth wb =
    if depth == 0 then
        case value wb of
            [] ->
                []

            entries ->
                [ List.map .word entries ]

    else
        getChildrenStartingAt ch wb
            |> List.concatMap (\( ch2, wb2 ) -> steals_ ch2 (depth - 1) wb2)


getChildrenStartingAt : Char -> WordBank -> List ( Char, WordBank )
getChildrenStartingAt ch wb =
    alphabet
        |> List.filter (\a -> a >= ch)
        |> List.map (\a -> ( a, getChild a wb ))
