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
    game = Repo.get(id)

    {
      :ok,
      socket
      |> assign_new(:session_uuid, fn -> session_uuid end)
      |> assign(:game, id)
      |> assign(:players, Repo.get_players(id))
      |> assign(:score, game.score)
      |> assign(:turn, game.turn)
      |> assign(:my_turn, nil)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center h-screen">
      <div class="flex flex-col items-center justify-center">
        <div class="flex flex-col items-center justify-center gap-5">
          <div class="flex items-center justify-center gap-2">
            <button
              phx-click="make_move"
              phx-value-move="rock"
              class={[
                "bg-gray-100 hover:bg-gray-200 text-white font-bold py-2 px-4 rounded-full",
                @my_turn == "rock" &&
                  "bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded-full"
              ]}
            >
              🪨
            </button>
            <button
              phx-click="make_move"
              phx-value-move="paper"
              class={[
                "bg-gray-100 hover:bg-gray-200 text-white font-bold py-2 px-4 rounded-full",
                @my_turn == "paper" &&
                  "bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded-full"
              ]}
            >
              📰
            </button>
            <button
              phx-click="make_move"
              phx-value-move="scissors"
              class={[
                "bg-gray-100 hover:bg-gray-200 text-white font-bold py-2 px-4 rounded-full",
                @my_turn == "scissors" &&
                  "bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded-full"
              ]}
            >
              ✂️
            </button>
          </div>

          <div class="flex flex-col items-center justify-center mt-4 text-center">
            <%= if length(@players) < 2 do %>
              <h1>Waiting for other player to join...</h1>
            <% end %>
            <%= if length(@players) == 2 do %>
              <div class="flex flex-row items-center justify-center gap-10">
                <div>
                  <h1>Your score: <%= @score[@session_uuid] %></h1>
                </div>
                <div>
                  <h1>Opponent score: <%= @score[Enum.find(@players, &(&1 != @session_uuid))] %></h1>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("make_move", %{"move" => move}, socket) do
    Repo.make_move(socket.assigns.game, socket.assigns.session_uuid, move)

    PubSub.broadcast(
      RockPaperEx.PubSub,
      "game:#{socket.assigns.game}",
      {:player_turn, socket.assigns.session_uuid, move}
    )

    turn = Repo.get_turn(socket.assigns.game)

    {:noreply,
     assign(socket,
       score: Repo.get_score(socket.assigns.game),
       turn: turn,
       my_turn:
         if turn == %{} do
           nil
         else
           move
         end
     )}
  end

  @impl true
  def handle_info({:player_joined, _player}, socket) do
    {:noreply, assign(socket, players: Repo.get_players(socket.assigns.game))}
  end

  def handle_info({:player_left, player}, socket) do
    Repo.leave_game(socket.assigns.game, player)
    {:noreply, assign(socket, players: Repo.get_players(socket.assigns.game))}
  end

  def handle_info({:player_turn, _player, _move}, socket) do
    turn = Repo.get_turn(socket.assigns.game)

    {:noreply,
     assign(socket,
       score: Repo.get_score(socket.assigns.game),
       my_turn:
         if turn == %{} do
           nil
         else
           socket.assigns.my_turn
         end
     )}
  end

  @impl true
  def terminate(_reason, socket) do
    PubSub.broadcast(
      RockPaperEx.PubSub,
      "game:#{socket.assigns.game}",
      {:player_left, socket.assigns.session_uuid}
    )

    Repo.leave_game(socket.assigns.game, socket.assigns.session_uuid)
  end
end
