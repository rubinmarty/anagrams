module Main exposing (main)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav exposing (Key)
import Process
import Task
import Types exposing (Model, Msg(..))
import Url exposing (Url)
import Url.Parser
import Url.Parser.Query
import View
import WordBank exposing (WordBank)


main : Program String Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = View.view
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }


init : String -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            { wordBank = WordBank.empty
            , mWord = Nothing
            , key = key
            , searchBar = ""
            , loaded = False
            , mouseOver = Nothing
            }

        ( model_, _ ) =
            update (onUrlChange url) model
    in
    ( model_, loadWords flags )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Select mWord ->
            ( { model | mWord = Maybe.map String.toUpper mWord, mouseOver = Nothing }, Cmd.none )

        Internal url ->
            ( model, Nav.pushUrl model.key (Url.toString url) )

        External href ->
            ( model, Nav.load href )

        SearchBar string ->
            ( { model | searchBar = string }, Cmd.none )

        Search ->
            ( model, Nav.pushUrl model.key ("?word=" ++ model.searchBar) )

        GoHome ->
            ( { model | mWord = Nothing }, Cmd.none )

        AcceptWordBank wb ->
            ( { model | wordBank = wb, loaded = True }, Cmd.none )

        MouseOver mString ->
            ( { model | mouseOver = mString }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


loadWords : String -> Cmd Msg
loadWords file =
    Process.sleep 20
        |> Task.perform (\_ -> AcceptWordBank <| parseFile file)


getWordFromUrl : Url -> Maybe String
getWordFromUrl url =
    { url | path = "" }
        |> Url.Parser.parse (Url.Parser.query (Url.Parser.Query.string "word"))
        |> Maybe.andThen identity


onUrlRequest : UrlRequest -> Msg
onUrlRequest urlRequest =
    case urlRequest of
        Browser.Internal url ->
            Internal url

        Browser.External href ->
            External href


onUrlChange : Url -> Msg
onUrlChange url =
    Select <| getWordFromUrl url


parseFile : String -> WordBank
parseFile file =
    let
        combine line wb =
            case String.split "\t" line of
                word :: definition :: [] ->
                    WordBank.insert word definition wb

                _ ->
                    wb
    in
    file
        |> String.lines
        |> List.drop 2
        |> List.foldl combine WordBank.empty
