module Page.Loading exposing (..)

import Html exposing (Html)
import Polymer.Paper as Paper
import Polymer.Attributes exposing (boolProperty)


view : Html msg
view =
    Paper.spinner [ boolProperty "active" True ] []
