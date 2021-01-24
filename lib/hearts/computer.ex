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
      if hearts > 5 do
        noHearts = Enum.filter(shuffledHand, fn {x, _y} -> x != :heart end)
        filterCards(noHearts, true)
      else
        filterCards(shuffledHand, true)
      end
    else
      if spades <= 3 and Enum.count(shuffledHand, fn x -> x == {:spade, :queen} end) == 1 do
        noQueen = Enum.filter(shuffledHand, fn x -> x != {:spade, :queen} end)
        [{:spade, :queen} | noQueen]
      else
        if diamonds <= 3 do
          orderList(shuffledHand, :diamond)
        else
          if clubs <= 4 do
            newList = orderList(shuffledHand, :club)
            first = List.first(newList)
            List.delete(newList, first)
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

    numOptions = Enum.map(options, fn x -> Setup.getNumber(x) end)
    newOptions = Enum.filter(numOptions, fn {x, y} -> (x != :spade) or (y >= 12) end)
    IO.inspect(newOptions)
    finalOptions = Enum.map(newOptions, fn x -> Setup.getAtom(x) end)

    card1 = List.first(finalOptions)
    nHand = List.delete(finalOptions, card1)
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

  def findSuits(hand, hearts) do
    spades = countSuit(hand, :spade) > 5
    diamonds = countSuit(hand, :diamond) > 5
    clubs = countSuit(hand, :club) > 5
    nHand = if !hearts do
      noHearts = Enum.filter(hand, fn {x, _y} -> x != :heart end)
      if length(noHearts) > 1 do
        Enum.filter(noHearts, fn x -> x != {:spade, :queen} end)
      else
        noHearts
      end
    else
      hand
    end

    sHand = if !spades and countSuit(nHand, :spade) < length(nHand) do
      Enum.filter(nHand, fn {x, _y} -> x != :spade end)
    else
      nHand
    end

    dHand = if !diamonds and countSuit(sHand, :diamond) < length(sHand) do
      Enum.filter(sHand, fn {x, _y} -> x != :diamond end)
    else
      sHand
    end

    if !clubs and countSuit(dHand, :club) < length(dHand) do
      Enum.filter(dHand, fn {x, _y} -> x != :club end)
    else
      dHand
    end
  end

  def deleteLargeHearts(hand, number) do
    numHand = Enum.map(hand, fn x -> Setup.getNumber(x) end)
    newHand = if Enum.filter(numHand, fn {x, y} -> x != :heart or y < number end) == [] do
      numHand
    else
      Enum.filter(numHand, fn {x, y} -> x != :heart or y < number end)
    end
    Enum.map(newHand, fn x -> Setup.getAtom(x) end)
  end

  def playLittleSpades?(hand, true) do
    if Enum.filter(hand, fn {x, _y} -> x != :spade end) == [] do
      hand
    else
      Enum.filter(hand, fn {x, _y} -> x != :spade end)
    end
  end

  def playLittleSpades?(hand, false) do
    if Enum.count(hand, fn x -> x == {:spade, :king} or x == {:spade, :ace} or x == {:spade, :queen} end) == 0 and countSuit(hand, :spade) > 0 do
      Enum.filter(hand, fn {x, _y} -> x == :spade end)
    else
      hand
    end
  end

  def findPlays(hand, :anything, false, _p, spades, diamonds, clubs, hearts, false, _h1, _h2, queen?) do
    left = Enum.filter(hand, fn {x, _y} -> x != :heart end)
    final = playLittleSpades?(left, queen?)
      |> deleteSpades(true, queen?)


    if filterSuits(final, spades, diamonds, clubs, hearts) != [] do
      filterSuits(final, spades, diamonds, clubs, hearts)
    else
      if final == [] do
        hand
      else
        final
      end
    end
  end

  def findPlays(hand, :anything, true, _p, spades, diamonds, clubs, hearts, false, _h1, _h2, queen?) do
    final = playLittleSpades?(hand, queen?)
    |> deleteSpades(true, queen?)
    |> deleteLargeHearts(10)

    if filterSuits(final, spades, diamonds, clubs, hearts) != [] do
      filterSuits(final, spades, diamonds, clubs, hearts)
    else
      final
    end
  end

  def findPlays(hand, suitLead, _isBroken, p, _spades, _diamonds, _clubs, _hearts, false, h1, h2, queen?) do
    suit? = Rules.haveSuit(hand, suitLead)

    current =
      if suit? do
        newH = Enum.filter(hand, fn {x, _y} -> x == suitLead end)
        if suitLead == :heart do
          {_s, num} = Rules.largestCard(p)
          deleteLargeHearts(newH, num)
        else
          newH
        end
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
      if !suit? do
        if !haveTwoClubs(p) do
          findSuits(current, false)
        else
          findSuits(current, true)
        end
      else
        deleteSpades(current, suit?, queen?)
      end
    end

    if final == [] do
      current
    else
      final
    end
  end

  def findPlays(hand, :anything, isBroken, _p, _spades, _diamonds, _clubs, _hearts, true, _h1, _h2, _q) do
    start = if isBroken do
      hand
    else
      if Enum.count(hand, fn {x, _y} -> x != :heart end) == 0 do
        hand
      else
        Enum.filter(hand, fn {x, _y} -> x != :heart end)
      end
    end

    filterCards(start, false)
  end

  def findPlays(hand, suitLead, _isBroken, p, _spades, _diamonds, _clubs, _hearts, true, _h1, _h2, _q) do
    if Rules.haveSuit(hand, suitLead) do
      newHand = Enum.filter(hand, fn {x, _y} -> x == suitLead end)
      [{_s, lH} | _tail] = filterCards(newHand, false)
      {_sp, lP} = Rules.largestCard(p)
      if lH < lP do
        filterCards(newHand, true)
      else
        filterCards(newHand, false)
      end
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
