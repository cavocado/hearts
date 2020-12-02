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
  # Start game with Hearts.start([0, 0, 0, 0], 0)
  def start(scores, roundNumber) do
    board = Setup.main(scores, roundNumber) |> passingCards()
    pHands = board.hands
    twoClubs = twoClubs(pHands)
    nextPlayer = rem(twoClubs + 1, 4)
    followingPlayer = rem(nextPlayer + 1, 4)
    lastPlayer = rem(followingPlayer + 1, 4)
    newBoard = Board.changeP1(board, twoClubs) |> Board.changeP2(nextPlayer) |> Board.changeP3(followingPlayer) |> Board.changeP4(lastPlayer)
    game(newBoard)
  end

  def twoClubs([[{:club, :two} | _tail], _player2, _player3, _player4]), do: 0
  def twoClubs([_player1, [{:club, :two} | _tail], _player3, _player4]), do: 1
  def twoClubs([_player1, _player2, [{:club, :two} | _tail], _player4]), do: 2
  def twoClubs([_player1, _player2, _player3, [{:club, :two} | _tail]]), do: 3

  def passingCards(board) do
    roundNumber = board.roundNumber
    hands = board.hands
    type = cond do
      rem(roundNumber, 4) == 0 -> "left"
      rem(roundNumber, 4) == 1 -> "right"
      rem(roundNumber, 4) == 2 -> "across"
      rem(roundNumber, 4) == 3 -> "hold"
    end
    if type == "hold" do
      board
    else
      [p1c1, p1c2, p1c3] = Player.passCards(board)
      [p2c1, p2c2, p2c3] = Computer.pickPassingCards(board, 1)
      [p3c1, p3c2, p3c3] = Computer.pickPassingCards(board, 2)
      [p4c1, p4c2, p4c3] = Computer.pickPassingCards(board, 3)
      newHands = removePassingCards(hands, p1c1, p1c2, p1c3, 0)
        |> removePassingCards(p2c1, p2c2, p2c3, 1)
        |> removePassingCards(p3c1, p3c2, p3c3, 2)
        |> removePassingCards(p4c1, p4c2, p4c3, 3)
      finalHands = addPassingCards(newHands, type, [p1c1, p1c2, p1c3], [p2c1, p2c2, p2c3], [p3c1, p3c2, p3c3], [p4c1, p4c2, p4c3])
      sortedHands = Enum.map(finalHands, fn x -> Setup.sortCards(x) end)
      Board.changeH(board, sortedHands)
    end
  end

  def addPassingCards([p1, p2, p3, p4], "left", fromP1, fromP2, fromP3, fromP4) do
    [p1 ++ fromP2, p2 ++ fromP3, p3 ++ fromP4, p4 ++ fromP1]
  end

  def addPassingCards([p1, p2, p3, p4], "right", fromP1, fromP2, fromP3, fromP4) do
    [p1 ++ fromP4, p2 ++ fromP1, p3 ++ fromP2, p4 ++ fromP3]
  end

  def addPassingCards([p1, p2, p3, p4], "across", fromP1, fromP2, fromP3, fromP4) do
    [p1 ++ fromP3, p2 ++ fromP4, p3 ++ fromP1, p4 ++ fromP2]
  end

  def removePassingCards([p1, p2, p3, p4], card1, card2, card3, player) do
    cond do
      player == 0 -> [p1 |> List.delete(card1) |> List.delete(card2) |> List.delete(card3), p2, p3, p4]
      player == 1 -> [p1, p2 |> List.delete(card1) |> List.delete(card2) |> List.delete(card3), p3, p4]
      player == 2 -> [p1, p2, p3 |> List.delete(card1) |> List.delete(card2) |> List.delete(card3), p4]
      player == 3 -> [p1, p2, p3, p4 |> List.delete(card1) |> List.delete(card2) |> List.delete(card3)]
    end
  end

  def no_more_cards?([[], [], [], []]), do: true
  def no_more_cards?(_anything_else), do: false

  def game(state) do
    p1 = state.p1
    nextState = if p1 == 0 do
      Player.playCard(state)
    else
      Computer.pickCard(state)
    end
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
