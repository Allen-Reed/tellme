defmodule TellmeWeb.HomeLive do
  use TellmeWeb, :live_view

  alias Tellme.Posts
  alias Tellme.Posts.Post

  @impl true
  def render(%{loading: true} = assigns) do
    ~H"""
    <div class="text-white">Loading up...</div>
    """
  end

  def render(assigns) do
    ~H"""

    <div class="flex justify-center mb-4">
    <.button type="button" class="w-1/3 bg-[#8200ff]" phx-click={show_modal("new-post-modal")}>New Tell 🔥</.button>
    </div>
    <div id="feed" phx-update="stream" class="flex flex-col gap-2">
      <div
        :for={{dom_id, post} <- @streams.posts}
        id={dom_id}
        class="w-[99%] mx-auto flex flex-col gap-2 p-4 border rounded bg-white"
      >
        <img src={post.image_path} />
        <p class="text-[#8200ff]"><%= post.user.email %></p>
        <p class="text-2xl"><%= post.caption %></p>
      </div>
    </div>

    <.modal id="new-post-modal">
      <.simple_form for={@form} phx-change="validate" phx-submit="save-post">
        <.live_file_input upload={@uploads.image} required />
        <.input field={@form[:caption]} type="textarea" label="Caption" required />

        <.button type="submit" phx-disable-with="Saving...">Create Post</.button>
      </.simple_form>
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Tellme.PubSub, "posts")

      form =
        %Post{}
        |> Post.changeset(%{})
        |> to_form(as: "post")

      socket =
        socket
        |> assign(form: form, loading: false)
        |> allow_upload(:image, accept: ~w(.png .jpg), max_entries: 1)
        |> stream(:posts, Posts.list_posts())

      {:ok, socket}
    else
      {:ok, assign(socket, loading: true)}
    end
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save-post", %{"post" => post_params}, socket) do
    %{current_user: user} = socket.assigns

    post_params
    |> Map.put("user_id", user.id)
    |> Map.put("image_path", List.first(consume_files(socket)))
    |> Posts.save()
    |> case do
      {:ok, post} ->
        # Debugging line
        IO.puts("Post saved successfully!")

        socket =
          socket
          |> put_flash(:info, "Post created successfully!")
          |> stream_insert(:posts, post)
          |> push_navigate(to: ~p"/home")

        Phoenix.PubSub.broadcast(Tellme.PubSub, "posts", {:new, Map.put(post, :user, user)})

        {:noreply, socket}

      {:error, changeset} ->
        IO.puts("Post failed to save")
        IO.inspect(changeset)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:new, post}, socket) do
    socket =
      socket
      |> put_flash(:info, "#{post.user.email} just posted!")
      |> stream_insert(:posts, post, at: 0)

    {:noreply, socket}
  end

  defp consume_files(socket) do
    consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
      dest = Path.join([:code.priv_dir(:tellme), "static", "uploads", Path.basename(path)])

      File.cp!(path, dest)

      {:postpone, ~p"/uploads/#{Path.basename(dest)}"}
    end)
  end
end
