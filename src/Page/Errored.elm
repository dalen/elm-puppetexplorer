module Page.Errored exposing (view, pageLoadError, PageLoadError)

{-| The page that renders when there was an error trying to load another page,
for example a Page Not Found error.
-}

-- MODEL --

import View.Page as Page exposing (ActivePage)
import Html
import Html.Attributes as Attributes


type PageLoadError
    = PageLoadError Model


type alias Model =
    { activePage : ActivePage
    , errorMessage : String
    }


pageLoadError : ActivePage -> String -> PageLoadError
pageLoadError activePage errorMessage =
    PageLoadError { activePage = activePage, errorMessage = errorMessage }



-- VIEW --


view : PageLoadError -> Html.Html msg
view (PageLoadError model) =
    Html.main_ [ Attributes.id "content", Attributes.class "container", Attributes.tabindex -1 ]
        [ Html.h1 [] [ Html.text "Error Loading Page" ]
        , Html.div [ Attributes.class "row" ]
            [ Html.p [] [ Html.text model.errorMessage ] ]
        ]
