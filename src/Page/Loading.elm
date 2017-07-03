module Page.Loading exposing (..)

import Html exposing (Html)
import Material.Spinner as Spinner


view : Html msg
view =
    Spinner.spinner [ Spinner.active True ]
