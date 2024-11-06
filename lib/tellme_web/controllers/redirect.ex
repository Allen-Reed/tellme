defmodule TellmeWeb.RedirectController do
  use TellmeWeb, :controller

  def redirect_to_home(conn, _params) do
    redirect(conn, to: Routes.home_live_path(conn, :index))
  end
end
