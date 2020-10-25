defmodule Setup do

  def main(scores, roundNumber) do
    hands = shuffleAndDeal()
    sortedHands = Enum.map(hands, fn x -> sortCards(x) end)
    twoClubs = twoClubs(hands)
    nextPlayer = rem(twoClubs + 1, 4)
    followingPlayer = rem(nextPlayer + 1, 4)
    lastPlayer = rem(followingPlayer + 1, 4)
    [sortedHands, [[],[],[],[]], [], false, twoClubs, nextPlayer, followingPlayer, lastPlayer, scores, roundNumber, false]
  end

  def shuffleAndDeal() do
    deck = [{:club, :two}, {:club, :three}, {:club, :four}, {:club, :five}, {:club, :six}, {:club, :seven}, {:club, :eight}, {:club, :nine}, {:club, :ten}, {:club, :jack}, {:club, :queen}, {:club, :king}, {:club, :ace}, {:diamond, :two}, {:diamond, :three}, {:diamond, :four}, {:diamond, :five}, {:diamond, :six}, {:diamond, :seven}, {:diamond, :eight}, {:diamond, :nine}, {:diamond, :ten}, {:diamond, :jack}, {:diamond, :queen}, {:diamond, :king}, {:diamond, :ace}, {:heart, :two}, {:heart, :three}, {:heart, :four}, {:heart, :five}, {:heart, :six}, {:heart, :seven}, {:heart, :eight}, {:heart, :nine}, {:heart, :ten}, {:heart, :jack}, {:heart, :queen}, {:heart, :king}, {:heart, :ace}, {:spade, :two}, {:spade, :three}, {:spade, :four}, {:spade, :five}, {:spade, :six}, {:spade, :seven}, {:spade, :eight}, {:spade, :nine}, {:spade, :ten}, {:spade, :jack}, {:spade, :queen}, {:spade, :king}, {:spade, :ace}]
    deck |> Enum.shuffle |> Enum.chunk_every(13)
  end

  def sortCards(hand) do
    map = %{:two => 2, :three => 3, :four => 4, :five => 5, :six => 6, :seven => 7, :eight => 8, :nine => 9, :ten => 10, :jack => 11, :queen => 12, :king => 13, :ace => 14}
    map2 = %{2 => :two, 3 => :three, 4 => :four, 5 => :five, 6 => :six, 7 => :seven, 8 => :eight, 9 => :nine, 10 => :ten, 11 => :jack, 12 => :queen, 13 => :king, 14 => :ace}
    newHand = Enum.map(hand, fn {x, y} -> {x, Map.fetch(map, y)} end)
    sorted = Enum.sort(newHand)
    Enum.map(sorted, fn {x, y} -> {x, Map.fetch(map2, y)} end)
  end

  defp twoClubs([[{:club, :two} | _tail], _player2, _player3, _player4]), do: 1
  defp twoClubs([_player1, [{:club, :two} | _tail], _player3, _player4]), do: 2
  defp twoClubs([_player1, _player2, [{:club, :two} | _tail], _player4]), do: 3
  defp twoClubs([_player1, _player2, _player3, [{:club, :two} | _tail]]), do: 4

end
