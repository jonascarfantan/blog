module Page.Blog exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Date exposing (Date)
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes exposing (alt, attribute, checked, class, controls, disabled, for, height, href, id, method, name, placeholder, src, start, style, target, title, type_, value, width)
import Json.Decode exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Page.Blog.Post as Post
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
    List ( Route, Post.Metadata )


data : DataSource Data
data =
    Post.metadatas


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


viewPostMetadata : ( Route, Post.Metadata ) -> Html Msg
viewPostMetadata ( route, info ) =
    div [ class "font-sans prose prose-xl text-pink" ]
        [ text <| info.title ++ " " ++ (info.published |> Date.format "dd MMM yyyy") ++ " " ++ viewTags info.tags
        ]


viewTags : List String -> String
viewTags =
    String.concat
