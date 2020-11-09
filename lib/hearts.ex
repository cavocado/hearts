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
    state = Setup.main(scores, roundNumber)
      |> Player.passCards()
    game(state)
  end

  def game(state) do
    newState = state
    |> Player.playCard()
    |> Rules.ruleCheck()
    if newState == [[[], [], [], []], tricks, playedSoFar, isBroken, p1, p2, p3, p4, scores, roundNumber, true] do
      if endGame?(scores) do
        winningScore = Enum.min(scores)
        winner = whoWon?(scores, winningScore)
        IO.puts("Player #{winner + 1} won with a score of #{winningScore}!")
      else
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

  def whoWon?([winningScore, p2, p3, p4], winningScore), do: 0
  def whoWon?([p1, winningScore, p3, p4], winningScore), do: 1
  def whoWon?([p1, p2, winningScore, p4], winningScore), do: 2
  def whoWon?([p1, p2, p3, winningScore], winningScore), do: 3

end
