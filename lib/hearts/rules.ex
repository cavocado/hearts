defmodule Rules do

  def ruleCheck([hands, tricks, playedSoFar, isBroken, p1, p2, p3, p4, scores, roundNumber, roundOver]) do
    sizePlayedSoFar = Enum.count(playedSoFar)
    {fineSuit, newIsBroken} = cond do
      sizePlayedSoFar > 1 -> okSuit(hands, playedSoFar, [p1, p2, p3, p4], isBroken)
      sizePlayedSoFar == 1 -> heartsOk(findHand(1, hands), playedSoFar, isBroken)
      sizePlayedSoFar < 1 -> {true, isBroken}
    end
    if not fineSuit do
      newHands = addCard(hands, List.last(playedSoFar), p1)
      [newHands, tricks, Enum.drop(playedSoFar, -1), isBroken, p1, p2, p3, p4, scores, roundNumber, roundOver]
    else
      if sizePlayedSoFar < 4 do
        [hands, tricks, playedSoFar, newIsBroken, p2, p3, p4, p1, scores, roundNumber, false]
      else
        bigCard = largestCard(playedSoFar)
        whichPlayer = playerWithHighCard(bigCard, playedSoFar, [p1, p2, p3, p4])
        secPlayer = rem(whichPlayer + 1, 4)
        thrPlayer = rem(whichPlayer + 2, 4)
        forPlayer = rem(whichPlayer + 3, 4)
        newTricks = wonTrick(whichPlayer, tricks, playedSoFar)
        if hands == [[],[],[],[]] do
          [hands, newTricks, [], newIsBroken, whichPlayer, secPlayer, thrPlayer, forPlayer, newScores(tricks, scores), roundNumber, true]
        else
          [hands, newTricks, [], newIsBroken, whichPlayer, secPlayer, thrPlayer, forPlayer, scores, roundNumber, false]
        end
      end
    end
  end

  def addCard([p1, p2, p3, p4], card, player) do
    cond do
      player == 1 -> [p1 ++ card, p2, p3, p4]
      player == 2 -> [p1, p2 ++ card, p3, p4]
      player == 3 -> [p1, p2, p3 ++ card, p4]
      player == 4 -> [p1, p2, p3, p4 ++ card]
    end
  end

  def okSuit(hands, [{suit, number} | tail], [_first, second, third, fourth], isBroken) do
    size = Enum.count(tail) + 1
    player = cond do
      size == 2 -> second
      size == 3 -> third
      size == 4 -> fourth
    end
    hand = findHand(player, hands)
    {qSuit, _qNumber} = List.last(tail)
    cond do
      suit == qSuit -> {true, isBroken}
      haveSuit(hand, suit) -> {false, isBroken}
      qSuit != :heart -> {true, isBroken}
      heartsOk(hand, [{suit, number} | tail], isBroken) == {true, true} -> {true, true}
      true -> {false, isBroken}
    end
  end

  def findHand(0, [p1Hand, _p2Hand, _p3Hand, _p4Hand]), do: p1Hand
  def findHand(1, [_p1Hand, p2Hand, _p3Hand, _p4Hand]), do: p2Hand
  def findHand(2, [_p1Hand, _p2Hand, p3Hand, _p4Hand]), do: p3Hand
  def findHand(3, [_p1Hand, _p2Hand, _p3Hand, p4Hand]), do: p4Hand

  def haveSuit(hand, suit) do
    cond do
      Enum.count(hand, fn {x, _y} -> x != suit end) == 0 -> false
      true -> true
    end
  end

  def heartsOk(hand, [{suit, _number} | _tail], isBroken) do
    cond do
      isBroken -> {true, true}
      Enum.count(hand, fn {x, _y} -> x != :heart end) == 0 -> {true, true}
      haveSuit(hand, suit) == false -> {true, true}
      true -> {false, false}
    end
  end

  def largestCard([{suit1, number1}, {suit2, number2}, {suit3, number3}, {suit4, number4}]) do
    suit = suit1
    numbers = Enum.map([{suit1, number1}, {suit2, number2}, {suit3, number3}, {suit4, number4}], fn {x, y} -> checkSuit(x, y, suit) end)
    correspondingNumbers = Enum.map(numbers, fn a -> getNumber(a) end)
    greatest = Enum.max(correspondingNumbers)
    {suit, getAtom(greatest)}
  end

  def getNumber({_x, y}) do
    map = %{:zero => 0, :two => 2, :three => 3, :four => 4, :five => 5, :six => 6, :seven => 7, :eight => 8, :nine => 9, :ten => 10, :jack => 11, :queen => 12, :king => 13, :ace => 14}
    {:ok, num} = Map.fetch(map, y)
    num
  end

  def getAtom(num) do
    map2 = %{0 => :zero, 2 => :two, 3 => :three, 4 => :four, 5 => :five, 6 => :six, 7 => :seven, 8 => :eight, 9 => :nine, 10 => :ten, 11 => :jack, 12 => :queen, 13 => :king, 14 => :ace}
    {:ok, atom} = Map.fetch(map2, num)
    atom
  end

  def checkSuit(suit, number, actualSuit) do
    cond do
      suit == actualSuit -> number
      true -> :zero
    end
  end

  def playerWithHighCard(bigCard, [bigCard | _tail], [player | _tail1]), do: player
  def playerWithHighCard(bigCard, [_1c, bigCard, _3c, _4c], [_p1, player, _p3, _p4]), do: player
  def playerWithHighCard(bigCard, [_1c, _2c, bigCard, _4c], [_p1, _p2, player, _p4]), do: player
  def playerWithHighCard(bigCard, [_1c, _2c, _3c, bigCard], [_p1, _p2, _p3, player]), do: player

  def wonTrick(playerHC, [p1, p2, p3, p4], playedSoFar) do
    cond do
      playerHC == 0 -> [p1 ++ playedSoFar, p2, p3, p4]
      playerHC == 1 -> [p1, p2 ++ playedSoFar, p3, p4]
      playerHC == 2 -> [p1, p2, p3 ++ playedSoFar, p4]
      playerHC == 3 -> [p1, p2, p3, p4 ++ playedSoFar]
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
      true -> [p1Score + newP1 + queen1, p2Score + newP2 + queen2, p3Score + newP3 + queen3, p4Score + newP4 + queen4]
    end
  end

  # move endGame to file running the whole game
  def endGame?(scores) do
    cond do
      Enum.count(scores, fn x -> x >= 100 end) > 0 -> true
      true -> false
    end
  end

  def countHearts(tricks) do
    Enum.map(tricks, fn x -> Enum.count(x, fn {x, _y} -> x == :heart end) end)
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
