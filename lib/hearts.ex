defmodule Hearts do
  @moduledoc """
  Documentation for Hearts.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Hearts.hello()
      :world

  """
  # Start game with start([0, 0, 0, 0], 0)
  def start(scores, roundNumber) do
    board = Setup.main(scores, roundNumber) |> Player.passCards()
    pHands = board.hands
    twoClubs = twoClubs(pHands)
    nextPlayer = rem(twoClubs + 1, 4)
    followingPlayer = rem(nextPlayer + 1, 4)
    lastPlayer = rem(followingPlayer + 1, 4)
    newBoard = Board.changeP1(board, twoClubs) |> Board.changeP2(nextPlayer) |> Board.changeP3(followingPlayer) |> Board.changeP4(lastPlayer)
    game(newBoard)
  end

  defp twoClubs([[{:club, :two} | _tail], _player2, _player3, _player4]), do: 0
  defp twoClubs([_player1, [{:club, :two} | _tail], _player3, _player4]), do: 1
  defp twoClubs([_player1, _player2, [{:club, :two} | _tail], _player4]), do: 2
  defp twoClubs([_player1, _player2, _player3, [{:club, :two} | _tail]]), do: 3

  def no_more_cards?([[], [], [], []]), do: true
  def no_more_cards?(_anything_else), do: false

  def game(state) do
    nextState = Player.playCard(state)
    newState = Rules.ruleCheck(nextState)
    if no_more_cards?(newState.hands) do
      scores = newState.scores
      if endGame?(scores) do
        winningScore = Enum.min(scores)
        winner = whoWon?(scores, winningScore)
        IO.puts("Player #{winner + 1} won with a score of #{winningScore}!")
      else
        roundNumber = newState.roundNumber
        start(scores, roundNumber + 1)
      end
    else
      game(newState)
    end
  end

  def endGame?(scores) do
    cond do
      Enum.count(scores, fn x -> x >= 100 end) > 0 -> true
      true -> false
    end
  end

  def whoWon?([winningScore, _p2, _p3, _p4], winningScore), do: 0
  def whoWon?([_p1, winningScore, _p3, _p4], winningScore), do: 1
  def whoWon?([_p1, _p2, winningScore, _p4], winningScore), do: 2
  def whoWon?([_p1, _p2, _p3, winningScore], winningScore), do: 3

end
