defmodule RockPaperExWeb.NewGameLive do
  use RockPaperExWeb, :live_view

  alias RockPaperEx.Repo

  @impl true
  def mount(_params, %{"session_uuid" => session_uuid}, socket) do
    {:ok, assign(socket, :session_uuid, session_uuid)}
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
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("play", _params, socket) do
    id = Repo.create_game(socket.assigns.session_uuid)

    {:noreply, push_navigate(socket, to: ~p"/game/#{id}")}
  end
end
