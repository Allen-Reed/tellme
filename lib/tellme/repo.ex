defmodule Tellme.Repo do
  use Ecto.Repo,
    otp_app: :tellme,
    adapter: Ecto.Adapters.Postgres
end
