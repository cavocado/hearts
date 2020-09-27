defmodule Rules do

  def ruleCheck([hands, tricks, playedSoFar, isBroken, 1p, 2p, 3p, 4p, scores]) do

  end

  def everyonePlayed([first, second, third, fourth]), do: largestCard(first, second, third, fourth)
  def everyonePlayed(playedCards), do: false

  def sameSuit(hands, playedCards, order) do

  end

  def heartsOk(hand, playedCards) do

  end

  def largestCard(1c, 2c, 3c, 4c) do
    ##return the largest card
  end

  def playerWithHighCard(bigCard, [bigCard | _tail], [player | _tail]), do: player
  def playerWithHighCard(bigCard, [_1c, bigCard, _3c, _4c], [_1p, player, _3p, _4p]), do: player
  def playerWithHighCard(bigCard, [_1c, _2c, bigCard, _4c], [_1p, _2p, player, _4p]), do: player
  def playerWithHighCard(bigCard, [_1c, _2c, _3c, bigCard], [_1p, _2p, _3p, player]), do: player

  def wonTrick(highCard, playerHC, [hands, tricks, playedSoFar, isBroken, _1p, _2p, _3p, _4p, scores]) do

  end

  def noCardsLeft([[],[],[],[]], tricks, [p1Score, p2Score, p3Score, p4Score]) do
    [newP1, newP2, newP3, newP4] = countHearts(tricks)
    newScores = [p1Score + newP1, p2Score + newP2, p3Score + newP3, p4Score + newP4]
    [newScores, Enum.map(newScores, fn x -> x >= 100 end)]
  end

  def noCardsLeft(_hands, _tricks, _score), do: false

  ## gets passed tricks
  def countHearts(tricks) do
    Enum.map(tricks, fn x -> Enum.count(x, fn y -> {:heart, _} or {:spade, :queen} end) end)
  end

end
