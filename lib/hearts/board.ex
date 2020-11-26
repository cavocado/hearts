defmodule Board do

  defstruct [
              hands: [],
              broken?: false,
              playedSoFar: [],
              tricks: [[],[],[],[]],
              p1: 0,
              p2: 1,
              p3: 2,
              p4: 3,
              scores: [0,0,0,0],
              roundNumber: 0,
              roundOver: false
            ]

  def new() do
    %Board{}
  end

  def changeH(board, value) do
    %Board{board | hands: value}
  end

  def changeB(board, value) do
    %Board{board | broken?: value}
  end

  def changeP(board, value) do
    %Board{board | playedSoFar: value}
  end

  def changeT(board, value) do
    %Board{board | tricks: value}
  end

  def changeP1(board, value) do
    %Board{board | p1: value}
  end

  def changeP2(board, value) do
    %Board{board | p2: value}
  end

  def changeP3(board, value) do
    %Board{board | p3: value}
  end

  def changeP4(board, value) do
    %Board{board | p4: value}
  end

  def changeS(board, value) do
    %Board{board | scores: value}
  end

  def changeRN(board, value) do
    %Board{board | roundNumber: value}
  end

  def changeRO(board, value) do
    %Board{board | roundOver: value}
  end

end
