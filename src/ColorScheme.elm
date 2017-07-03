module ColorScheme exposing (..)

import Material.Color as Color


error : Color.Color
error =
    Color.color Color.DeepOrange Color.A700


warning : Color.Color
warning =
    Color.color Color.Yellow Color.S500


unknown =
    Color.color Color.Grey Color.S500


success =
    Color.color Color.Green Color.S500
