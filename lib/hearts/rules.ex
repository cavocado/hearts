defmodule Rules do

  def ruleCheck([hands, tricks, playedSoFar, isBroken, 1p, 2p, 3p, 4p, scores, roundNumber, roundOver]) do
    sizePlayedSoFar = Enum.count(playedSoFar)
    cond do
      sizePlayedSoFar > 1 -> fineSuit = okSuit(hands, playedSoFar, [1p, 2p, 3p, 4p], isBroken)
      sizePlayedSoFar = 1 -> fineSuit = heartsOk(findHand(1, hands), playedSoFar, isBroken)
    end
    # handle if a suit was not ok to play
    cond do
      sizePlayedSoFar = 4 -> bigCard = largestCard(playedSoFar)
      _ -> [hands, tricks, playedSoFar, isBroken, 2p, 3p, 4p, 1p, scores, roundNumber, false]
    end
    whichPlayer = playerWithHighCard(bigCard, playedSoFar, [1p, 2p, 3p, 4p])
    secPlayer = (whichPlayer + 1) % 4 + 1
    thrPlayer = (whichPlayer + 2) % 4 + 1
    forPlayer = (whichPlayer + 3) % 4 + 1
    newTricks = wonTrick(bigCard, whichPlayer, tricks, playedSoFar)
    cond do
      hands == [[],[],[],[]] -> [hands, tricks, [], isBroken, whichPlayer, secPlayer, thrPlayer, forPlayer, newScores(tricks, scores), roundNumber, true]
      _ -> [hands, tricks, [], isBroken, whichPlayer, secPlayer, thrPlayer, forPlayer, scores, roundNumber, false]
    end
  end

  def okSuit(hands, [{suit, number} | tail], [_first, second, third, fourth], isBroken) do
    correctSuit = suit
    size = Enum.count(tail) + 1
    cond do
      size == 2 -> player = second
      size == 3 -> player = third
      size == 4 -> player = fourth
    end
    hand = findHand(player, hands)
    {qSuit, qNumber} = List.last(tail)
    cond do
      suit == qSuit -> true
      haveSuit(hand, suit) -> false
      qSuit != :heart -> true
      heartsOk(hand, [{suit, number} | tail], isBroken) -> true
      _ -> false
    end
  end

  def findHand(1, [p1Hand, _p2Hand, _p3Hand, _p4Hand]) do: p1Hand
  def findHand(2, [_p1Hand, p2Hand, _p3Hand, _p4Hand]) do: p2Hand
  def findHand(3, [_p1Hand, _p2Hand, p3Hand, _p4Hand]) do: p3Hand
  def findHand(4, [_p1Hand, _p2Hand, _p3Hand, p4Hand]) do: p4Hand

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

  def largestCard([{1suit, 1number}, {2suit, 2number}, {3suit, 3number}, {4suit, 4number}]) do
    suit = 1suit
    # work on this
  end

  def playerWithHighCard(bigCard, [bigCard | _tail], [player | _tail]), do: player
  def playerWithHighCard(bigCard, [_1c, bigCard, _3c, _4c], [_1p, player, _3p, _4p]), do: player
  def playerWithHighCard(bigCard, [_1c, _2c, bigCard, _4c], [_1p, _2p, player, _4p]), do: player
  def playerWithHighCard(bigCard, [_1c, _2c, _3c, bigCard], [_1p, _2p, _3p, player]), do: player

  def wonTrick(highCard, playerHC, [p1, p2, p3, p4], playedSoFar) do
    cond do
      playerHC == 1 -> [p1 ++ playedSoFar, p2, p3, p4]
      playerHC == 2 -> [p1, p2 ++ playedSoFar, p3, p4]
      playerHC == 3 -> [p1, p2, p3 ++ playedSoFar, p4]
      playerHC == 4 -> [p1, p2, p3, p4 ++ playedSoFar]
    end
  end

  def newScores(tricks, [p1Score, p2Score, p3Score, p4Score]) do
    [newP1, newP2, newP3, newP4] = countHearts(tricks)
    [queen1, queen2, queen3, queen4] = countQueen(tricks)
    cond do
      newP1 + queen1 == 26 -> [p1Score, p2Score + 26, p3Score + 26, p4Score + 26]
      newP2 + queen2 == 26 -> [p1Score + 26, p2Score, p3Score + 26, p4Score + 26]
      newP3 + queen3 == 26 -> [p1Score + 26, p2Score + 26, p3Score, p4Score + 25]
      newP4 + queen4 == 26 -> [p1Score + 26, p2Score + 26, p3Score + 26, p4Score]
      _ -> [p1Score + newP1 + queen1, p2Score + newP2 + queen2, p3Score + newP3 + queen3, p4Score + newP4 + queen4]
    end
  end

  # move endGame to file running the whole game
  def endGame?(scores) do
    cond do
      Enum.count(scores, fn x -> x >= 100 end) > 0 -> true
      _ -> false
    end
  end

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
