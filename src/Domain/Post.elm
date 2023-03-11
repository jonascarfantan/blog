module Domain.Post exposing
    ( Metadata
    , toPostList
    )

import DataSource exposing (DataSource)
import DataSource.File as File
import DataSource.Glob as Glob
import Date exposing (Date)
import Html.Styled as Html exposing (Html)
import Markdown.Block exposing (Block)
import OptimizedDecoder as Decode exposing (Decoder)
import Route exposing (Route)

type alias File =
    { path : String
    , slug : String
    }

type alias Post =
    { route : Route.Route
    , metadata : RawMetadata
    , body : String
    }

type alias RawMetadata =
    { title : String
    , teaser : String
    , tags : List String
    , published : Date
    }

type alias Metadata =
    { title : String
    , teaser : String
    , tags : List String
    , published : PresentableDate
    }

type alias PresentableDate = 
    { day : String
    , month : String
    , year : String
    }

-- Exposed   
toPostList : DataSource (List (Route, Metadata))
toPostList =
    readFiles
        |> DataSource.map
            (\files ->
                files
                    |> List.map
                        (\ { path, slug } -> 
                            DataSource.map2 Tuple.pair
                                (route slug)
                                (fromRawMetadata
                                    <| File.onlyFrontmatter metadataDecoder path)
                        )
            ) |> DataSource.resolve

-- Internal
readFiles : DataSource (List File)
readFiles =
    Glob.succeed File
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/blog/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource

route : String -> DataSource Route
route slug =
    DataSource.succeed <| Route.Blog__Slug_ { slug = slug }


presentableDate : Date -> PresentableDate
presentableDate date =
    PresentableDate
        (date |> Date.format "dd")
        (date |> Date.format "MM")
        (date |> Date.format "yyyy")

fromRawMetadata : DataSource RawMetadata -> DataSource Metadata
fromRawMetadata raw =
    raw 
        |> DataSource.map
            (\ { title, teaser, tags, published } ->
                { title = title
                , teaser = teaser
                , tags = tags
                , published = presentableDate published
                }
            )

metadataDecoder : Decoder RawMetadata
metadataDecoder =
    Decode.map4 RawMetadata
        (Decode.field "title" Decode.string)
        (Decode.field "teaser" Decode.string)
        (Decode.field "tags" (Decode.list Decode.string))
        (Decode.field "published"
            (Decode.string
                |> Decode.andThen
                    (\isoString ->
                        case Date.fromIsoString isoString of
                            Ok date ->
                                Decode.succeed date

                            Err error ->
                                Decode.fail error
                    )
            )
        )
          
metadatas : DataSource (List RawMetadata)
metadatas =
    readFiles
        |> DataSource.map
            (\files -> files
                |> List.map
                    (\{ path } ->
                        File.onlyFrontmatter
                            metadataDecoder
                            path
                    )
            )
        |> DataSource.resolve
-- Unused
--posts : DataSource (List Post)
--posts =
--    readFiles
--        |> DataSource.map
--            (\files ->
--                files
--                    |> List.map
--                        (\{ path, slug } ->
--                            DataSource.map3 Post
--                                (route slug )
--                                (File.onlyFrontmatter metadataDecoder path)
--                                (File.bodyWithoutFrontmatter path)
--                        )
--            )
--        |> DataSource.resolve