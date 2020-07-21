defmodule RumblWeb.UserView do
  use RumblWeb, :view
  alias Rumbl.Accounts

  def first_name(%Accounts.User{name: name}) do
    String.split(name, " ")
    |> Enum.at(0)
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, username: user.username}
  end
end
