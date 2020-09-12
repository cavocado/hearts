defmodule Setup do

  def main(scores) do
    hands = shuffleAndDeal() |> Enum.map(hands, fn x -> sortCards(x) end)
    twoClubs = twoClubs(hands)
    nextPlayer = twoClubs + 1
    followingPlayer = nextPlayer + 1
    lastPlayer = followingPlayer + 1
    [hands, [[],[],[],[]], [], false, twoClubs, nextPlayer, followingPlayer, lastPlayer, scores]
  end

  ## A = ten; B = jack; C = queen; D = king; E = Ace
  ## For sorting purposes...

  def shuffleAndDeal() do
    deck = for number <- '23456789ABCDE', suit <- 'CDHS', do: [suit,number]
    deck |> Enum.shuffle |> Enum.chunk_every(13)
  end

  def sortCards(hand) do
    Enum.sort(hand)
  end

  defp twoClubs([["C2" | _tail], _player2, _player3, _player4]), do: 1
  defp twoClubs([_player1, ["C2" | _tail], _player3, _player4]), do: 2
  defp twoClubs([_player1, _player2, ["C2" | _tail], _player4]), do: 3
  defp twoClubs([_player1, _player2, _player3, ["C2" | _tail]]), do: 4

end
