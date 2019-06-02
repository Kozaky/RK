defmodule RkBackendWeb.Router do
  use RkBackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
    plug Plugs.InjectDetect
  end

  # Other scopes may use custom stacks.
  scope "/" do
    pipe_through :api

    forward("/graphiql", Absinthe.Plug.GraphiQL, schema: RkBackendWeb.Schema, json_codec: Jason)
  end
end
