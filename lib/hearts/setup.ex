defmodule Setup do

  def main() do
    hands = shuffleAndDeal() |> Enum.map(hands, fn x -> sortCards(x) end)
    twoClubs = ## find which hand has the 2 of Clubs
    nextPlayer = ## player after C2
    followingPlayer = ## player after nextPlayer
    lastPlayer = ## player after followingPlayer
    [hands, [[],[],[],[]], [], false, twoClubs, nextPlayer, followingPlayer, lastPlayer]
  end

  def shuffleAndDeal() do
    deck = for number <- '23456789TJQKA', suit <- 'CDHS', do: [suit,number]
    deck |> Enum.shuffle |> Enum.chunk_every(13)
  end

  def sortCards(hand) do
    shand = Enum.sort(hand)
    ## not finished; closer but not quite
  end

end
