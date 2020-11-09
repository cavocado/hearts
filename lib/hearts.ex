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
    state = Setup.main(scores, roundNumber) |> Player.passCards()
    game(state)
  end

  def no_more_cards?([[[], [], [], []] | _rest]), do: true
  def no_more_cards?(_anything_else), do: false

  def score([_h, _t, _p, _i, _p1, _p2, _p3, _p4, score, _r, _ro]), do: score
  def roundNumber([_h, _t, _p, _i, _p1, _p2, _p3, _p4, _s, _r, roundNumber]), do: roundNumber

  def game(state) do
    newState = state |> Player.playCard() |> Rules.ruleCheck()
    if no_more_cards?(newState) do
      scores = score(newState)
      if endGame?(scores) do
        winningScore = Enum.min(scores)
        winner = whoWon?(scores, winningScore)
        IO.puts("Player #{winner + 1} won with a score of #{winningScore}!")
      else
        roundNumber = roundNumber(newState)
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
