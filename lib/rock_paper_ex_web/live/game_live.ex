defmodule RockPaperExWeb.GameLive do
  use RockPaperExWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center h-screen">
      <div class="flex flex-col items-center justify-center">
        <div class="flex flex-col items-center justify-center">
          <h1 class="text-3xl font-bold text-center">Rock Paper Scissors</h1>
          <div class="flex flex-col items-center justify-center mt-4">
            <button
              class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-full"
              phx-click="play"
            >
              Play
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
