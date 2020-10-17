defmodule Setup do

  def main(scores, roundNumber) do
    hands = shuffleAndDeal() |> Enum.map(hands, fn x -> sortCards(x) end)
    twoClubs = twoClubs(hands)
    nextPlayer = (twoClubs + 1) % 4
    followingPlayer = (nextPlayer + 1) % 4
    lastPlayer = (followingPlayer + 1) % 4
    [hands, [[],[],[],[]], [], false, twoClubs, nextPlayer, followingPlayer, lastPlayer, scores, roundNumber, false]
  end

  def shuffleAndDeal() do
    deck = [{:club, :two}, {:club, :three}, {:club, :four}, {:club, :five}, {:club, :six}, {:club, :seven}, {:club, :eight}, {:club, :nine}, {:club, :ten}, {:club, :jack}, {:club, :queen}, {:club, :king}, {:club, :ace}, {:diamond, :two}, {:diamond, :three}, {:diamond, :four}, {:diamond, :five}, {:diamond, :six}, {:diamond, :seven}, {:diamond, :eight}, {:diamond, :nine}, {:diamond, :ten}, {:diamond, :jack}, {:diamond, :queen}, {:diamond, :king}, {:diamond, :ace}, {:heart, :two}, {:heart, :three}, {:heart, :four}, {:heart, :five}, {:heart, :six}, {:heart, :seven}, {:heart, :eight}, {:heart, :nine}, {:heart, :ten}, {:heart, :jack}, {:heart, :queen}, {:heart, :king}, {:heart, :ace}, {:spade, :two}, {:spade, :three}, {:spade, :four}, {:spade, :five}, {:spade, :six}, {:spade, :seven}, {:spade, :eight}, {:spade, :nine}, {:spade, :ten}, {:spade, :jack}, {:spade, :queen}, {:spade, :king}, {:spade, :ace}]
    deck |> Enum.shuffle |> Enum.chunk_every(13)
  end

  # fix sort to work with atoms
  def sortCards(hand) do
    Enum.sort(hand)
  end

  defp twoClubs([[{:club, :two} | _tail], _player2, _player3, _player4]), do: 1
  defp twoClubs([_player1, [{:club, :two} | _tail], _player3, _player4]), do: 2
  defp twoClubs([_player1, _player2, [{:club, :two} | _tail], _player4]), do: 3
  defp twoClubs([_player1, _player2, _player3, [{:club, :two} | _tail]]), do: 4

end
