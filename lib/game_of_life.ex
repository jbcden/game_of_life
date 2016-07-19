defmodule GameOfLife do

  def run(board) do
    board |> parse_board |> update_board
  end

  def parse_board(board) do
    Regex.scan(~r/^[0.]+$/m, board)
  end

  def update_board(board) do
    :timer.sleep(1000)
    print_board(board)
    next_board(board)
    |> normalize_board
    |> update_board
  end

  def normalize_board(board) do
    Enum.map board, fn (row) -> [Enum.join(row)] end
  end

  def next_board(board) do
    for x <- 0..height(board)-1 do
      for y <- 0..width(board)-1, into: [] do
        current = current_state(board, x, y)
        get_coordinates(x, y)
        |> reduce_neighbors(board)
        |> update_state(current)
      end
    end
  end

  def update_state(neighbor_sum, current) do
    case { current, neighbor_sum } do
      { 1, 2 } -> "0"
      { _, 3 } -> "0"
      { _, 1 } -> "."
      { _, _ } -> "."
    end
  end

  def current_state(board, x, y) do
    board
    |> char_at(x, y)
    |> convert_char
  end

  def reduce_neighbors(coords, board) do
    neighbors = for [x, y] <- coords, into: [] do
      board
      |> char_at(x, y)
      |> convert_char
    end

    Enum.reduce(neighbors, &(&1 + &2))
  end

  def char_at(board, x, y) do
    Enum.at(board, rem(x, height(board)))
    |> Enum.at(0)
    |> String.split("")
    |> Enum.at(y)
  end

  def convert_char("."), do: 0
  def convert_char("0"), do: 1
  def convert_char(_), do: 0

  def get_coordinates(x, y) do
    [
      [x-1, y+1], [x, y+1], [x+1, y+1],
      [x-1, y],             [x+1, y],
      [x-1, y-1], [x, y-1], [x+1, y-1]
    ]
  end

  def width(board) do
    Enum.at(board, 0)
    |> Enum.at(0)
    |> String.split("", trim: true)
    |> length
  end

  def height(board) do
    Enum.count(board)
  end

  def print_board(board) do
    IO.puts IO.ANSI.clear()
    IO.puts Enum.join(board, "\n")
  end
end

board = """
..........
..........
....00....
...0.0....
..0..0.00.
..00.0.00.
...0.00...
...0..0...
....00....
..........
..........
"""

GameOfLife.run(board)
