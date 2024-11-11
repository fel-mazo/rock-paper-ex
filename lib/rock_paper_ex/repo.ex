defmodule RockPaperEx.Repo do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, fn state -> Map.get(state, key) end)
  end

  def put(key, value) do
    Agent.update(__MODULE__, fn state -> Map.put(state, key, value) end)
  end

  defmodule Game do
    defstruct [:players, :outcome]
  end

  def update_game(id, f) do
    Agent.update(__MODULE__, fn state ->
      Map.update(state, id, %Game{players: MapSet.new()}, f)
    end)
  end

  def create_game(first_player) do
    id = UUID.uuid4()

    :ok =
      update_game(id, fn game ->
        %Game{game | players: MapSet.put(game.players, first_player)}
      end)

    id
  end

  def join_game(id, player) do
    %Game{players: players} = get(id)

    if MapSet.size(players) < 2 do
      update_game(id, fn game ->
        %Game{game | players: MapSet.put(players, player)}
      end)

      :ok
    else
      :error
    end
  end

  def leave_game(id, player) do
    update_game(id, fn game ->
      %Game{game | players: MapSet.delete(game.players, player)}
    end)
  end

  def get_players(id) do
    case get(id) do
      nil ->
        []

      game ->
        MapSet.to_list(game.players)
    end
  end

  def number_of_players(id) do
    case get(id) do
      nil ->
        0

      game ->
        MapSet.size(game.players)
    end
  end
end
