module Error exposing (..)

import Http
import Bootstrap.Alert as Alert
import Html


alert : String -> Http.Error -> Html.Html msg
alert context error =
    Alert.danger
        [ Html.strong [] [ Html.text ("Error while fetching " ++ context ++ ": ") ]
        , case error of
            Http.BadStatus resp ->
                Html.text ("Error " ++ (toString resp.status.code) ++ " : " ++ resp.body)

            Http.BadUrl url ->
                Html.text ("The URL " ++ url ++ " is malformed")

            Http.Timeout ->
                Html.text "Request timed out"

            Http.NetworkError ->
                Html.text "Network error"

            Http.BadPayload str resp ->
                Html.text ("Could not parse response from PuppetDB: " ++ str)
        ]
