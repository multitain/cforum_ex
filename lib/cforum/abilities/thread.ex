defmodule Cforum.Abilities.Thread do
  defmacro __using__(_opts) do
    quote do
      # TODO implement proper rights
      def may?(conn, "thread", _, _), do: access_forum?(conn.assigns[:current_user], conn.assigns[:current_forum])
      def may?(conn, "threads/invisible", _, _), do: signed_in?(conn)
      def may?(conn, "threads/open_close", _, _), do: signed_in?(conn)
    end
  end
end
