defmodule Player do

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
      ## Get rid of card from hand
      [hands, tricks, newPlayedSoFar, isBroken, p1, p2, p3, p4, scores, roundNumber, roundOver]
    else
      IO.puts("You can't play that card.")
      playCard([hands, tricks, playedSoFar, isBroken, p1, p2, p3, p4, scores, roundNumber, roundOver])
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
    values = String.split(card, " ", true)
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
