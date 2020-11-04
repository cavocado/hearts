defmodule Player do

  def playCard() do
    card = IO.gets("What card would you like to play?")
    String.trim(card)
  end

  def cardsPlayed(playedCards) do
    Enum.map(playedCards, fn {x, y} -> IO.puts("#{y} of #{x}s\n") end)
  end

  def inValidPlay() do
    IO.puts("You can't play that card.")
    playCard()
  end

  def stringToCardValue(card) do
    numberValues = %{"0" => :zero, "2" => :two, "3" => :three, "4" => :four, "5" => :five, "6" => :six, "7" => :seven, "8" => :eight, "9" => :nine, "10" => :ten, "jack" => :jack, "queen" => :queen, "king" => :king, "ace" => :ace}
    suitValues = %{"diamonds" => :diamond, "clubs" => :club, "hearts" => :heart, "spades" => :spade}
    values = String.split(card, " ", true)
    number = List.last(values)
    suit = List.first(values)
    {Map.fetch(suitValues, suit), Map.fetch(numberValues, number)}
  end

end
