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
    spades = board.sLeft
    clubs = board.cLeft
    diamonds = board.dLeft
    hearts = board.hLeft

    suitLead =
      if playedSoFar == [] do
        :anything
      else
        findSuit(playedSoFar)
      end

    possiblePlays =
      findPlays(hand, suitLead, isBroken, playedSoFar, spades, diamonds, clubs, hearts)

    card =
      if haveTwoClubs(hand) do
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

  def countSuit(hand, suit), do: Enum.count(hand, fn {x, _y} -> x == suit end)

  def removeSuit(hand, suit, num) when num <= 3,
    do: Enum.filter(hand, fn {x, _y} -> x == suit end)

  def removeSuit(_hand, _suit, _num), do: []

  # Somehow hearts are being played when they can't (including at beginning)
  def findPlays(hand, :anything, false, _p, spades, diamonds, clubs, _hearts) do
    sNum = spades - countSuit(hand, :spade)
    dNum = diamonds - countSuit(hand, :diamond)
    cNum = clubs - countSuit(hand, :club)
    left = Enum.filter(hand, fn {x, _y} -> x != :heart end)
    removeS = removeSuit(left, :spade, sNum)
    removeD = removeSuit(left, :diamond, dNum)
    removeC = removeSuit(left, :club, cNum)
    final = ((left -- removeS) -- removeD) -- removeC

    if final == [] do
      left
    else
      final
    end
  end

  def findPlays(hand, :anything, true, _p, spades, diamonds, clubs, hearts) do
    sNum = spades - countSuit(hand, :spade)
    dNum = diamonds - countSuit(hand, :diamond)
    cNum = clubs - countSuit(hand, :club)
    hNum = hearts - countSuit(hand, :heart)
    removeS = removeSuit(hand, :spade, sNum)
    removeD = removeSuit(hand, :diamond, dNum)
    removeC = removeSuit(hand, :club, cNum)
    removeH = removeSuit(hand, :heart, hNum)
    final = (((hand -- removeS) -- removeD) -- removeC) -- removeH

    if final == [] do
      hand
    else
      final
    end
  end

  def findPlays(hand, suitLead, _isBroken, p, spades, diamonds, clubs, hearts) do
    suit? = Rules.haveSuit(hand, suitLead)

    current =
      if suit? do
        Enum.filter(hand, fn {x, _y} -> x == suitLead end)
      else
        if haveTwoClubs(p) do
          Enum.filter(hand, fn {x, y} -> x != :heart and {x, y} != {:spade, :queen} end)
        else
          hand
        end
      end

    sNum = spades - countSuit(current, :spade)
    dNum = diamonds - countSuit(current, :diamond)
    cNum = clubs - countSuit(current, :club)
    hNum = hearts - countSuit(current, :heart)
    removeS = removeSuit(current, :spade, sNum)
    removeD = removeSuit(current, :diamond, dNum)
    removeC = removeSuit(current, :club, cNum)
    removeH = removeSuit(current, :heart, hNum)
    final = (((current -- removeS) -- removeD) -- removeC) -- removeH

    if final == [] do
      current
    else
      final
    end
  end
end
