module Util exposing (..)

import Date exposing (Date)
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
