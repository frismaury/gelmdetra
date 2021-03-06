module Behavior exposing (..)

import Models exposing (AppModel)
import Msgs exposing (Msg(..))
import Routing exposing (parseLocation)
import Models.User exposing (User)


update : Msg -> AppModel -> ( AppModel, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        Redirect ->
            model ! []

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                { model | route = newRoute } ! []

        OnFetchUsers (Ok listUsers) ->
            let
                oldUsersModule =
                    model.usersModule

                updateUsersModule =
                    { oldUsersModule | userList = listUsers }
            in
                { model | usersModule = updateUsersModule } ! []

        OnFetchUsers (Err err) ->
            { model | error = toString err } ! []
