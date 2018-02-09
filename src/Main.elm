import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket
import List

main: Program Never
main =
  Html.program
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }



 -- MODEL

type alias Model =
  { chatMessages : List String,
    userMessage : String
  }

init : (Model, Cmd Msg)
init =
  ( Model [] ""
  , Cmd.none
  )



-- UPDATE

type Msg
  = PostChatMessage
  | UpdateUserMessage String
  | NewChatMessage String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PostChatMessage ->
      let
        message = model.userMessage
      in
        { model | userMessage = "" } ! [WebSocket.send "ws://0.0.0.0:3000/chat" message]

    UpdateUserMessage message ->
      { model | userMessage = message } ! []

    NewChatMessage message  ->
      let
        messages = message :: model.chatMessages
      in
        { model | chatMessages = messages } ! []



-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ input [ placeholder "message..."
            , autofocus True
            , value model.userMessage
            , onInput UpdateUserMessage
            ] []
    , button [ onClick PostChatMessage ] [ text "Submit" ]
    , displayChatMessages model.chatMessages
  ]

displayChatMessages : List String -> Html a
displayChatMessages chatMessages =
  div [] (List.map ( \x -> div [] [ text x ] ) chatMessages)



 -- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://0.0.0.0:3000/chat" NewChatMessage
