module Page.Errored exposing (view, httpError, pageLoadError, PageLoadError, ErrorMessage)

{-| The page that renders when there was an error trying to load another page,
for example a Page Not Found error.
-}

-- MODEL --

import View.Page as Page exposing (ActivePage)
import Html
import Html.Attributes as Attributes
import Http


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


view : PageLoadError -> Html.Html msg
view (PageLoadError model) =
    Html.main_ [ Attributes.id "content", Attributes.class "container", Attributes.tabindex -1 ]
        [ Html.h1 [] [ Html.text "Error Loading Page" ]
        , Html.div [ Attributes.class "row" ]
            [ Html.p [] [ Html.text model.errorMessage ] ]
        ]
