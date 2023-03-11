module Domain.Post exposing
    ( Metadata
    , Post
    , metadatas
    , posts
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
    , metadata : Metadata
    , body : String
    }
type alias Metadata =
    { title : String
    , teaser : String
    , tags : List String
    , published : Date
    }

files : DataSource (List File)
files =
    Glob.succeed File
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/blog/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource
route : String -> DataSource Route
route slug =
    DataSource.succeed <| Route.Blog__Slug_ { slug = slug }

posts : DataSource (List Post)
posts =
    files
        |> DataSource.map
            (\paths ->
                paths
                    |> List.map
                        (\{ path, slug } ->
                            DataSource.map3 Post
                                (route slug )
                                (File.onlyFrontmatter metadataDecoder path)
                                (File.bodyWithoutFrontmatter path)
                        )
            )
        |> DataSource.resolve

metadataDecoder : Decoder Metadata
metadataDecoder =
    Decode.map4 Metadata
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


metadatas : DataSource (List Metadata)
metadatas =
    files
        |> DataSource.map
            (\paths -> paths
                |> List.map
                    (\{ path } ->
                        File.onlyFrontmatter
                            metadataDecoder
                            path
                    )
            )
        |> DataSource.resolve
