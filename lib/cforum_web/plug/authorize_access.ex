defmodule CforumWeb.Plug.AuthorizeAccess do
  @moduledoc """
  This plug is pluggable in controllers for authorizing actions based on our
  Abilities module. It constructs a path by the controller name and then calls
  `Abilities.may?(mod, action)`

  ## Examples

      # Authorize access to all actions
      plug AuthorizeAccess

      # Authorize acess only for some actions:
      plug AuthorizeAccess, only: [:new, :create]
  """
  import CforumWeb.Router.Helpers
  import CforumWeb.Gettext
  alias Cforum.Abilities

  def init(opts), do: opts

  def call(conn, opts) do
    path = Cforum.Helpers.controller_path(conn)
    action = Phoenix.Controller.action_name(conn)

    if Abilities.may?(conn, path, action) do
      conn
    else
      if Mix.env() == :dev, do: raise("Authorization required")

      conn
      |> Phoenix.Controller.put_flash(:error, gettext("You don't have access to this page!"))
      |> Plug.Conn.put_status(403)
      |> Phoenix.Controller.redirect(to: session_path(conn, :new))
      |> Plug.Conn.halt()
    end
  end
end
