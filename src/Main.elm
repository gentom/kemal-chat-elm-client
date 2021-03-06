module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket
import List


main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags =
    { websocketHost : String }



-- MODEL


type alias Model =
    { chatMessages : List String
    , userMessage : String
    , username : String
    , usernameSelected : Bool
    , websocketHost : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model [] "" "" False flags.websocketHost
    , Cmd.none
    )



-- UPDATE


{-
let message = model.userMessage で message変数にチャットメッセージを格納している
次に in { model | userMessage = ""} で userMessageを空文字列に置き換えている。だから、message変数にチャットメッセージを
格納しておく必要がある。
Websocket.send "ws://0.0.0.0:3000/chat" message でKemalサーバーにユーザーのチャットメッセージを送信している
-}

type Msg
    = PostChatMessage
    | UpdateUserMessage String
    | NewChatMessage String
    | UpdateUsername String
    | SelectUsername


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PostChatMessage ->
            let
                message =
                    model.userMessage

                username =
                    model.username

                host =
                    model.websocketHost
            in
                { model | userMessage = "" } ! [ submitChatMessage username message host ]

        UpdateUserMessage message ->
            { model | userMessage = message } ! []

        NewChatMessage message ->
            let
                messages =
                    message :: model.chatMessages
            in
                { model | chatMessages = messages } ! []

        UpdateUsername username ->
            { model | username = username } ! []

        SelectUsername ->
            { model | usernameSelected = True } ! []



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h3 [] [ text "Awesome Chat Room" ]
        , viewSelect model
        ]


viewSelect : Model -> Html Msg
viewSelect model =
    if model.usernameSelected then
        chatView model
    else
        enterNameView model


enterNameView : Model -> Html Msg
enterNameView model =
    div []
        [ label [] [ text "Enter your username for this chat" ]
        , input
            [ autofocus True
            , value model.username
            , onInput UpdateUsername
            , class "u-full-width"
            , type_ "text"
            ]
            []
        , button
            [ onClick SelectUsername
            , class "button-primary"
            ]
            [ text "Submit" ]
        ]


chatView : Model -> Html Msg
chatView model =
    div []
        [ input
            [ placeholder "say something..."
            , autofocus True
            , value model.userMessage
            , onInput UpdateUserMessage
            , type_ "text"
            , style [ ( "margin-right", "0.5em" ) ]
            ]
            []
        , button
            [ onClick PostChatMessage
            , class "button-primary"
            ]
            [ text "Submit" ]
        , displayChatMessages model.chatMessages
        ]


displayChatMessages : List String -> Html a
displayChatMessages chatMessages =
    div [] (List.map (\x -> div [] [ text x ]) chatMessages)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen model.websocketHost NewChatMessage



-- HELPERS


submitChatMessage : String -> String -> String -> Cmd Msg
submitChatMessage username message websocketHost =
    WebSocket.send websocketHost (username ++ ": " ++ message)
