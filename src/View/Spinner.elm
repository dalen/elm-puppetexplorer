module View.Spinner exposing (view)

import Html
import Html.Attributes as Attributes


view : Html.Html msg
view =
    Html.i [ Attributes.class "fa fa-spinner fa-spin" ] []
