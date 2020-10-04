defmodule Rules do

  def ruleCheck([hands, tricks, playedSoFar, isBroken, 1p, 2p, 3p, 4p, scores]) do

  end

  def everyonePlayed([first, second, third, fourth]), do: largestCard(first, second, third, fourth)
  def everyonePlayed(playedCards), do: false

  def okSuit(hands, [{suit, number} | tail], [_first, second, third, fourth], isBroken) do
    correctSuit = suit
    size = Enum.count(tail) + 1
    cond do
      size == 2 -> player = second
      size == 3 -> player = third
      size == 4 -> player = fourth
    end
    # Find the right hand
    {qSuit, qNumber} = List.last(tail)
    cond do
      suit == qSuit -> true
      haveSuit(hand, suit) -> false
      qSuit != :heart -> true
      heartsOk(hand, [{suit, number} | tail], isBroken) -> true
      _ -> false
    end
  end

  def haveSuit(hand, suit) do
    cond do
      Enum.count(hand, fn x -> x != {suit, _} end) == 0 -> false
      _ -> true
    end
  end

  def heartsOk(hand, [{suit, number} | _tail], isBroken) do
    cond do
      isBroken -> true
      Enum.count(hand, fn x -> x != {:heart, _} end) == 0 -> true
      haveSuit(hand, suit) == false -> true
      _ -> false
    end
  end

  def largestCard([1c, 2c, 3c, 4c]) do
    ##return the largest card
  end

  def playerWithHighCard(bigCard, [bigCard | _tail], [player | _tail]), do: player
  def playerWithHighCard(bigCard, [_1c, bigCard, _3c, _4c], [_1p, player, _3p, _4p]), do: player
  def playerWithHighCard(bigCard, [_1c, _2c, bigCard, _4c], [_1p, _2p, player, _4p]), do: player
  def playerWithHighCard(bigCard, [_1c, _2c, _3c, bigCard], [_1p, _2p, _3p, player]), do: player

  def wonTrick(highCard, playerHC, [hands, tricks, playedSoFar, isBroken, _1p, _2p, _3p, _4p, scores]) do

  end

  def noCardsLeft([[],[],[],[]], tricks, [p1Score, p2Score, p3Score, p4Score]) do
    [newP1, newP2, newP3, newP4] = countHearts(tricks)
    [queen1, queen2, queen3, queen4] = coutQueen(tricks)
    newScores = [p1Score + newP1 + queen1, p2Score + newP2 + queen2, p3Score + newP3 + queen3, p4Score + newP4 + queen4]
    # If one person got all
    [newScores, Enum.map(newScores, fn x -> x >= 100 end)]
  end

  def noCardsLeft(_hands, _tricks, _score), do: false

  def countHearts(tricks) do
    Enum.map(tricks, fn x -> Enum.count(x, fn y -> y == {:heart, _} end) end)
  end

  def countQueen(tricks) do
    [p1, p2, p3, p4] = Enum.map(tricks, fn x -> Enum.count(x, fn y -> y == {:spade, :queen} end) end)
    cond do
      p1 == 1 -> [13, 0, 0, 0]
      p2 == 1 -> [0, 13, 0, 0]
      p3 == 1 -> [0, 0, 13, 0]
      p4 == 1 -> [0, 0, 0, 13]
    end
  end

end
