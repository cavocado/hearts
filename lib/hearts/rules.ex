defmodule Rules do
  def ruleCheck(board) do
    playedSoFar = board.playedSoFar
    hands = board.hands
    tricks = board.tricks
    p1 = board.p1
    p2 = board.p2
    p3 = board.p3
    p4 = board.p4
    isBroken = board.broken?
    sizePlayedSoFar = getLength(playedSoFar, 0)

    {fineSuit, newIsBroken} =
      cond do
        sizePlayedSoFar > 1 -> okSuit(hands, playedSoFar, p1, isBroken)
        sizePlayedSoFar == 1 -> checkFirstCard(hands, playedSoFar, isBroken, p1)
        sizePlayedSoFar < 1 -> {true, isBroken}
      end

    if not fineSuit do
      aHands = addCard(hands, List.last(playedSoFar), p1)
      newHands = Enum.map(aHands, fn x -> Setup.sortCards(x) end)
      IO.puts("You can't play that card.")
      Board.changeH(board, newHands) |> Board.changeP(Enum.drop(playedSoFar, -1))
    else
      newBoard = Board.changeB(board, newIsBroken)

      if sizePlayedSoFar < 4 do
        Board.changeP1(newBoard, p2)
        |> Board.changeP2(p3)
        |> Board.changeP3(p4)
        |> Board.changeP4(p1)
        |> Board.changeRO(false)
      else
        bigCard = largestCard(playedSoFar)
        whichPlayer = playerWithHighCard(bigCard, playedSoFar, [p2, p3, p4, p1])
        IO.puts("Player #{whichPlayer + 1} won the trick.\n")
        printCardsPlayed(playedSoFar, [p2, p3, p4, p1])
        secPlayer = rem(whichPlayer + 1, 4)
        thrPlayer = rem(whichPlayer + 2, 4)
        forPlayer = rem(whichPlayer + 3, 4)
        newTricks = wonTrick(whichPlayer, tricks, playedSoFar)
        newIsBroken = haveQueenSpades(playedSoFar, isBroken)

        [clubs, diamonds, hearts, spades] =
          numSuit(playedSoFar, newBoard.cLeft, newBoard.dLeft, newBoard.hLeft, newBoard.sLeft)

        IO.puts(
          "left: clubs #{clubs}, diamonds #{diamonds}, hearts #{hearts}, spades #{spades}\n"
        )

        nextBoard =
          Board.changeT(newBoard, newTricks)
          |> Board.changeP1(whichPlayer)
          |> Board.changeP2(secPlayer)
          |> Board.changeP3(thrPlayer)
          |> Board.changeP4(forPlayer)
          |> Board.changeP([])
          |> Board.changeB(newIsBroken)
          |> Board.changeCL(clubs)
          |> Board.changeDL(diamonds)
          |> Board.changeHL(hearts)
          |> Board.changeSL(spades)

        if hands == [[], [], [], []] do
          scores = board.scores
          IO.puts("The new scores are ")
          IO.inspect(newScores(newTricks, scores))

          Board.changeS(nextBoard, newScores(newTricks, scores))
          |> Board.changeRO(true)
        else
          Board.changeRO(nextBoard, false)
        end
      end
    end
  end

  def numSuit(playedSoFar, cLeft, dLeft, hLeft, sLeft) do
    clubs = Enum.count(playedSoFar, fn {x, _y} -> x == :club end)
    diamonds = Enum.count(playedSoFar, fn {x, _y} -> x == :diamond end)
    hearts = Enum.count(playedSoFar, fn {x, _y} -> x == :heart end)
    spades = Enum.count(playedSoFar, fn {x, _y} -> x == :spade end)
    [cLeft - clubs, dLeft - diamonds, hLeft - hearts, sLeft - spades]
  end

  def printCardsPlayed([{suit1, num1}, {suit2, num2}, {suit3, num3}, {suit4, num4}], [
        p1,
        p2,
        p3,
        p4
      ]) do
    IO.puts("Player #{p1 + 1} played:")
    printCard({suit1, num1})
    IO.puts("Player #{p2 + 1} played:")
    printCard({suit2, num2})
    IO.puts("Player #{p3 + 1} played:")
    printCard({suit3, num3})
    IO.puts("Player #{p4 + 1} played:")
    printCard({suit4, num4})
  end

  def printCard({suit, num}) do
    suitM = %{:spade => "♠️", :diamond => "♦️", :heart => "♥️", :club => "♣️"}

    numM = %{
      :two => "2 ",
      :three => "3 ",
      :four => "4 ",
      :five => "5 ",
      :six => "6 ",
      :seven => "7 ",
      :eight => "8 ",
      :nine => "9 ",
      :ten => "10",
      :jack => "J ",
      :queen => "Q ",
      :king => "K ",
      :ace => "A "
    }

    {:ok, nSuit} = Map.fetch(suitM, suit)
    {:ok, nNum} = Map.fetch(numM, num)

    # IO.puts("-------------")
    # IO.puts("|           |")
    # IO.puts("|     #{nNum}    |")
    # IO.puts("|     #{nSuit}     |")
    # IO.puts("|           |")
    # IO.puts("-------------")
    IO.puts(
      IO.ANSI.white_background() <>
        IO.ANSI.black() <> "#{nNum}#{nSuit}" <> IO.ANSI.black_background() <> IO.ANSI.white()
    )
  end

  def haveQueenSpades(playedSoFar, isBroken) do
    cond do
      Enum.count(playedSoFar, fn x -> x == {:spade, :queen} end) > 0 -> true
      true -> isBroken
    end
  end

  def checkFirstCard(hands, [{suit, number}], isBroken, p1) do
    hand = findHand(p1, hands)

    cond do
      haveTwoClubs(hands) and {suit, number} == {:club, :two} -> {true, isBroken}
      haveTwoClubs(hands) -> {false, isBroken}
      isBroken -> {true, true}
      suit != :heart -> {true, isBroken}
      Enum.count(hand, fn {x, _y} -> x != :heart end) == 0 -> {true, true}
      true -> {false, isBroken}
    end
  end

  defp haveTwoClubs([[{:club, :two} | _tail], _player2, _player3, _player4]), do: true
  defp haveTwoClubs([_player1, [{:club, :two} | _tail], _player3, _player4]), do: true
  defp haveTwoClubs([_player1, _player2, [{:club, :two} | _tail], _player4]), do: true
  defp haveTwoClubs([_player1, _player2, _player3, [{:club, :two} | _tail]]), do: true
  defp haveTwoClubs(_hands), do: false

  def getLength(list, count) do
    if list == [] do
      count
    else
      newList = List.delete_at(list, 0)
      getLength(newList, count + 1)
    end
  end

  def addCard([p1, p2, p3, p4], card, player) do
    cond do
      player == 0 -> [p1 ++ [card], p2, p3, p4]
      player == 1 -> [p1, p2 ++ [card], p3, p4]
      player == 2 -> [p1, p2, p3 ++ [card], p4]
      player == 3 -> [p1, p2, p3, p4 ++ [card]]
    end
  end

  def okSuit(hands, [{suit, number} | tail], first, isBroken) do
    player = first
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
      Enum.count(hand, fn {x, _y} -> x == suit end) > 0 -> true
      true -> false
    end
  end

  def heartsOk(hand, [{suit, number} | _tail], isBroken) do
    cond do
      isBroken -> {true, true}
      {suit, number} == {:club, :two} -> {false, isBroken}
      Enum.count(hand, fn {x, _y} -> x != :heart end) == 0 -> {true, true}
      haveSuit(hand, suit) == false -> {true, true}
      true -> {false, false}
    end
  end

  def largestCard([{suit1, number1}, {suit2, number2}, {suit3, number3}, {suit4, number4}]) do
    suit = suit1

    numbers =
      Enum.map([{suit1, number1}, {suit2, number2}, {suit3, number3}, {suit4, number4}], fn {x, y} ->
        checkSuit(x, y, suit)
      end)

    correspondingNumbers = Enum.map(numbers, fn a -> getNumber(a) end)
    greatest = Enum.max(correspondingNumbers)
    {suit, getAtom(greatest)}
  end

  def getNumber(y) do
    map = %{
      :zero => 0,
      :two => 2,
      :three => 3,
      :four => 4,
      :five => 5,
      :six => 6,
      :seven => 7,
      :eight => 8,
      :nine => 9,
      :ten => 10,
      :jack => 11,
      :queen => 12,
      :king => 13,
      :ace => 14
    }

    {:ok, num} = Map.fetch(map, y)
    num
  end

  def getAtom(num) do
    map2 = %{
      0 => :zero,
      2 => :two,
      3 => :three,
      4 => :four,
      5 => :five,
      6 => :six,
      7 => :seven,
      8 => :eight,
      9 => :nine,
      10 => :ten,
      11 => :jack,
      12 => :queen,
      13 => :king,
      14 => :ace
    }

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
      newP1 + queen1 == 26 ->
        [p1Score, p2Score + 26, p3Score + 26, p4Score + 26]

      newP2 + queen2 == 26 ->
        [p1Score + 26, p2Score, p3Score + 26, p4Score + 26]

      newP3 + queen3 == 26 ->
        [p1Score + 26, p2Score + 26, p3Score, p4Score + 25]

      newP4 + queen4 == 26 ->
        [p1Score + 26, p2Score + 26, p3Score + 26, p4Score]

      true ->
        [
          p1Score + newP1 + queen1,
          p2Score + newP2 + queen2,
          p3Score + newP3 + queen3,
          p4Score + newP4 + queen4
        ]
    end
  end

  def countHearts(tricks) do
    Enum.map(tricks, fn x -> Enum.count(x, fn {x, _y} -> x == :heart end) end)
  end

  def countQueen(tricks) do
    [p1, p2, p3, p4] =
      Enum.map(tricks, fn x -> Enum.count(x, fn y -> y == {:spade, :queen} end) end)

    cond do
      p1 == 1 -> [13, 0, 0, 0]
      p2 == 1 -> [0, 13, 0, 0]
      p3 == 1 -> [0, 0, 13, 0]
      p4 == 1 -> [0, 0, 0, 13]
    end
  end
end
