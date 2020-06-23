module View exposing (view)

import Browser exposing (Document)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Html
import Types exposing (Model, Msg(..))
import WordBank exposing (WordBank)


link : String -> Html a
link word =
    Html.a
        [ Attr.href ("?word=" ++ word) ]
        [ Html.text word ]


wordLinks : Maybe String -> List (List String) -> Html Msg
wordLinks mouseOver words =
    let
        connect nodes =
            List.intersperse (Html.text ", ") nodes

        wordNode : List String -> Html Msg
        wordNode wordVariants =
            let
                ( firstWord, otherWords ) =
                    case wordVariants of
                        [ oneWord ] ->
                            ( oneWord, [] )

                        h :: tl ->
                            ( h, tl )

                        _ ->
                            ( "", [] )
            in
            Html.span
                [ Attr.classList
                    [ ( "steal-word", True )
                    , ( "with-backups", otherWords /= [] )
                    ]
                , Html.onMouseOver (MouseOver <| Just firstWord)
                , Html.onMouseOut (MouseOver Nothing)
                ]
                [ link firstWord
                , Html.text
                    (if otherWords /= [] then
                        "*"

                     else
                        ""
                    )
                , Html.span
                    [ Attr.classList
                        [ ( "tooltip", True )
                        , ( "visible", mouseOver == Just firstWord )
                        ]
                    , Html.onMouseOver (MouseOver <| Just firstWord)
                    , Html.onMouseOut (MouseOver Nothing)
                    ]
                    [ Html.span [] (connect <| List.map link otherWords) ]
                ]

        wordNodes =
            List.map wordNode words
    in
    Html.span [] (connect wordNodes)


displayWord : String -> WordBank -> Maybe String -> Html Msg
displayWord word wb mouseOver =
    let
        wb2 =
            WordBank.travel word wb

        entries =
            WordBank.value wb2

        otherWordsNodes ow =
            if ow == [] then
                [ Html.text "" ]

            else
                Html.text " ( / " :: List.intersperse (Html.text " / ") (List.map link ow) ++ [ Html.text ")" ]
    in
    case entries of
        [] ->
            Html.div []
                [ Html.h1 [] [ Html.text word ]
                , Html.h5 [] [ Html.text "Sorry, that doesn't appear to be a real word." ]
                ]

        h :: tl ->
            let
                -- please don't try to understand this line
                ( primaryEntry, rest ) =
                    List.foldr
                        (\e ( f, r ) ->
                            if e.word == word then
                                ( e, f :: r )

                            else
                                ( f, e :: r )
                        )
                        ( h, [] )
                        tl
            in
            Html.div []
                [ Html.h1 [] <| [ Html.text <| primaryEntry.word ] ++ otherWordsNodes (List.map .word rest)
                , Html.h5 [] [ Html.text primaryEntry.definition ]
                , Html.h3 [] [ Html.text "One letter steals:" ]
                , wordLinks mouseOver <| WordBank.steals 1 wb2
                , Html.h3 [] [ Html.text "Two letter steals:" ]
                , wordLinks mouseOver <| WordBank.steals 2 wb2
                , Html.h3 [] [ Html.text "Three letter steals:" ]
                , wordLinks mouseOver <| WordBank.steals 3 wb2
                ]


searchBar : Html Msg
searchBar =
    Html.div
        [ Attr.id "searchBox" ]
        [ Html.span [] [ Html.text "Search for a word:" ]
        , Html.form
            [ Html.onSubmit Search, Attr.id "searchBar" ]
            [ Html.input [ Attr.type_ "text", Attr.placeholder "Search", Html.onInput SearchBar ] [] ]
        ]


view : Model -> Document Msg
view model =
    if not model.loaded then
        { title = "Loading..."
        , body = [ Html.h1 [] [ Html.text "Loading dictionary..." ] ]
        }

    else
        let
            title =
                case model.mWord of
                    Nothing ->
                        "Anagrams Solver"

                    Just word ->
                        "Anagrams Solver / " ++ word

            wordArea =
                case model.mWord of
                    Nothing ->
                        Html.text ""

                    Just word ->
                        displayWord word model.wordBank model.mouseOver

            body =
                Html.div [ Attr.style "padding" "40px" ]
                    [ searchBar
                    , wordArea
                    ]
        in
        { title = title
        , body = [ body ]
        }
