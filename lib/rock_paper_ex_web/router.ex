defmodule RockPaperExWeb.Router do
  use RockPaperExWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RockPaperExWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_session_uuid
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RockPaperExWeb do
    pipe_through :browser
    live "/", NewGameLive
    live "/game/:game", GameLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", RockPaperExWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:rock_paper_ex, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RockPaperExWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp assign_session_uuid(conn, _opts) do
    case get_session(conn, :session_uuid) do
      nil ->
        put_session(conn, :session_uuid, UUID.uuid4())

      _uuid ->
        conn
    end
  end
end
