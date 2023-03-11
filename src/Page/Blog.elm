module Page.Blog exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Date exposing (Date)
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes exposing (alt, attribute, checked, class, controls, disabled, for, height, href, id, method, name, placeholder, src, start, style, target, title, type_, value, width)
import Json.Decode exposing (Decoder)
import Page exposing (Page, PageWithState, StaticPayload)
import Domain.Post as Post
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
    List Post.Post


data : DataSource Data
data =
    Post.posts


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
    , body = List.map renderPostCard static.data
    }


renderPostCard : Post.Post -> Html Msg
renderPostCard post =
    let
        info = post.metadata
        url = post.route
    in
    div [ class "font-sans prose prose-xl text-orange" ]
        [ text <| info.title ++ " " ++ (info.published |> Date.format "dd MM yyyy")
        ]


renderTags : List String -> String
renderTags =
    String.concat
