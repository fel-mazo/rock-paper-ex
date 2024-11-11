defmodule RockPaperExWeb.GameLive do
  use RockPaperExWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :state, :waiting)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center h-screen">
      <div class="flex flex-col items-center justify-center">
        <div class="flex flex-col items-center justify-center">
          <h1 class="text-3xl font-bold text-center">🪨 📰 ✂️</h1>
          <div class="flex flex-col items-center justify-center mt-4">
            <button
              class="bg-gray-100 hover:bg-gray-200 text-white font-bold py-2 px-4 rounded-full"
              phx-click="play"
            >
              <div class="hover:animate-throw -rotate-90">
                <span>✊🏾</span>
              </div>
            </button>
            <h1><%= @state %></h1>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("play", _params, socket) do
    {:noreply, assign(socket, :state, :playing)}
  end
end
