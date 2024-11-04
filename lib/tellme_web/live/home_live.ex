defmodule TellmeWeb.HomeLive do
  use TellmeWeb, :live_view

  @impl truedef render(assigns) do
    ~H"""

    """

    @impl true
    def mount(_params, _session, socket) do
      {:ok, socket}
    end
  end
end
