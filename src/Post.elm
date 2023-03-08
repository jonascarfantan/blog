module Post exposing
    ( Post
    , PostMetadata
    )

import DataSource exposing (DataSource)
import DataSource.File as File
import DataSource.Glob as Glob exposing (Glob)
import Date exposing (Date)
import Html.Styled as Html exposing (Html)
import Markdown.Block exposing (Block)
import Markdown.Parser
import OptimizedDecoder exposing (Decoder)
import Route
import Shared


type alias Post =
    { filePath : String
    , subPath : List String
    , slug : String
    }


type alias FullPost =
    { route : Route.Route
    , metadata : PostMetadata
    , content : String
    }


type alias PostMetadata =
    { title : String
    , description : String
    , published : Date
    , draft : Bool
    , rss : Bool
    }
