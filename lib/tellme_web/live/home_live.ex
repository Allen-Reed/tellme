defmodule TellmeWeb.HomeLive do
  use TellmeWeb, :live_view

  alias Tellme.Posts
  alias Tellme.Posts.Post

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="text-2xl">Feed</h1>
    <.button type="button" phx-click={show_modal("new-post-modal")}>New Post</.button>

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
    form =
      %Post{}
      |> Post.changeset(%{})
      |> to_form(as: "post")

    socket =
      socket
      |> assign(form: form)
      |> allow_upload(:image, accept: ~w(.png .jpg), max_entries: 1)

    {:ok, socket}
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
    |> Map.put("image_path", List.first(handle_event(socket)))
    |> Posts.save()
    |> case do
      {:ok, _post} ->
        socket =
          socket
          |> put_flash(:info, "Post created successfully!")
          |> push_navigate(to: ~p"/home")
        {:noreply, socket}


      {:error, _changeset}
        {:noreply, socket}
    end

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        dest = Path.join(Application.app_dir(:tellme, "priv/static/uploads"), Path.basename(path))
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end
end
