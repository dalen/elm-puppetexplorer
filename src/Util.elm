module Util exposing (..)

import Date exposing (Date)
import Date.Extra
import Date.Distance
import Date.Distance.I18n.En
import Round
import Regex


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


roundSignificantFigures : Int -> Float -> String
roundSignificantFigures figures number =
    let
        numString =
            toString number

        ( beforeDecimal, afterDecimal ) =
            case List.head (String.indexes "." numString) of
                Nothing ->
                    ( String.length numString, 0 )

                Just pos ->
                    if String.startsWith "0" numString then
                        -- Number like 0.005
                        let
                            numZeros =
                                case
                                    List.head
                                        (Regex.find
                                            (Regex.AtMost 1)
                                            (Regex.regex "^0*")
                                            (String.dropLeft 2 numString)
                                        )
                                of
                                    Nothing ->
                                        0

                                    Just match ->
                                        String.length match.match
                        in
                            ( 0, numZeros )
                    else
                        ( pos, 0 )
    in
        Round.round (figures - beforeDecimal + afterDecimal) number


roundSignificantFiguresPretty : Int -> Float -> String
roundSignificantFiguresPretty figures number =
    Regex.replace (Regex.AtMost 1) (Regex.regex "\\.0+$") (\_ -> "") (roundSignificantFigures figures number)
