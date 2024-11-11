defmodule RockPaperExWeb.GameLive do
  use RockPaperExWeb, :live_view

  alias RockPaperEx.Repo
  alias Phoenix.PubSub

  @impl true
  def mount(%{"game" => id}, %{"session_uuid" => session_uuid}, socket) do
    :ok = PubSub.subscribe(RockPaperEx.PubSub, "game:#{id}")

    case Repo.join_game(id, session_uuid) do
      :ok -> PubSub.broadcast(RockPaperEx.PubSub, "game:#{id}", {:player_joined, session_uuid})
      :error -> nil
    end

    # else spectate ?

    IO.inspect(Repo.get_players(id))

    {
      :ok,
      socket
      |> assign_new(:session_uuid, fn -> session_uuid end)
      |> assign(:game, id)
      |> assign(:players, Repo.get_players(id))
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center h-screen">
      <div class="flex flex-col items-center justify-center">
        <div>toto</div>
        <div class="flex flex-col items-center justify-center">
          <div class="flex items-center justify-center gap-2">
            <button class="bg-gray-100 hover:bg-gray-200 text-white font-bold py-2 px-4 rounded-full">
              🪨
            </button>
            <button class="bg-gray-100 hover:bg-gray-200 text-white font-bold py-2 px-4 rounded-full">
              📰
            </button>
            <buuton class="bg-gray-100 hover:bg-gray-200 text-white font-bold py-2 px-4 rounded-full">
              ✂️
            </buuton>
          </div>
          <div class="flex flex-col items-center justify-center mt-4">
            <h1>Session ID: <%= @session_uuid %></h1>
            <div class="flex flex-col items-center justify-center mt-4">
              <%= for player <- @players do %>
                <h1>Player: <%= player %></h1>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_info({:player_joined, _player}, socket) do
    {:noreply, assign(socket, players: Repo.get_players(socket.assigns.game))}
  end

  def handle_info({:player_left, player}, socket) do
    Repo.leave_game(socket.assigns.game, player)
    {:noreply, assign(socket, players: Repo.get_players(socket.assigns.game))}
  end

  @impl true
  def terminate(reason, socket) do
    PubSub.broadcast(
      RockPaperEx.PubSub,
      "game:#{socket.assigns.game}",
      {:player_left, socket.assigns.session_uuid}
    )

    Repo.leave_game(socket.assigns.game, socket.assigns.session_uuid)
  end
end
