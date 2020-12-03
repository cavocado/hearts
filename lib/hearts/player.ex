defmodule Player do

  def passCards(board) do
    [hand | _tail] = board.hands
    IO.inspect(hand)
    p1c1 = getPassingCard(hand)
    p1c2 = getPassingCard(hand)
    p1c3 = getPassingCard(hand)
    [p1c1, p1c2, p1c3]
  end

  def getPassingCard(p1) do
    card = IO.gets(IO.ANSI.red <> "Player 1: Pick a card to pass: " <> IO.ANSI.normal) |> String.trim() |> stringToCardValue()
    if isInHand(p1, card) do
      card
    else
      IO.puts("Invalid choice")
      getPassingCard(p1)
    end
  end

  def playCard(board) do
    p1 = board.p1
    playedSoFar = board.playedSoFar
    hands = board.hands
    IO.puts(IO.ANSI.green <> "It's player #{p1 + 1}'s turn." <> IO.ANSI.normal)
    if Enum.count(playedSoFar) > 0 do
      IO.puts(IO.ANSI.light_blue <> "Here are the cards that have been played already" <> IO.ANSI.normal)
      cardsPlayed(playedSoFar)
    end
    hand = getHand(hands, p1)
    IO.puts("Here is your hand:")
    IO.inspect(hand)
    {suit, number} = getCard() |> stringToCardValue()
    card = {suit, number}
    if (suit == false) || (number == false) do
      IO.puts(IO.ANSI.red <> "Not a valid input. Try again." <> IO.ANSI.normal)
      playCard(board)
    else
      if isInHand(hand, card) do
        newPlayedSoFar = playedSoFar ++ [card]
        newHands = removeCard(hands, card, p1)
        Board.changeP(board, newPlayedSoFar) |> Board.changeH(newHands)
      else
        IO.puts(IO.ANSI.red <> "You can't play that card." <> IO.ANSI.normal)
        playCard(board)
      end
    end
  end

  def removeCard([p1, p2, p3, p4], card, player) do
    cond do
      player == 0 -> [List.delete(p1, card), p2, p3, p4]
      player == 1 -> [p1, List.delete(p2, card), p3, p4]
      player == 2 -> [p1, p2, List.delete(p3, card), p4]
      player == 3 -> [p1, p2, p3, List.delete(p4, card)]
    end
  end

  def getHand([hand | _tail], 0), do: hand
  def getHand([_p1, hand, _p3, _p4], 1), do: hand
  def getHand([_p1, _p2, hand, _p4], 2), do: hand
  def getHand([_p1, _p2, _p3, hand], 3), do: hand

  def getCard() do
    card = IO.gets("What card would you like to play? ")
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
    result = Map.fetch(numberValues, num)
    if result == :error do
      false
    else
      {:ok, number} = result
      number
    end
  end

  def getSuitAtom(suit) do
    suitValues = %{"diamonds" => :diamond, "clubs" => :club, "hearts" => :heart, "spades" => :spade}
    result = Map.fetch(suitValues, suit)
    if result == :error do
      false
    else
      {:ok, asuit} = result
      asuit
    end
  end

  def isInHand(hand, {suit, number}) do
    card = List.keyfind(hand, suit, 0)
    if card == nil do
      false
    else
      if card == {suit, number} do
        true
      else
        newHand = List.delete(hand, card)
        isInHand(newHand, {suit, number})
      end
    end
  end

end
