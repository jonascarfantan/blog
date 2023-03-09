module Page.Blog.Post exposing
    ( Metadata
    , Post
    , metadatas
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


files : DataSource (List File)
files =
    Glob.succeed File
        |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/blog/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource


type alias Post =
    { route : Route.Route
    , metadata : Metadata
    , body : String
    }


posts : DataSource (List Post)
posts =
    files
        |> DataSource.map
            (\paths ->
                paths
                    |> List.map
                        (\{ path, slug } ->
                            DataSource.map3 Post
                                (DataSource.succeed <|
                                    Route.Blog__Slug_
                                        { slug = slug }
                                )
                                (File.onlyFrontmatter metadataDecoder path)
                                (File.bodyWithoutFrontmatter path)
                        )
            )
        |> DataSource.resolve


type alias Metadata =
    { title : String
    , teaser : String
    , tags : List String
    , published : Date
    }


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


metadatas : DataSource (List ( Route.Route, Metadata ))
metadatas =
    files
        |> DataSource.map
            (\paths ->
                paths
                    |> List.map
                        (\{ path, slug } ->
                            DataSource.map2 Tuple.pair
                                (DataSource.succeed <|
                                    Route.Blog__Slug_
                                        { slug = slug }
                                )
                                (File.onlyFrontmatter
                                    metadataDecoder
                                    path
                                )
                        )
            )
        |> DataSource.resolve
