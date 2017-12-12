module Page.Errored exposing (view, httpError, pageLoadError, PageLoadError, ErrorMessage)

{-| The page that renders when there was an error trying to load another page,
for example a Page Not Found error.
-}

-- MODEL --

import View.Page as Page exposing (ActivePage)
import Html exposing (Html, text)
import Http
import Bootstrap.Alert as Alert


type PageLoadError
    = PageLoadError Model


type alias ErrorMessage =
    String


type alias Model =
    { activePage : ActivePage
    , errorMessage : ErrorMessage
    }


pageLoadError : ActivePage -> ErrorMessage -> PageLoadError
pageLoadError activePage errorMessage =
    PageLoadError { activePage = activePage, errorMessage = errorMessage }


httpError : String -> Http.Error -> ErrorMessage
httpError context error =
    "Error when loading "
        ++ context
        ++ ": "
        ++ (case error of
                Http.BadStatus resp ->
                    "Error " ++ (toString resp.status.code) ++ " : " ++ resp.body

                Http.BadUrl url ->
                    "The URL " ++ url ++ " is malformed"

                Http.Timeout ->
                    "Request timed out"

                Http.NetworkError ->
                    "Network error"

                Http.BadPayload str resp ->
                    "Could not parse response from PuppetDB: " ++ str
           )



-- VIEW --


view : PageLoadError -> Html msg
view (PageLoadError model) =
    Alert.danger
        [ Alert.h4 [] [ text "Error Loading Page" ]
        , text model.errorMessage
        ]
