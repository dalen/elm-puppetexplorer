module Util exposing (..)

import Date exposing (Date)
import Date.Extra
import Date.Distance
import Date.Distance.I18n.En


dateDistance : Date -> Date -> String
dateDistance =
    let
        locale =
            Date.Distance.I18n.En.locale { addSuffix = True }

        defaultConfig =
            Date.Distance.defaultConfig

        config =
            { defaultConfig | locale = locale }
    in
        Date.Distance.inWordsWithConfig config


{-| Hours and minutes
-}
time : Date -> String
time date =
    Date.Extra.toFormattedString "hh:mm:ssX" date


{-| ISO format without milliseconds
-}
formattedDate : Date -> String
formattedDate date =
    Date.Extra.toFormattedString "YYYY-MM-ddThh:mm:ssX" date
