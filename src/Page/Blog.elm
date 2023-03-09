module Page.Blog exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File as File
import DataSource.Glob as Glob
import Date exposing (Date)
import Head
import Head.Seo as Seo
import Html exposing (..)
import Json.Decode exposing (Decoder)
import OptimizedDecoder as Decode exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Route exposing (Route)
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


type alias Data =
    List ( Route, Metadata )


data : DataSource Data
data =
    metadatas


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website



-- VIEW


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Blog Blog"
    , body = List.map viewPostMetadata static.data
    }


viewPostMetadata : ( Route, Metadata ) -> Html Msg
viewPostMetadata ( route, post ) =
    div []
        [ text <| post.title ++ " " ++ post.teaser ++ " " ++ viewTags post.tags
        ]


viewTags : List String -> String
viewTags =
    String.concat



-- BLOG Blog


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

    --, published : Date
    }


metadataDecoder : Decoder Metadata
metadataDecoder =
    Decode.map3 Metadata
        (Decode.field "title" Decode.string)
        (Decode.field "teaser" Decode.string)
        (Decode.field "tags" (Decode.list Decode.string))


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
