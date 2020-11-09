defmodule Player do

  def passCards([hands, tricks, playedSoFar, isBroken, p1, p2, p3, p4, scores, roundNumber, roundOver]) do
    type = cond do
      rem(roundNumber, 4) == 0 -> "left"
      rem(roundNumber, 4) == 1 -> "right"
      rem(roundNumber, 4) == 2 -> "across"
      rem(roundNumber, 4) == 3 -> "hold"
    end
    if type == "hold" do
      [hands, tricks, playedSoFar, isBroken, p1, p2, p3, p4, scores, roundNumber, roundOver]
    else
      p1c1 = getPassingCard(hands, 0)
      p1c2 = getPassingCard(hands, 0)
      p1c3 = getPassingCard(hands, 0)
      p2c1 = getPassingCard(hands, 1)
      p2c2 = getPassingCard(hands, 1)
      p2c3 = getPassingCard(hands, 1)
      p3c1 = getPassingCard(hands, 2)
      p3c2 = getPassingCard(hands, 2)
      p3c3 = getPassingCard(hands, 2)
      p4c1 = getPassingCard(hands, 3)
      p4c2 = getPassingCard(hands, 3)
      p4c3 = getPassingCard(hands, 3)
      newHands = removePassingCards(hands, p1c1, p1c2, p1c3, 0)
        |> removePassingCards(p2c1, p2c2, p2c3, 1)
        |> removePassingCards(p3c1, p3c2, p3c3, 2)
        |> removePassingCards(p4c1, p4c2, p4c3, 3)
      finalHands = addPassingCards(newHands, type, [p1c1, p1c2, p1c3], [p2c1, p2c2, p2c3], [p3c1, p3c2, p3c3], [p4c1, p4c2, p4c3])
      sortedHands = Enum.map(finalHands, fn x -> Setup.sortCards(x) end)
      [sortedHands, tricks, playedSoFar, isBroken, p1, p2, p3, p4, scores, roundNumber, roundOver]
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

  def getPassingCard([p1, p2, p3, p4], 0) do
    card = IO.gets("Player 1: Pick a card to pass: ") |> String.trim() |> stringToCardValue()
    if isInHand(p1, card) do
      card
    else
      IO.puts("Invalid choice")
      getPassingCard([p1, p2, p3, p4], 0)
    end
  end

  def getPassingCard([p1, p2, p3, p4], 1) do
    card = IO.gets("Player 2: Pick a card to pass: ") |> String.trim() |> stringToCardValue()
    if isInHand(p2, card) do
      card
    else
      IO.puts("Invalid choice")
      getPassingCard([p1, p2, p3, p4], 1)
    end
  end

  def getPassingCard([p1, p2, p3, p4], 2) do
    card = IO.gets("Player 3: Pick a card to pass: ") |> String.trim() |> stringToCardValue()
    if isInHand(p3, card) do
      card
    else
      IO.puts("Invalid choice")
      getPassingCard([p1, p2, p3, p4], 2)
    end
  end

  def getPassingCard([p1, p2, p3, p4], 3) do
    card = IO.gets("Player 4: Pick a card to pass: ") |> String.trim() |> stringToCardValue()
    if isInHand(p4, card) do
      card
    else
      IO.puts("Invalid choice")
      getPassingCard([p1, p2, p3, p4], 3)
    end
  end

  def playCard([hands, tricks, playedSoFar, isBroken, p1, p2, p3, p4, scores, roundNumber, roundOver]) do
    IO.puts("It's player #{p1}'s turn.\n")
    if Enum.count(playedSoFar) > 0 do
      IO.puts("Here are the cards that have been played already")
      cardsPlayed(playedSoFar)
    end
    card = getCard() |> stringToCardValue()
    hand = getHand(hands, p1)
    if isInHand(hand, card) do
      newPlayedSoFar = playedSoFar ++ card
      newHands = removeCard(hands, card, p1)
      [newHands, tricks, newPlayedSoFar, isBroken, p1, p2, p3, p4, scores, roundNumber, roundOver]
    else
      IO.puts("You can't play that card.")
      playCard([hands, tricks, playedSoFar, isBroken, p1, p2, p3, p4, scores, roundNumber, roundOver])
    end
  end

  def removeCard([p1, p2, p3, p4], card, player) do
    cond do
      player == 1 -> [List.delete(p1, card), p2, p3, p4]
      player == 2 -> [p1, List.delete(p2, card), p3, p4]
      player == 3 -> [p1, p2, List.delete(p3, card), p4]
      player == 4 -> [p1, p2, p3, List.delete(p4, card)]
    end
  end

  def getHand([hand | _tail], 0), do: hand
  def getHand([_p1, hand, _p3, _p4], 1), do: hand
  def getHand([_p1, _p2, hand, _p4], 2), do: hand
  def getHand([_p1, _p2, _p3, hand], 3), do: hand

  def getCard() do
    card = IO.gets("What card would you like to play?")
    String.trim(card)
  end

  def cardsPlayed(playedCards) do
    Enum.map(playedCards, fn {x, y} -> IO.puts("#{y} of #{x}s\n") end)
  end

  def stringToCardValue(card) do
    values = String.split(card, " ")
    number = List.last(values)
    suit = List.first(values)
    {getSuitAtom(suit), getNumberAtom(number)}
  end

  def getNumberAtom(num) do
    numberValues = %{"0" => :zero, "2" => :two, "3" => :three, "4" => :four, "5" => :five, "6" => :six, "7" => :seven, "8" => :eight, "9" => :nine, "10" => :ten, "jack" => :jack, "queen" => :queen, "king" => :king, "ace" => :ace}
    {:ok, atom} = Map.fetch(numberValues, num)
    atom
  end

  def getSuitAtom(suit) do
    suitValues = %{"diamonds" => :diamond, "clubs" => :club, "hearts" => :heart, "spades" => :spade}
    {:ok, atom} = Map.fetch(suitValues, suit)
    atom
  end

  def isInHand(hand, card) do
    Enum.find_value(hand, fn a -> a == card end)
  end

end
