module Config exposing (..)


type alias Config =
    { serverUrl : String
    , nodeFacts : List String
    , unresponsiveHours : Int
    , dashboardPanels : List (List DashboardPanelConfig)
    }


type alias DashboardPanelConfig =
    { title : String
    , bean : String
    , style : String
    , multiply : Maybe Float
    , unit : Maybe String
    }
