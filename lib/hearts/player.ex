defmodule Player do
  def passCards(board) do
    [hand | _tail] = board.hands
    IO.puts("\nHere is your hand:")

    IO.puts(
      IO.ANSI.white_background() <>
        IO.ANSI.black() <> formatHand(hand, "") <> IO.ANSI.black_background() <> IO.ANSI.white()
    )

    p1c1 = getPassingCard(hand)
    p1c2 = getPassingCard(hand)
    p1c3 = getPassingCard(hand)
    [p1c1, p1c2, p1c3]
  end

  def getPassingCard(p1) do
    card =
      IO.gets("Player 1: Pick a card to pass: ")
      |> String.trim()

    if card == "help" do
      printInstructions()
      getPassingCard(p1)
    else
      newCard = stringToCardValue(card)

      if isInHand(p1, newCard) do
        newCard
      else
        IO.puts("Invalid choice - try something like 'clubs 10' or 'diamonds queen' which is in your hand")
        getPassingCard(p1)
      end
    end
  end

  def printInstructions() do
    IO.puts("\n
    The goal of Hearts is to take as few hearts and the queen of spades as possible or take all of them.

    At the beginning of each round, there may be some passing of cards that happens. There are 4
    different types of rounds for a 4 player game. The first round is passing to the left, the second is
    passing to the right, the third is passing across and the fourth is the hold hand in which no cards
    are passed. When passing, 3 cards are chosen to give to the player in the direction indicated.

    The person with the 2 of clubs starts each round by playing the 2 of clubs.
    Each other person has to play a club as well unless they don't have any in which case they would
    throw off a card other than a heart or the queen of spades (only a first trick rule).
    The person who played the highest card in the suit led wins the trick and leads for the next trick
    to repeat the process (doesn't have to lead clubs).

    Hearts can't be led until someone throws off a heart or the queen of spades has been played.
    The process above repeats until all of the cards have been played.

    When a round is over, everyone counts the number of hearts they took and the person who took the
    queen of spades adds 13 to the number of hearts they took. Then, they add the values to the scores
    they had previously. If someone took all the hearts and the queen of spades, then they have a choice
    to either take 26 away from their score or add 26 to all the other players' scores (in my game, 26 is
    added to all the other scores).

    Rounds are played until a player's score is greater than or equal to 100. The person with the lowest
    score wins the game.
    ")
  end

  def formatHand([{s, n} | t], string) do
    suitM = %{:spade => "♠️", :diamond => "♦️", :heart => "♥️", :club => "♣️"}

    numM = %{
      :two => "2",
      :three => "3",
      :four => "4",
      :five => "5",
      :six => "6",
      :seven => "7",
      :eight => "8",
      :nine => "9",
      :ten => "10",
      :jack => "J",
      :queen => "Q",
      :king => "K",
      :ace => "A"
    }

    suit = Map.fetch!(suitM, s)
    num = Map.fetch!(numM, n)

    if t == [] do
      string <> num <> suit <> " "
    else
      formatHand(t, string <> num <> suit <> " , ")
    end
  end

  def playCard(board) do
    p1 = board.p1
    playedSoFar = board.playedSoFar
    hands = board.hands
    IO.puts("\nIt's player #{p1 + 1}'s turn.")

    if Enum.count(playedSoFar) > 0 do
      IO.puts(
        IO.ANSI.black_background() <>
          IO.ANSI.white() <>
          "Here are the cards that have been played already" <>
          IO.ANSI.black_background() <> IO.ANSI.white()
      )

      IO.puts(
        IO.ANSI.white_background() <>
          IO.ANSI.black() <>
          formatHand(playedSoFar, "") <> IO.ANSI.black_background() <> IO.ANSI.white()
      )
    end

    hand = getHand(hands, p1)
    IO.puts("\nHere is your hand:")

    IO.puts(
      IO.ANSI.white_background() <>
        IO.ANSI.black() <> formatHand(hand, "") <> IO.ANSI.black_background() <> IO.ANSI.white()
    )

    {suit, number} = getCard() |> stringToCardValue()
    card = {suit, number}

    if suit == false || number == false do
      IO.puts("Not a valid input. Try again. - try something like 'clubs 10' or 'diamonds queen'")
      playCard(board)
    else
      if isInHand(hand, card) do
        newPlayedSoFar = playedSoFar ++ [card]
        newHands = removeCard(hands, card, p1)
        Board.changeP(board, newPlayedSoFar) |> Board.changeH(newHands)
      else
        IO.puts("You can't play that card - Please pick a card from your hand")
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
    card = IO.gets("What card would you like to play? ") |> String.trim()

    if card == "help" do
      printInstructions()
      getCard()
    else
      card
    end
  end

  def stringToCardValue(card) do
    values = String.split(card, " ")
    number = List.last(values)
    suit = List.first(values)
    {getSuitAtom(suit), getNumberAtom(number)}
  end

  def getNumberAtom(num) do
    numberValues = %{
      "0" => :zero,
      "2" => :two,
      "3" => :three,
      "4" => :four,
      "5" => :five,
      "6" => :six,
      "7" => :seven,
      "8" => :eight,
      "9" => :nine,
      "10" => :ten,
      "jack" => :jack,
      "queen" => :queen,
      "king" => :king,
      "ace" => :ace
    }

    result = Map.fetch(numberValues, num)

    if result == :error do
      false
    else
      {:ok, number} = result
      number
    end
  end

  def getSuitAtom(suit) do
    suitValues = %{
      "diamonds" => :diamond,
      "clubs" => :club,
      "hearts" => :heart,
      "spades" => :spade
    }

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
