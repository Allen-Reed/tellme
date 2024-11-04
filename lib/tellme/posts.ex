defmodule Tellme.Posts do
  alias Tellme.Repo
  alias Tellme.Posts.Post

  def save(post_params) do
    %Posts{}
    |> Post.changeset(post_params)
    |> Repo.insert()
  end

end
