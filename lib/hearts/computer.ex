defmodule Computer do

  def pickPassingCards(board, player) do
    hands = board.hands
    hand = findHand(hands, player)
    shuffledHand = Enum.shuffle(hand)
    card1 = List.first(shuffledHand)
    nHand = List.delete(shuffledHand, card1)
    card2 = List.first(nHand)
    tHand = List.delete(nHand, card2)
    card3 = List.first(tHand)
    [card1, card2, card3]
  end

  def pickCard(board) do
    player = board.p1
    hands = board.hands
    hand = findHand(hands, player)
    playedSoFar = board.playedSoFar
    isBroken = board.broken?
    suitLead = if playedSoFar == [] do
      :anything
    else
      findSuit(playedSoFar)
    end
    possiblePlays = findPlays(hand, suitLead, isBroken, playedSoFar)
    card = if haveTwoClubs(possiblePlays) do
      {:club, :two}
    else
      Enum.shuffle(possiblePlays) |> List.first()
    end
    newHands = Player.removeCard(hands, card, player)
    board
    |> Board.changeH(newHands)
    |> Board.changeP(playedSoFar ++ [card])
  end

  def haveTwoClubs([{:club, :two} | _tail]), do: true
  def haveTwoClubs(_), do: false

  def findHand([hand, _, _, _], 0), do: hand
  def findHand([_, hand, _, _], 1), do: hand
  def findHand([_, _, hand, _], 2), do: hand
  def findHand([_, _, _, hand], 3), do: hand

  def findSuit([{suit, _number} | _tail]), do: suit

  def findPlays(hand, :anything, false, _p) do
    Enum.filter(hand, fn {x, _y} -> x != :heart end)
  end

  def findPlays(hand, :anything, true, _p) do
    hand
  end

  def findPlays(hand, suitLead, _isBroken, p) do
    suit? = Rules.haveSuit(hand, suitLead)
    if suit? do
      Enum.filter(hand, fn {x, _y} -> x == suitLead end)
    else
      if haveTwoClubs(p) do
        Enum.filter(hand, fn {x, _y} -> x != :heart end)
      else
        hand
      end
    end
  end

end
