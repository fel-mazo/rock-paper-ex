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
    defstruct [:players, :score, :turn]
  end

  def update_game(id, f) do
    Agent.update(__MODULE__, fn state ->
      Map.update(state, id, %Game{players: MapSet.new(), score: %{}, turn: %{}}, f)
    end)
  end

  def create_game(first_player) do
    id = UUID.uuid4()

    :ok =
      update_game(id, fn game ->
        %Game{
          game
          | players: MapSet.put(game.players, first_player),
            score: %{first_player => 0},
            turn: %{}
        }
      end)

    id
  end

  def join_game(id, player) do
    %Game{players: players} = get(id)

    if MapSet.size(players) < 2 do
      update_game(id, fn game ->
        %Game{game | players: MapSet.put(players, player), score: Map.put(game.score, player, 0)}
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

  def get_score(id) do
    case get(id) do
      nil ->
        %{}

      game ->
        game.score
    end
  end

  def get_turn(id) do
    case get(id) do
      nil ->
        %{}

      game ->
        game.turn
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

  def compare_moves(a, b) do
    case {a, b} do
      {"rock", "scissors"} -> 1
      {"scissors", "paper"} -> 1
      {"paper", "rock"} -> 1
      _ -> 0
    end
  end

  def make_move(id, player, move) do
    update_game(id, fn game ->
      turn = Map.put(game.turn, player, move)

      if map_size(turn) == 2 do
        other_player = Enum.find(Map.keys(turn), &(&1 != player))
        other_move = Map.get(turn, other_player)

        player_turn_score = compare_moves(move, other_move)
        other_turn_score = compare_moves(other_move, move)

        %Game{
          game
          | turn: %{},
            score:
              game.score
              |> Map.update(player, player_turn_score, &(&1 + player_turn_score))
              |> Map.update(other_player, other_turn_score, &(&1 + other_turn_score))
        }
      else
        %Game{game | turn: turn}
      end
    end)
  end
end
