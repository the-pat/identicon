defmodule Identicon do
  def main(input) do
    input
    |> hash_input()
    |> pick_color()
    |> build_grid()
  end

  @doc """
    Hash the given string and return a list of 16 numbers

  ## Examples

      iex> Identicon.hash_input("hello world!")
      %Identicon.Image{
        color: nil,
        hex: [252, 63, 249, 142, 140, 106, 13, 48, 135, 213, 21, 192, 71, 63, 134,
         119]
      }

  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end

  @doc """
    Take the first three hex values from the image as the RGB value

  ## Examples

      iex> image = %Identicon.Image{hex: [1, 2, 3, 4]}
      iex> Identicon.pick_color(image)
      %Identicon.Image{color: {1, 2, 3}, hex: [1, 2, 3, 4]}

  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
    Build a 5x5 grid from the hex values

  ## Examples

      iex> image = %Identicon.Image{hex: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]}
      iex> Identicon.build_grid(image)
      %Identicon.Image{
        color: nil,
        grid: [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12], [13, 14, 15]],
        hex: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
      }

  """
  def build_grid(%Identicon.Image{hex: hex_list} = image) do
    grid = hex_list
    |> Enum.chunk_every(3, 3, :discard)
    |> Enum.map(fn row -> mirror_row(row) end)

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Return the mirrored row

  ## Examples

      iex> row = [145, 46, 200]
      iex> Identicon.mirror_row(row)
      [145, 46, 200, 46, 145]
  """
  def mirror_row(row) do
    [first, second | _] = row
    row ++ [second, first]
  end
end
