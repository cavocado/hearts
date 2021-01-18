defmodule Computer do
  def pickPassingCards(board, player) do
    hands = board.hands
    hand = findHand(hands, player)
    clubs = countSuit(hand, :club)
    diamonds = countSuit(hand, :diamond)
    hearts = countSuit(hand, :heart)
    spades = countSuit(hand, :spade)
    run? = run(board, player)
    shuffledHand = Enum.shuffle(hand)
    options = if run? do
      filterCards(shuffledHand, true)
    else
      if spades <= 3 do
        orderList(shuffledHand, :spade)
      else
        if diamonds <= 3 do
          orderList(shuffledHand, :diamond)
        else
          if clubs <= 3 do
            orderList(shuffledHand, :club)
          else
            if hearts <= 3 do
              orderList(shuffledHand, :heart)
            else
              shuffledHand
            end
          end
        end
      end
    end
    card1 = List.first(options)
    nHand = List.delete(options, card1)
    card2 = List.first(nHand)
    tHand = List.delete(nHand, card2)
    card3 = List.first(tHand)
    [card1, card2, card3]
  end

  def run(board, 1), do: board.runP2
  def run(board, 2), do: board.runP3
  def run(board, 3), do: board.runP4

  def orderList(hand, suit) do
    sList = Enum.filter(hand, fn {x, _y} -> x == suit end)
    rest = Enum.filter(hand, fn {x, _y} -> x != suit end)
    sList ++ rest
  end

  def run?(hand) do
    hearts = findHearts(hand)
    if length(hearts) <= 3 do
      false
    else
      map = %{
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
      heartNums = Enum.map(hearts, fn {_x, y} -> Map.fetch!(map, y) end)
      if Enum.count(heartNums, fn x -> x < 14 - length(heartNums) end) > 0 do
        false
      else
        true
      end
    end
  end

  def findHearts(hand), do: Enum.filter(hand, fn {x, _y} -> x == :heart end)

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

    run = if player == 2 do
      board.runP2
    else
      if player == 3 do
        board.runP3
      else
        board.runP4
      end
    end

    suitLead =
      if playedSoFar == [] do
        :anything
      else
        findSuit(playedSoFar)
      end

    possiblePlays =
      findPlays(hand, suitLead, isBroken, playedSoFar, spades, diamonds, clubs, hearts, run, board.heart1, board.heart2, board.queen?)

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

  def filterSuits(hand, spades, diamonds, clubs, hearts) do
    sNum = spades - countSuit(hand, :spade)
    dNum = diamonds - countSuit(hand, :diamond)
    cNum = clubs - countSuit(hand, :club)
    hNum = hearts - countSuit(hand, :heart)
    removeS = removeSuit(hand, :spade, sNum)
    removeD = removeSuit(hand, :diamond, dNum)
    removeC = removeSuit(hand, :club, cNum)
    removeH = removeSuit(hand, :heart, hNum)
    (((hand -- removeS) -- removeD) -- removeC) -- removeH
  end

  def deleteSpades(hand, same_suit?, queen?) do
    if Rules.getLength(hand, 0) > 1 and same_suit? do
      nList = List.delete(hand, {:spade, :queen})
      if !queen? and Rules.getLength(nList, 0) > 1 do
        nList2 = List.delete(nList, {:spade, :king})
        if Rules.getLength(nList2, 0) > 1 do
          List.delete(nList2, {:spade, :ace})
        else
          nList2
        end
      else
        nList
      end
    else
      hand
    end
  end

  def findPlays(hand, :anything, false, _p, spades, diamonds, clubs, hearts, false, _h1, _h2, queen?) do
    left = Enum.filter(hand, fn {x, _y} -> x != :heart end)
    final = filterSuits(left, spades, diamonds, clubs, hearts)

    if final == [] do
      if left == [] do
        hand
      else
        deleteSpades(left, true, queen?)
      end
    else
      deleteSpades(final, true, queen?)
    end
  end

  def findPlays(hand, :anything, true, _p, spades, diamonds, clubs, hearts, false, _h1, _h2, queen?) do
    final = filterSuits(hand, spades, diamonds, clubs, hearts)

    if final == [] do
      deleteSpades(hand, true, queen?)
    else
      deleteSpades(final, true, queen?)
    end
  end

  def findPlays(hand, suitLead, _isBroken, p, spades, diamonds, clubs, hearts, false, h1, h2, queen?) do
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

    final = if h1 != 10 and h2 != 10 and !suit? and !haveTwoClubs(p) do
      Enum.filter(current, fn {x, y} -> x == :heart or (x == :spade and y == :queen) end)
    else
      filterSuits(current, spades, diamonds, clubs, hearts)
    end

    if final == [] do
      deleteSpades(current, suit?, queen?)
    else
      deleteSpades(final, suit?, queen?)
    end
  end

  def findPlays(hand, :anything, isBroken, _p, _spades, _diamonds, _clubs, _hearts, true, _h1, _h2, _q) do
    start = if isBroken do
      hand
    else
      Enum.filter(hand, fn {x, _y} -> x != :heart end)
    end

    filterCards(start, false)
  end

  def findPlays(hand, suitLead, _isBroken, _p, _spades, _diamonds, _clubs, _hearts, true, _h1, _h2, _q) do
    if Rules.haveSuit(hand, suitLead) do
      newHand = Enum.filter(hand, fn {x, _y} -> x == suitLead end)
      # filter for biggest cards unless can't beat cards in p
      filterCards(newHand, false)
    else
      newHand = Enum.filter(hand, fn {x, y} -> x != :heart and {x, y} != {:spade, :queen} end)
      filterCards(newHand, true)
    end
  end

  def filterCards(hand, small_to_big?) do
    numHand = Enum.map(hand, fn x -> getNewCard(x) end)
    newHand = Enum.sort(numHand)

    rev = if !small_to_big? do
      Enum.reverse(newHand)
    else
      newHand
    end

    Enum.map(rev, fn x -> getOldCard(x) end)
  end

  def getNewCard({x, y}) do
    map = %{
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
    {num, x}
  end

  def getOldCard({x, y}) do
    map2 = %{
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

    atom = Map.fetch!(map2, x)
    {y, atom}
  end
end
