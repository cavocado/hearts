defmodule Board do
  defstruct hands: [],
            broken?: false,
            playedSoFar: [],
            tricks: [[], [], [], []],
            p1: 0,
            p2: 1,
            p3: 2,
            p4: 3,
            scores: [0, 0, 0, 0],
            roundNumber: 0,
            roundOver: false,
            sLeft: 13,
            hLeft: 13,
            dLeft: 13,
            cLeft: 13,
            heart1: 10,
            heart2: 10,
            easy?: false,
            queen?: false,
            runP2: false,
            runP3: false,
            runP4: false

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

  def changeSL(board, value) do
    %Board{board | sLeft: value}
  end

  def changeHL(board, value) do
    %Board{board | hLeft: value}
  end

  def changeCL(board, value) do
    %Board{board | cLeft: value}
  end

  def changeDL(board, value) do
    %Board{board | dLeft: value}
  end

  def changeH1(board, value) do
    %Board{board | heart1: value}
  end

  def changeH2(board, value) do
    %Board{board | heart2: value}
  end

  def changeE(board, value) do
    %Board{board | easy?: value}
  end

  def changeQ(board, value) do
    %Board{board | queen?: value}
  end

  def changeR2(board, value) do
    %Board{board | runP2: value}
  end

  def changeR3(board, value) do
    %Board{board | runP3: value}
  end

  def changeR4(board, value) do
    %Board{board | runP4: value}
  end
end
