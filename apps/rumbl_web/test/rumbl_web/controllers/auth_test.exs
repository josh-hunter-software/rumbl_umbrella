defmodule RumblWeb.AuthTest do
  use RumblWeb.ConnCase, async: true
  alias RumblWeb.Auth
  setup %{conn: conn} do
    conn =
      bypass_through(conn, RumblWeb.Router, :browser)
      # ^ passes router and browser pipeline to invoke and sets up conn with flash etc
      |> get("/")
    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])

    assert conn.halted
  end

  test "authenticate_user for existing current_user", %{conn: conn} do
    conn =
      assign(conn, :current_user, %Rumbl.Accounts.User{})
      |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn =
      Auth.login(conn, %Rumbl.Accounts.User{id: 123})
      |> send_resp(:ok, "")

    next_conn = get(login_conn, "/")
    assert 123 = get_session(next_conn, :user_id)
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      put_session(conn, :user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn = get(logout_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = user()
    conn =
      put_session(conn, :user_id, user.id)
      |> Auth.call(Auth.init([]))
    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Auth.init([]))
    assert conn.assigns.current_user == nil
  end
end
