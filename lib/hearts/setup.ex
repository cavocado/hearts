defmodule Setup do
  # Sets up each round
  def main(currentScores, currentRoundNumber, cardCount?) do
    # Deals cards and sorts the hands
    listHands = shuffleAndDeal()
    [p1, p2, p3, p4] = Enum.map(listHands, fn x -> sortCards(x) end)

    # Checks if a player could take all of the hearts and queen of spades
    run2 = Computer.run?(p2)
    run3 = Computer.run?(p3)
    run4 = Computer.run?(p4)

    # Creates the state of the game
    board =
      Board.new()
      |> Board.changeS(currentScores)
      |> Board.changeRN(currentRoundNumber)
      |> Board.changeH([p1, p2, p3, p4])
      |> Board.changeR2(run2)
      |> Board.changeR3(run3)
      |> Board.changeR4(run4)

    # Prints direction of passing
    case rem(currentRoundNumber, 4) do
      0 -> IO.puts("\nPass left this round.")
      1 -> IO.puts("\nPass right this round.")
      2 -> IO.puts("\nPass across this round.")
      3 -> IO.puts("\nThis is a hold hand.")
    end

    # Checks if the card count should be displayed or not
    if cardCount? do
      Board.changeE(board, true)
    else
      board
    end
  end

  # Function to randomize hands
  def shuffleAndDeal() do
    deck = [
      {:club, :two},
      {:club, :three},
      {:club, :four},
      {:club, :five},
      {:club, :six},
      {:club, :seven},
      {:club, :eight},
      {:club, :nine},
      {:club, :ten},
      {:club, :jack},
      {:club, :queen},
      {:club, :king},
      {:club, :ace},
      {:diamond, :two},
      {:diamond, :three},
      {:diamond, :four},
      {:diamond, :five},
      {:diamond, :six},
      {:diamond, :seven},
      {:diamond, :eight},
      {:diamond, :nine},
      {:diamond, :ten},
      {:diamond, :jack},
      {:diamond, :queen},
      {:diamond, :king},
      {:diamond, :ace},
      {:heart, :two},
      {:heart, :three},
      {:heart, :four},
      {:heart, :five},
      {:heart, :six},
      {:heart, :seven},
      {:heart, :eight},
      {:heart, :nine},
      {:heart, :ten},
      {:heart, :jack},
      {:heart, :queen},
      {:heart, :king},
      {:heart, :ace},
      {:spade, :two},
      {:spade, :three},
      {:spade, :four},
      {:spade, :five},
      {:spade, :six},
      {:spade, :seven},
      {:spade, :eight},
      {:spade, :nine},
      {:spade, :ten},
      {:spade, :jack},
      {:spade, :queen},
      {:spade, :king},
      {:spade, :ace}
    ]

    deck |> Enum.shuffle() |> Enum.chunk_every(13)
  end

  # Sorts cards by suit and numerical order
  def sortCards(hand) do
    newHand = Enum.map(hand, fn a -> getNumber(a) end)
    sorted = Enum.sort(newHand)
    Enum.map(sorted, fn b -> getAtom(b) end)
  end

  # Translates atoms into integers for sorting
  def getNumber({x, y}) do
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
    {x, num}
  end

  # Translates integers back to atoms
  def getAtom({x, y}) do
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

    {:ok, atom} = Map.fetch(map2, y)
    {x, atom}
  end
end
