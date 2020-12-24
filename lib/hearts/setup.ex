defmodule Setup do
  def main(currentScores, currentRoundNumber) do
    listHands = shuffleAndDeal()
    sortedHands = Enum.map(listHands, fn x -> sortCards(x) end)

    Board.new()
    |> Board.changeS(currentScores)
    |> Board.changeRN(currentRoundNumber)
    |> Board.changeH(sortedHands)
  end

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

  def sortCards(hand) do
    newHand = Enum.map(hand, fn a -> getNumber(a) end)
    sorted = Enum.sort(newHand)
    Enum.map(sorted, fn b -> getAtom(b) end)
  end

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
